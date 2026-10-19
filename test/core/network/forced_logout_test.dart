import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:xstore/core/constants/prefs_keys.dart';
import 'package:xstore/core/network/api_endpoints.dart';
import 'package:xstore/core/network/api_auth_headers.dart';
import 'package:xstore/core/network/dio_provider.dart';
import 'package:xstore/core/network/server_error_provider.dart';
import 'package:xstore/features/auth/domain/entities/user_entity.dart';
import 'package:xstore/features/auth/presentation/providers/auth_provider.dart';

class _Adapter implements HttpClientAdapter {
  _Adapter({this.refreshStatus = 401});
  final int refreshStatus;
  final requests = <RequestOptions>[];

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    requests.add(options);
    final status = options.path == ApiEndpoints.refreshToken
        ? refreshStatus
        : 401;
    return ResponseBody.fromString(
      jsonEncode({'message': 'no'}),
      status,
      headers: {
        Headers.contentTypeHeader: ['application/json'],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}

class _Auth extends Auth {
  int builds = 0;

  @override
  Future<UserEntity?> build() async {
    builds++;
    return const UserEntity(
      id: 'u1',
      name: 'T',
      email: 't@t.com',
      phoneNumber: '010',
      role: UserRole.consumer,
    );
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test(
    'a rejected refresh completes the forced logout without error',
    () async {
      FlutterSecureStorage.setMockInitialValues({
        PrefsKeys.authToken: 'old',
        PrefsKeys.authRefreshToken: 'bad-refresh',
        PrefsKeys.authUser: '{}',
      });
      final c = ProviderContainer(
        overrides: [authProvider.overrideWith(_Auth.new)],
      );
      addTearDown(c.dispose);
      c.read(dioProvider).httpClientAdapter = _Adapter();
      final auth = c.read(authProvider.notifier) as _Auth;
      await c.read(authProvider.future);
      expect(auth.builds, 1);

      await expectLater(
        c.read(dioProvider).get<dynamic>('/api/protected'),
        throwsA(isA<DioException>()),
      );

      const storage = FlutterSecureStorage();
      expect(await storage.read(key: PrefsKeys.authToken), isNull);
      expect(await storage.read(key: PrefsKeys.authRefreshToken), isNull);
      expect(await storage.read(key: PrefsKeys.authUser), isNull);
      // ref.invalidate(authProvider) was reached: auth rebuilds on next read.
      await c.read(authProvider.future);
      expect(auth.builds, 2, reason: 'authProvider must have been invalidated');
      expect(ApiEndpoints.refreshToken, isNotEmpty);
    },
  );

  group('refresh POST 5xx and the global server-error page', () {
    Future<(ProviderContainer, _Adapter)> setup() async {
      FlutterSecureStorage.setMockInitialValues({
        PrefsKeys.authToken: 'old',
        PrefsKeys.authRefreshToken: 'refresh',
      });
      final adapter = _Adapter(refreshStatus: 503);
      final c = ProviderContainer(
        overrides: [authProvider.overrideWith(_Auth.new)],
      );
      addTearDown(c.dispose);
      c.read(dioProvider).httpClientAdapter = adapter;
      return (c, adapter);
    }

    test(
      'a silent request keeps the page down and the refresh inherits it',
      () async {
        final (c, adapter) = await setup();
        await expectLater(
          c
              .read(dioProvider)
              .get<dynamic>(
                '/api/protected',
                options: ApiAuthHeaders.silentErrors(),
              ),
          throwsA(isA<DioException>()),
        );
        final refresh = adapter.requests.singleWhere(
          (r) => r.path == ApiEndpoints.refreshToken,
        );
        expect(refresh.extra[ApiAuthHeaders.silentErrorsKey], isTrue);
        expect(c.read(serverErrorProvider), isFalse);
      },
    );

    test('a normal request still raises it', () async {
      final (c, adapter) = await setup();
      await expectLater(
        c.read(dioProvider).get<dynamic>('/api/protected'),
        throwsA(isA<DioException>()),
      );
      final refresh = adapter.requests.singleWhere(
        (r) => r.path == ApiEndpoints.refreshToken,
      );
      expect(refresh.extra[ApiAuthHeaders.silentErrorsKey], isNull);
      expect(c.read(serverErrorProvider), isTrue);
    });
  });
}
