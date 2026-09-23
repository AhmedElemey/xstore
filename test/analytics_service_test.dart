import 'dart:convert';

import 'package:amplitude_flutter/amplitude.dart';
import 'package:amplitude_flutter/autocapture/autocapture.dart';
import 'package:amplitude_flutter/configuration.dart';
import 'package:dio/dio.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:xstore/core/analytics/analytics_service.dart';
import 'package:xstore/core/analytics/event_names.dart';
import 'package:xstore/core/constants/prefs_keys.dart';
import 'package:xstore/core/network/api_endpoints.dart';
import 'package:xstore/core/router/app_routes.dart';
import 'package:xstore/features/auth/domain/entities/user_entity.dart';
import 'package:xstore/features/auth/presentation/providers/auth_provider.dart';

import 'helpers/fake_async_auth_notifier.dart';

/// Stands in for the real `amplitude_flutter` platform channel — records
/// every `invokeMethod` call instead of dispatching to native code, so
/// tests can assert on exactly what the SDK was asked to send without a
/// real Android/iOS/web plugin registered.
class _RecordingMethodChannel extends MethodChannel {
  _RecordingMethodChannel() : super('amplitude_flutter');

  final calls = <MethodCall>[];

  @override
  Future<T?> invokeMethod<T>(String method, [dynamic arguments]) async {
    calls.add(MethodCall(method, arguments));
    if (method == 'init') return true as T?;
    return null;
  }
}

Amplitude _fakeAmplitude(_RecordingMethodChannel channel, {String apiKey = 'test-amplitude-key'}) =>
    Amplitude(
      Configuration(apiKey: apiKey, autocapture: const AutocaptureDisabled()),
      channel,
    );

class _RecordingAdapter implements HttpClientAdapter {
  _RecordingAdapter({this.statusCode = 202});

  final int statusCode;
  final posts = <RequestOptions>[];

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    posts.add(options);
    return ResponseBody.fromString(
      jsonEncode({'ok': true}),
      statusCode,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}

/// Real [Auth.logout] / [Auth.adoptSession] read analytics through Auth's own
/// `ref`. If analytics listens to `authProvider`, that read circular-asserts.
class _AuthThatReadsAnalytics extends FakeAuth {
  _AuthThatReadsAnalytics(super.user);

  void pingAnalytics() {
    ref.read(analyticsServiceProvider);
  }
}

UserEntity _user() => const UserEntity(
      id: 'u1',
      name: 'Buyer',
      email: 'buyer@test.com',
      phoneNumber: '01011111111',
    );

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late _RecordingAdapter adapter;
  late Dio dio;
  late AnalyticsService service;

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    adapter = _RecordingAdapter();
    dio = Dio(BaseOptions(baseUrl: 'https://example.test'))
      ..httpClientAdapter = adapter;
  });

  ProviderContainer buildContainer({
    required Auth auth,
    UserEntity? sessionUser,
    Map<String, String> secureValues = const {},
    Amplitude? amplitudeClient,
  }) {
    FlutterSecureStorage.setMockInitialValues(secureValues);
    late AnalyticsService created;
    final container = ProviderContainer(
      overrides: [
        authProvider.overrideWith(() => auth),
        analyticsServiceProvider.overrideWith((ref) {
          created = AnalyticsService(
            ref,
            client: dio,
            readAuthToken: () async => secureValues[PrefsKeys.authToken],
            amplitudeClient: amplitudeClient,
          );
          return created;
        }),
      ],
    );
    addTearDown(container.dispose);
    container.read(analyticsServiceProvider);
    service = created;
    service.bindSession(sessionUser);
    return container;
  }

  test('does not POST /api/analytics/events while the user is logged out',
      () async {
    buildContainer(auth: FakeAuth(null));
    service.track('view_item');
    await service.ready;
    await service.flushNow();

    expect(adapter.posts, isEmpty);
  });

  test('POSTs /api/analytics/events with X-Auth-Token when logged in',
      () async {
    buildContainer(
      auth: FakeAuth(_user()),
      sessionUser: _user(),
      secureValues: {PrefsKeys.authToken: 'sess-token'},
    );
    service.track('view_item');
    await service.ready;
    await service.flushNow();

    expect(adapter.posts, hasLength(1));
    expect(adapter.posts.single.path, ApiEndpoints.analyticsEvents);
    expect(adapter.posts.single.headers['X-Auth-Token'], 'sess-token');
  });

  test('POST body is {events: <queued event list>}, not a bare array',
      () async {
    buildContainer(
      auth: FakeAuth(_user()),
      sessionUser: _user(),
      secureValues: {PrefsKeys.authToken: 'sess-token'},
    );
    service.track('view_item', properties: {'item_id': 'p1'});
    service.track('add_to_cart', properties: {'item_id': 'p1'});
    await service.ready;
    await service.flushNow();

    expect(adapter.posts, hasLength(1));
    final body = Map<String, dynamic>.from(adapter.posts.single.data as Map);
    expect(body.keys, ['events']);
    final events = (body['events'] as List).cast<Map>();
    // app_open is also queued on init and rides in the same batch — filter
    // it out, it's not what this test is about.
    final tracked =
        events.where((e) => e['name'] != AnalyticsEvents.appOpen).toList();
    expect(tracked, hasLength(2));
    expect(tracked.map((e) => e['name']), ['view_item', 'add_to_cart']);
    expect(tracked.map((e) => e['eventName']), ['view_item', 'add_to_cart']);
    expect(tracked.first['eventId'], isNotEmpty);
    expect(tracked.first['timestamp'], isNotEmpty);
    expect(tracked.first['userId'], 'u1');
    expect(tracked.first['screenName'], isNotEmpty);
    expect(tracked.first['properties'], {'item_id': 'p1'});
  });

  test('flush stamps session identity onto events queued as a guest', () async {
    buildContainer(
      auth: FakeAuth(null),
      secureValues: {PrefsKeys.authToken: 'sess-token'},
    );
    service.track('view_item', properties: {'item_id': 'p1', 'price_egp': 10});
    await service.ready;
    await service.flushNow();
    expect(adapter.posts, isEmpty);

    service.bindSession(_user());
    await service.flushNow();

    final body = Map<String, dynamic>.from(adapter.posts.single.data as Map);
    final events = (body['events'] as List).cast<Map>();
    // app_open is queued on init as a guest and flushes in the same batch
    // once the session is bound.
    final viewItem = events.firstWhere((e) => e['name'] == 'view_item');
    expect(viewItem['userId'], 'u1');
    expect(viewItem['userRole'], 'consumer');
    expect(viewItem['eventName'], 'view_item');
    expect(viewItem['properties'], {'item_id': 'p1', 'price_egp': '10'});
  });

  test('flushes the queued events once the user logs in', () async {
    buildContainer(
      auth: FakeAuth(null),
      secureValues: {PrefsKeys.authToken: 'sess-token'},
    );
    service.track('view_item');
    await service.ready;
    await service.flushNow();
    expect(adapter.posts, isEmpty);

    service.bindSession(_user());
    await service.flushNow();

    expect(adapter.posts, hasLength(1));
    expect(adapter.posts.single.path, ApiEndpoints.analyticsEvents);
  });

  test('does not queue logout for the initial guest session', () async {
    buildContainer(auth: FakeAuth(null));
    await service.ready;
    // app_open is queued on every init (see the dedicated test below) —
    // this test is only about logout not being queued unprompted.
    expect(service.queuedEventNames, isNot(contains(AnalyticsEvents.logout)));
  });

  test('queues logout when the session goes from signed-in to signed-out',
      () async {
    buildContainer(
      auth: FakeAuth(_user()),
      sessionUser: _user(),
      secureValues: {PrefsKeys.authToken: 'sess-token'},
    );
    await service.ready;
    // Deterministically drain the app_open event queued on init (signed in
    // from the start, so it's eligible to flush) before asserting on the
    // queue below.
    await service.flushNow();
    expect(service.queuedEventNames, isEmpty);

    // Auth.logout tracks then bindSession(null); the event must stay queued.
    service.track(AnalyticsEvents.logout);
    service.bindSession(null);
    expect(service.queuedEventNames, [AnalyticsEvents.logout]);
  });

  test('flushBeforeSignOut sends logout while the session token is valid',
      () async {
    buildContainer(
      auth: FakeAuth(_user()),
      sessionUser: _user(),
      secureValues: {PrefsKeys.authToken: 'sess-token'},
    );
    await service.ready;
    await service.flushNow(); // drain app_open queued on init
    adapter.posts.clear();

    service.track(AnalyticsEvents.logout);
    await service.flushBeforeSignOut();
    service.bindSession(null);

    expect(adapter.posts, hasLength(1));
    final events = ((adapter.posts.single.data as Map)['events'] as List)
        .cast<Map>();
    expect(events.map((e) => e['name']), [AnalyticsEvents.logout]);
    expect(service.queuedEventNames, isEmpty);
  });

  test('never sends a previous account\'s events under the next session',
      () async {
    buildContainer(
      auth: FakeAuth(null),
      secureValues: {PrefsKeys.authToken: 'sess-token'},
    );
    await service.ready;

    // u1's logout could not be sent (e.g. offline) before signing out.
    service.bindSession(_user());
    await service.flushNow(); // settle the flush login kicks off
    adapter.posts.clear();
    service.track(AnalyticsEvents.logout);
    service.bindSession(null);
    service.track('view_item'); // guest browsing — stitched to next login

    const other = UserEntity(
      id: 'u2',
      name: 'Other',
      email: 'other@test.com',
      phoneNumber: '01022222222',
    );
    service.bindSession(other);
    await service.flushNow();

    final sent = [
      for (final post in adapter.posts)
        ...((post.data as Map)['events'] as List).cast<Map>(),
    ];
    // app_open (queued as a guest on init) may ride along — not the point.
    final tracked =
        sent.where((e) => e['name'] != AnalyticsEvents.appOpen).toList();
    expect(tracked.map((e) => e['name']), ['view_item']);
    expect(tracked.single['userId'], 'u2');
  });

  test('HTTP 200 drops the sent batch so the next flush does not resend it',
      () async {
    adapter = _RecordingAdapter(statusCode: 200);
    dio.httpClientAdapter = adapter;
    buildContainer(
      auth: FakeAuth(_user()),
      sessionUser: _user(),
      secureValues: {PrefsKeys.authToken: 'sess-token'},
    );
    service.track('view_item');
    await service.ready;
    await service.flushNow();
    expect(adapter.posts, hasLength(1));

    await service.flushNow();
    expect(adapter.posts, hasLength(1));
  });

  test('bindSession(null) stops flushing signed-in events', () async {
    buildContainer(
      auth: FakeAuth(_user()),
      sessionUser: _user(),
      secureValues: {PrefsKeys.authToken: 'sess-token'},
    );
    await service.ready;
    // Deterministically drain the app_open event queued on init (signed in
    // from the start, so it's eligible to flush) before asserting below
    // that signing out stops any further POSTs.
    await service.flushNow();
    adapter.posts.clear();
    service.bindSession(null);
    service.track('view_item');
    await service.flushNow();
    expect(adapter.posts, isEmpty);
  });

  test('tracks app_open exactly once, on init, before any user is known',
      () async {
    buildContainer(auth: FakeAuth(null));
    await service.ready;

    expect(service.queuedEventNames, [AnalyticsEvents.appOpen]);
  });

  group('route-driven events', () {
    test('screen_view fires for every route change', () async {
      buildContainer(auth: FakeAuth(null));
      await service.ready;

      service.debugRouteChanged('/home');

      expect(service.queuedEventNames, contains(AnalyticsEvents.screenView));
    });

    test('screen_view carries the previous route as referrer', () async {
      buildContainer(
        auth: FakeAuth(_user()),
        sessionUser: _user(),
        secureValues: {PrefsKeys.authToken: 'sess-token'},
      );
      await service.ready;

      service.debugRouteChanged('/product/p1', referrer: '/home');
      await service.flushNow();

      final sent = [
        for (final post in adapter.posts)
          ...((post.data as Map)['events'] as List).cast<Map>(),
      ];
      final view = sent.lastWhere((e) => e['name'] == AnalyticsEvents.screenView);
      expect(view['properties'], {
        AnalyticsProps.screenName: '/product/p1',
        AnalyticsProps.referrer: '/home',
      });
    });

    test('cart_viewed fires alongside screen_view when the route is /cart',
        () async {
      buildContainer(auth: FakeAuth(null));
      await service.ready;

      service.debugRouteChanged(AppRoutes.cart);

      expect(
        service.queuedEventNames,
        containsAllInOrder(
          [AnalyticsEvents.screenView, AnalyticsEvents.cartViewed],
        ),
      );
    });

    test('cart_viewed does not fire for other routes', () async {
      buildContainer(auth: FakeAuth(null));
      await service.ready;

      service.debugRouteChanged('/home');
      service.debugRouteChanged('/explore');

      expect(
        service.queuedEventNames,
        isNot(contains(AnalyticsEvents.cartViewed)),
      );
    });
  });

  test(
    'Auth.ref.read(analyticsServiceProvider) is not a circular dependency',
    () async {
      final auth = _AuthThatReadsAnalytics(_user());
      final container = buildContainer(
        auth: auth,
        sessionUser: _user(),
      );
      await container.read(authProvider.future);
      await service.ready;
      expect(auth.pingAnalytics, returnsNormally);
    },
  );

  group('Amplitude forwarding', () {
    late _RecordingMethodChannel channel;

    setUp(() {
      channel = _RecordingMethodChannel();
    });

    List<Map> trackCalls() => channel.calls
        .where((c) => c.method == 'track')
        .map((c) => (c.arguments as Map)['event'] as Map)
        .toList();

    test('does not construct an Amplitude client when no AMPLITUDE_API_KEY '
        'is configured — the disabled path never touches a platform '
        'channel, mocked or not', () async {
      buildContainer(auth: FakeAuth(null));
      service.track('view_item');
      await service.ready;
      await expectLater(service.flushNow(), completes);
    });

    test('forwards guest events with no signed-in user required', () async {
      buildContainer(auth: FakeAuth(null), amplitudeClient: _fakeAmplitude(channel));
      service.track('view_item', properties: {'item_id': 'p1'});
      await service.ready;
      await service.flushNow();

      // app_open is forwarded too (it's not session-gated) — pick out the
      // event this test is actually about.
      final viewItem =
          trackCalls().firstWhere((e) => e['event_type'] == 'view_item');
      expect(viewItem['user_id'], isNull);
      expect(viewItem['device_id'], isNotEmpty);
      expect(viewItem['event_properties'], containsPair('item_id', 'p1'));
    });

    test('includes user_id and role once signed in', () async {
      buildContainer(
        auth: FakeAuth(_user()),
        sessionUser: _user(),
        secureValues: {PrefsKeys.authToken: 'sess-token'},
        amplitudeClient: _fakeAmplitude(channel),
      );
      service.track('purchase');
      await service.ready;
      await service.flushNow();

      final purchaseEvent =
          trackCalls().firstWhere((e) => e['event_type'] == 'purchase');
      expect(purchaseEvent['user_id'], 'u1');
      expect(purchaseEvent['user_properties'], {'role': 'consumer'});
    });

    test('maps purchase value_egp onto Amplitude revenue fields', () async {
      buildContainer(
        auth: FakeAuth(_user()),
        sessionUser: _user(),
        secureValues: {PrefsKeys.authToken: 'sess-token'},
        amplitudeClient: _fakeAmplitude(channel),
      );
      service.track(
        AnalyticsEvents.purchase,
        properties: {AnalyticsProps.valueEgp: 499.5, AnalyticsProps.orderId: 'o1'},
      );
      await service.ready;
      await service.flushNow();

      final purchaseEvent =
          trackCalls().firstWhere((e) => e['event_type'] == 'purchase');
      expect(purchaseEvent['revenue'], 499.5);
      expect(purchaseEvent['revenue_type'], 'purchase');
    });

    test('an Amplitude track() call never affects the xStore collector '
        'queue, and vice versa', () async {
      buildContainer(
        auth: FakeAuth(_user()),
        sessionUser: _user(),
        secureValues: {PrefsKeys.authToken: 'sess-token'},
        amplitudeClient: _fakeAmplitude(channel),
      );
      service.track('view_item');
      await service.ready;
      await service.flushNow();

      expect(
        trackCalls().map((e) => e['event_type']),
        containsAll(['view_item', AnalyticsEvents.appOpen]),
      );
      expect(adapter.posts, hasLength(1)); // xStore collector still sent.
    });
  });
}
