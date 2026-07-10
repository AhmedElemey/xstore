import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:xstore/core/constants/prefs_keys.dart';
import 'package:xstore/core/network/api_endpoints.dart';
import 'package:xstore/core/network/token_refresh_interceptor.dart';

/// Fake transport: `/protected` returns 401 until [unlockAfter] refresh
/// calls have completed, then 200. `refreshToken` always succeeds and hands
/// back a new token pair. Records every header seen so tests can assert on
/// what was actually sent, including the retried request.
class _FakeAdapter implements HttpClientAdapter {
  int protectedCallCount = 0;
  int refreshCallCount = 0;
  final List<Map<String, List<String>>> protectedHeadersSeen = [];

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    if (options.path == ApiEndpoints.refreshToken) {
      refreshCallCount++;
      return ResponseBody.fromString(
        jsonEncode({'token': 'new-token', 'refreshToken': 'new-refresh-token'}),
        200,
        headers: {
          Headers.contentTypeHeader: [Headers.jsonContentType],
        },
      );
    }

    protectedCallCount++;
    protectedHeadersSeen.add(
      options.headers.map((k, v) => MapEntry(k, [v.toString()])),
    );
    final authorized = options.headers['X-Auth-Token'] == 'new-token';
    if (!authorized) {
      return ResponseBody.fromString('{"message":"unauthorized"}', 401);
    }
    return ResponseBody.fromString(
      jsonEncode({'ok': true}),
      200,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}

void main() {
  late Dio dio;
  late _FakeAdapter adapter;
  late FlutterSecureStorage storage;
  late int refreshFailedCalls;

  setUp(() {
    FlutterSecureStorage.setMockInitialValues({
      PrefsKeys.authRefreshToken: 'old-refresh-token',
    });
    storage = const FlutterSecureStorage();
    refreshFailedCalls = 0;
    adapter = _FakeAdapter();
    dio = Dio(BaseOptions(baseUrl: 'https://example.test'))
      ..httpClientAdapter = adapter;
    dio.interceptors.add(
      TokenRefreshInterceptor(
        dio: dio,
        secureStorage: storage,
        onRefreshFailed: () async {
          refreshFailedCalls++;
        },
      ),
    );
  });

  test('refreshes the token and retries once on a 401, then succeeds', () async {
    final response = await dio.get<Map<String, dynamic>>(
      '/protected',
      options: Options(headers: {'X-Auth-Token': 'old-token'}),
    );

    expect(response.statusCode, 200);
    expect(response.data, {'ok': true});
    expect(adapter.refreshCallCount, 1);
    expect(adapter.protectedCallCount, 2);
    expect(adapter.protectedHeadersSeen.first['X-Auth-Token'], ['old-token']);
    expect(adapter.protectedHeadersSeen.last['X-Auth-Token'], ['new-token']);
    expect(refreshFailedCalls, 0);
    expect(await storage.read(key: PrefsKeys.authToken), 'new-token');
    expect(await storage.read(key: PrefsKeys.authRefreshToken), 'new-refresh-token');
  });

  test('concurrent 401s share a single refresh call', () async {
    final results = await Future.wait([
      dio.get<Map<String, dynamic>>(
        '/protected',
        options: Options(headers: {'X-Auth-Token': 'old-token'}),
      ),
      dio.get<Map<String, dynamic>>(
        '/protected',
        options: Options(headers: {'X-Auth-Token': 'old-token'}),
      ),
    ]);

    expect(results.every((r) => r.statusCode == 200), isTrue);
    expect(adapter.refreshCallCount, 1);
    expect(refreshFailedCalls, 0);
  });

  test('calls onRefreshFailed and leaves the error as-is when there is no refresh token',
      () async {
    FlutterSecureStorage.setMockInitialValues({});

    try {
      await dio.get<Map<String, dynamic>>(
        '/protected',
        options: Options(headers: {'X-Auth-Token': 'old-token'}),
      );
      fail('expected a DioException');
    } on DioException catch (e) {
      expect(e.response?.statusCode, 401);
    }

    expect(refreshFailedCalls, 1);
    expect(adapter.refreshCallCount, 0);
  });

  test('leaves unauthenticated requests (no X-Auth-Token) alone on 401', () async {
    try {
      await dio.get<Map<String, dynamic>>('/protected');
      fail('expected a DioException');
    } on DioException catch (e) {
      expect(e.response?.statusCode, 401);
    }

    expect(adapter.refreshCallCount, 0);
    expect(refreshFailedCalls, 0);
  });
}
