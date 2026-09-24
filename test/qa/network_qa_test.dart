// QA suite (2026-09-24): token refresh + backend error mapping.
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:xstore/core/constants/prefs_keys.dart';
import 'package:xstore/core/error/exceptions.dart';
import 'package:xstore/core/network/api_endpoints.dart';
import 'package:xstore/core/network/app_error_messages.dart';
import 'package:xstore/core/network/dio_error_mapper.dart';
import 'package:xstore/core/network/token_refresh_interceptor.dart';

import 'support/scripted_adapter.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('TokenRefreshInterceptor', () {
    late ScriptedAdapter server;
    late Dio dio;
    late int refreshFailedCalls;
    const storage = FlutterSecureStorage();

    setUp(() {
      FlutterSecureStorage.setMockInitialValues({
        PrefsKeys.authToken: 'old',
        PrefsKeys.authRefreshToken: 'refresh-1',
      });
      server = ScriptedAdapter();
      dio = scriptedDio(server);
      refreshFailedCalls = 0;
      dio.interceptors.add(
        TokenRefreshInterceptor(
          dio: dio,
          secureStorage: storage,
          onRefreshFailed: () async => refreshFailedCalls++,
        ),
      );
    });

    Options authed() => Options(headers: {'X-Auth-Token': 'old'});

    test('401 → refresh → retried once with the new token', () async {
      server.on('GET', '/api/orders/me', (req) async {
        return req.headers['X-Auth-Token'] == 'new'
            ? const FakeReply(200, [])
            : const FakeReply(401);
      });
      server.reply('POST', ApiEndpoints.refreshToken, 200,
          {'token': 'new', 'refreshToken': 'refresh-2'});

      final res = await dio.get<dynamic>('/api/orders/me', options: authed());
      expect(res.statusCode, 200);
      expect(await storage.read(key: PrefsKeys.authToken), 'new');
      expect(await storage.read(key: PrefsKeys.authRefreshToken), 'refresh-2');
      expect(refreshFailedCalls, 0);
    });

    test('three parallel 401s share ONE refresh call', () async {
      server.on('GET', '/api/x', (req) async => req.headers['X-Auth-Token'] ==
              'new'
          ? const FakeReply(200, {})
          : const FakeReply(401));
      server.on('POST', ApiEndpoints.refreshToken, (_) async {
        await Future<void>.delayed(const Duration(milliseconds: 20));
        return const FakeReply(200, {'token': 'new'});
      });
      await Future.wait(
        List.generate(3, (_) => dio.get<dynamic>('/api/x', options: authed())),
      );
      expect(server.count('POST', ApiEndpoints.refreshToken), 1);
    });

    test('unauthenticated 401 (login screen) does not trigger refresh',
        () async {
      server.reply('POST', ApiEndpoints.apiLogin, 401, {'errorEn': 'bad'});
      await expectLater(
        dio.post<dynamic>(ApiEndpoints.apiLogin, data: {}),
        throwsA(isA<DioException>()),
      );
      expect(server.count('POST', ApiEndpoints.refreshToken), 0);
    });

    test('rejected refresh token logs the user out', () async {
      server.reply('GET', '/api/x', 401);
      server.reply('POST', ApiEndpoints.refreshToken, 401);
      await expectLater(
        dio.get<dynamic>('/api/x', options: authed()),
        throwsA(isA<DioException>()),
      );
      expect(refreshFailedCalls, 1);
    });

    test('NO connectivity during refresh must NOT log the user out',
        () async {
      // Token expired while the phone is on flaky mobile data: the refresh
      // call itself fails at the transport level. Clearing the session here
      // forces a full re-login for a purely transient network problem.
      server.reply('GET', '/api/x', 401);
      server.on('POST', ApiEndpoints.refreshToken,
          (_) async => const FakeReply.transport(
                DioExceptionType.connectionError,
              ));
      await expectLater(
        dio.get<dynamic>('/api/x', options: authed()),
        throwsA(isA<DioException>()),
      );
      expect(refreshFailedCalls, 0);
    });

    test('a 5xx from refresh-token must NOT log the user out', () async {
      server.reply('GET', '/api/x', 401);
      server.reply('POST', ApiEndpoints.refreshToken, 503);
      await expectLater(
        dio.get<dynamic>('/api/x', options: authed()),
        throwsA(isA<DioException>()),
      );
      expect(refreshFailedCalls, 0);
    });
  });

  group('mapDioException', () {
    DioException bad(int status, Object? body) {
      final req = RequestOptions(path: '/x');
      return DioException(
        requestOptions: req,
        type: DioExceptionType.badResponse,
        response: Response<dynamic>(
          requestOptions: req,
          statusCode: status,
          data: body,
        ),
      );
    }

    Map<String, Object?> envelope(String en, {String? ar, int code = 400}) =>
        {
          'isSuccess': false,
          'data': null,
          'errorEn': en,
          'errorAr': ar ?? en,
          'statusCode': code,
        };

    test('transport errors → NetworkException', () {
      for (final t in [
        DioExceptionType.connectionTimeout,
        DioExceptionType.receiveTimeout,
        DioExceptionType.sendTimeout,
        DioExceptionType.connectionError,
      ]) {
        expect(
          mapDioException(
              DioException(requestOptions: RequestOptions(), type: t)),
          isA<NetworkException>(),
          reason: '$t',
        );
      }
    });

    test('backend envelope errorEn is surfaced', () {
      final e = mapDioException(bad(400, envelope('Listing not found.')));
      expect(e, isA<ServerException>());
      expect(e.message, 'Listing not found.');
    });

    test('401 → UnauthorizedException, 429 → rate-limit code', () {
      expect(mapDioException(bad(401, null)), isA<UnauthorizedException>());
      expect(mapDioException(bad(429, null)).message, rateLimitErrorCode);
    });

    test('phone-not-verified 400 maps to a stable code', () {
      final e = mapDioException(
          bad(400, envelope('Please verify your phone number first.')));
      expect(e.message, phoneNotVerifiedErrorCode);
    });

    test('store-location 403 maps to a stable code', () {
      final e = mapDioException(bad(
          403,
          envelope(
            'Store location (latitude/longitude) must be set before creating a listing',
            code: 403,
          )));
      expect(e.message, storeLocationRequiredErrorCode);
    });

    test('ASP.NET ProblemDetails validation errors are flattened', () {
      final e = mapDioException(bad(400, {
        'title': 'One or more validation errors occurred.',
        'errors': {
          'Price': ['Price must be > 0'],
          'Title': ['Title is required'],
        },
      }));
      expect(e.message, contains('Price must be > 0'));
      expect(e.message, contains('Title is required'));
    });

    test('non-JSON / HTML 502 body does not crash the mapper', () {
      final e = mapDioException(bad(502, '<html>Bad gateway</html>'));
      expect(e, isA<ServerException>());
    });

    test('a 500 must not surface raw server internals to the user', () {
      // Live probe: refresh-token with a malformed token answers 500 with
      // "IDX12741: JWT must have three segments…".
      final e = mapDioException(bad(
          500,
          envelope('IDX12741: JWT must have three segments (JWS) or five '
              'segments (JWE).', code: 500)));
      expect(e.message, isNot(contains('IDX12741')));
    });
  });
}
