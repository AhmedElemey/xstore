import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../constants/prefs_keys.dart';
import 'api_endpoints.dart';

/// On a 401 from an authenticated request, refreshes the access token and
/// retries the request once. Concurrent 401s that arrive while a refresh is
/// already in flight await that same refresh instead of each firing their
/// own (a "single-flight" refresh, avoiding a thundering herd of refresh
/// calls when several requests race each other and all come back
/// unauthorized around the same time).
///
/// Requests that never carried the per-user `X-Auth-Token` header (public
/// endpoints, or a login attempt that legitimately failed) are left alone —
/// only a session that *was* authenticated and got rejected is worth
/// refreshing.
class TokenRefreshInterceptor extends Interceptor {
  TokenRefreshInterceptor({
    required Dio dio,
    required FlutterSecureStorage secureStorage,
    required Future<void> Function() onRefreshFailed,
  })  : _dio = dio,
        _secureStorage = secureStorage,
        _onRefreshFailed = onRefreshFailed;

  final Dio _dio;
  final FlutterSecureStorage _secureStorage;
  final Future<void> Function() _onRefreshFailed;

  static const _retriedKey = '_token_refresh_retried';

  Future<String?>? _refreshing;

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    final options = err.requestOptions;
    final wasAuthenticated = options.headers.containsKey('X-Auth-Token');
    final alreadyRetried = options.extra[_retriedKey] == true;
    final isRefreshCall = options.path == ApiEndpoints.refreshToken;

    if (err.response?.statusCode != 401 ||
        !wasAuthenticated ||
        alreadyRetried ||
        isRefreshCall) {
      return handler.next(err);
    }

    final newToken = await _refreshToken();
    if (newToken == null) {
      await _onRefreshFailed();
      return handler.next(err);
    }

    try {
      options.extra[_retriedKey] = true;
      options.headers['X-Auth-Token'] = newToken;
      final retried = await _dio.fetch(options);
      return handler.resolve(retried);
    } on DioException catch (e) {
      return handler.next(e);
    }
  }

  /// Coalesces concurrent refresh attempts into a single in-flight call.
  Future<String?> _refreshToken() {
    return _refreshing ??= _performRefresh().whenComplete(() {
      _refreshing = null;
    });
  }

  Future<String?> _performRefresh() async {
    final refreshToken = await _secureStorage.read(key: PrefsKeys.authRefreshToken);
    if (refreshToken == null || refreshToken.isEmpty) return null;

    try {
      final response = await _dio.post<Map<String, dynamic>>(
        ApiEndpoints.refreshToken,
        data: {'token': refreshToken},
      );
      final data = response.data;
      final newToken = data?['token'] as String?;
      if (newToken == null || newToken.isEmpty) return null;

      await _secureStorage.write(key: PrefsKeys.authToken, value: newToken);
      final newRefreshToken = data?['refreshToken'] as String?;
      if (newRefreshToken != null && newRefreshToken.isNotEmpty) {
        await _secureStorage.write(
          key: PrefsKeys.authRefreshToken,
          value: newRefreshToken,
        );
      }
      return newToken;
    } catch (_) {
      return null;
    }
  }
}
