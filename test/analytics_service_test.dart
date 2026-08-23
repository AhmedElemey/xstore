import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:xstore/core/analytics/analytics_service.dart';
import 'package:xstore/core/constants/prefs_keys.dart';
import 'package:xstore/core/network/api_endpoints.dart';
import 'package:xstore/features/auth/domain/entities/user_entity.dart';
import 'package:xstore/features/auth/presentation/providers/auth_provider.dart';

import 'helpers/fake_async_auth_notifier.dart';

class _RecordingAdapter implements HttpClientAdapter {
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
      202,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}

class _EmittingAuth extends FakeAuth {
  _EmittingAuth(super.user);

  void emit(UserEntity? user) {
    state = AsyncData(user);
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
    Map<String, String> secureValues = const {},
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
          );
          return created;
        }),
      ],
    );
    addTearDown(container.dispose);
    container.read(analyticsServiceProvider);
    service = created;
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
      secureValues: {PrefsKeys.authToken: 'sess-token'},
    );
    service.track('view_item');
    await service.ready;
    await service.flushNow();

    expect(adapter.posts, hasLength(1));
    expect(adapter.posts.single.path, ApiEndpoints.analyticsEvents);
    expect(adapter.posts.single.headers['X-Auth-Token'], 'sess-token');
  });

  test('flushes the queued events once the user logs in', () async {
    final auth = _EmittingAuth(null);
    buildContainer(
      auth: auth,
      secureValues: {PrefsKeys.authToken: 'sess-token'},
    );
    service.track('view_item');
    await service.ready;
    await service.flushNow();
    expect(adapter.posts, isEmpty);

    auth.emit(_user());
    await service.flushNow();

    expect(adapter.posts, hasLength(1));
    expect(adapter.posts.single.path, ApiEndpoints.analyticsEvents);
  });
}
