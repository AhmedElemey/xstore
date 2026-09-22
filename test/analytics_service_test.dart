import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
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
    Dio? amplitudeClient,
    String? amplitudeApiKey,
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
            amplitudeApiKey: amplitudeApiKey,
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
    // app_open is also queued on init (see the dedicated test below) and
    // rides in the same batch — filter it out, it's not what this test is
    // about.
    final tracked =
        events.where((e) => e['name'] != AnalyticsEvents.appOpen).toList();
    expect(tracked, hasLength(2));
    expect(tracked.map((e) => e['name']), ['view_item', 'add_to_cart']);
    expect(tracked.first['eventId'], isNotEmpty);
    expect(tracked.first['properties'], {'item_id': 'p1'});
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
    late _RecordingAdapter amplitudeAdapter;
    late Dio amplitudeDio;

    setUp(() {
      amplitudeAdapter = _RecordingAdapter(statusCode: 200);
      amplitudeDio = Dio()..httpClientAdapter = amplitudeAdapter;
    });

    test('does nothing when no AMPLITUDE_API_KEY is configured', () async {
      buildContainer(auth: FakeAuth(null), amplitudeClient: amplitudeDio);
      service.track('view_item');
      await service.ready;
      await service.flushNow();

      expect(amplitudeAdapter.posts, isEmpty);
    });

    test('forwards guest events with no signed-in user required', () async {
      buildContainer(
        auth: FakeAuth(null),
        amplitudeClient: amplitudeDio,
        amplitudeApiKey: 'test-amplitude-key',
      );
      service.track('view_item', properties: {'item_id': 'p1'});
      await service.ready;
      await service.flushNow();

      expect(amplitudeAdapter.posts, hasLength(1));
      final body = Map<String, dynamic>.from(
        amplitudeAdapter.posts.single.data as Map,
      );
      expect(body['api_key'], 'test-amplitude-key');
      final events = (body['events'] as List).cast<Map>();
      // app_open is forwarded too (it's not session-gated) — pick out the
      // event this test is actually about.
      final viewItem =
          events.firstWhere((e) => e['event_type'] == 'view_item');
      expect(viewItem['user_id'], isNull);
      expect(viewItem['device_id'], isNotEmpty);
      expect(viewItem['event_properties'], containsPair('item_id', 'p1'));
    });

    test('includes user_id and role once signed in, and never sends the '
        'xStore license/auth headers', () async {
      buildContainer(
        auth: FakeAuth(_user()),
        sessionUser: _user(),
        secureValues: {PrefsKeys.authToken: 'sess-token'},
        amplitudeClient: amplitudeDio,
        amplitudeApiKey: 'test-amplitude-key',
      );
      service.track('purchase');
      await service.ready;
      await service.flushNow();

      expect(amplitudeAdapter.posts, hasLength(1));
      final request = amplitudeAdapter.posts.single;
      expect(request.headers['Authorization'], isNull);
      expect(request.headers['X-Auth-Token'], isNull);
      final body = Map<String, dynamic>.from(request.data as Map);
      final events = (body['events'] as List).cast<Map>();
      final purchaseEvent =
          events.firstWhere((e) => e['event_type'] == 'purchase');
      expect(purchaseEvent['user_id'], 'u1');
      expect(purchaseEvent['user_properties'], {'role': 'consumer'});
    });

    test('maps purchase value_egp onto Amplitude revenue fields', () async {
      buildContainer(
        auth: FakeAuth(_user()),
        sessionUser: _user(),
        secureValues: {PrefsKeys.authToken: 'sess-token'},
        amplitudeClient: amplitudeDio,
        amplitudeApiKey: 'test-amplitude-key',
      );
      service.track(
        AnalyticsEvents.purchase,
        properties: {AnalyticsProps.valueEgp: 499.5, AnalyticsProps.orderId: 'o1'},
      );
      await service.ready;
      await service.flushNow();

      final body = Map<String, dynamic>.from(
        amplitudeAdapter.posts.single.data as Map,
      );
      final events = (body['events'] as List).cast<Map>();
      final purchaseEvent =
          events.firstWhere((e) => e['event_type'] == 'purchase');
      expect(purchaseEvent['revenue'], 499.5);
      expect(purchaseEvent['revenue_type'], 'purchase');
    });

    test('a failed Amplitude POST does not drop the batch and does not '
        'affect the xStore collector queue', () async {
      final failingAdapter = _RecordingAdapter(statusCode: 500);
      amplitudeDio.httpClientAdapter = failingAdapter;
      buildContainer(
        auth: FakeAuth(_user()),
        sessionUser: _user(),
        secureValues: {PrefsKeys.authToken: 'sess-token'},
        amplitudeClient: amplitudeDio,
        amplitudeApiKey: 'test-amplitude-key',
      );
      service.track('view_item');
      await service.ready;
      await service.flushNow();

      expect(failingAdapter.posts, hasLength(1));
      // The failed batch (view_item + the app_open queued on init) stays
      // queued in full for retry.
      expect(
        service.amplitudeQueuedEventNames,
        containsAll(['view_item', AnalyticsEvents.appOpen]),
      );
      expect(adapter.posts, hasLength(1)); // xStore collector still sent.
    });
  });
}
