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

  Future<_RefreshOutcome>? _refreshing;

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

    final outcome = await _refreshToken();
    if (outcome.token == null) {
      // Only clear the session when the refresh was AUTHORITATIVELY rejected
      // (no refresh token, or the endpoint said the token is bad). A
      // transport error / 5xx / hung read is transient — keep the session so
      // the next request can retry instead of force-logging the user out.
      if (outcome.sessionInvalid) {
        await _onRefreshFailed();
      }
      return handler.next(err);
    }

    try {
      options.extra[_retriedKey] = true;
      options.headers['X-Auth-Token'] = outcome.token;
      final retried = await _dio.fetch(options);
      return handler.resolve(retried);
    } on DioException catch (e) {
      return handler.next(e);
    }
  }

  /// Coalesces concurrent refresh attempts into a single in-flight call.
  Future<_RefreshOutcome> _refreshToken() {
    return _refreshing ??= _performRefresh().whenComplete(() {
      _refreshing = null;
    });
  }

  Future<_RefreshOutcome> _performRefresh() async {
    String? refreshToken;
    try {
      // Same hung-native-read guard as dio_provider.dart's onRequest — a
      // stuck secure-storage read here must not block every retried
      // request forever. A failed read is transient, not proof the session
      // is dead, so don't invalidate on it.
      refreshToken = await _secureStorage
          .read(key: PrefsKeys.authRefreshToken)
          .timeout(const Duration(seconds: 5));
    } catch (_) {
      return const _RefreshOutcome.transient();
    }
    // Nothing to refresh with — the 401 is terminal, sign the user out.
    if (refreshToken == null || refreshToken.isEmpty) {
      return const _RefreshOutcome.invalid();
    }

    try {
      final response = await _dio.post<Map<String, dynamic>>(
        ApiEndpoints.refreshToken,
        data: {'token': refreshToken},
      );
      final data = response.data;
      final newToken = data?['token'] as String?;
      // 2xx but no usable token: treat as transient (malformed response),
      // don't force a logout on a server that answered "OK".
      if (newToken == null || newToken.isEmpty) {
        return const _RefreshOutcome.transient();
      }

      await _secureStorage.write(key: PrefsKeys.authToken, value: newToken);
      final newRefreshToken = data?['refreshToken'] as String?;
      if (newRefreshToken != null && newRefreshToken.isNotEmpty) {
        await _secureStorage.write(
          key: PrefsKeys.authRefreshToken,
          value: newRefreshToken,
        );
      }
      return _RefreshOutcome.refreshed(newToken);
    } on DioException catch (e) {
      // The refresh endpoint rejecting the refresh token (400/401) is
      // authoritative: the session is dead. Anything else (5xx, timeout,
      // no connectivity) is transient — keep the session.
      final status = e.response?.statusCode;
      if (status == 401 || status == 400) {
        return const _RefreshOutcome.invalid();
      }
      return const _RefreshOutcome.transient();
    } catch (_) {
      return const _RefreshOutcome.transient();
    }
  }
}

/// Result of a refresh attempt. [sessionInvalid] is true only when the
/// session should be cleared (authoritative rejection), never for a
/// transient network/server failure.
class _RefreshOutcome {
  const _RefreshOutcome.refreshed(this.token) : sessionInvalid = false;
  const _RefreshOutcome.invalid()
      : token = null,
        sessionInvalid = true;
  const _RefreshOutcome.transient()
      : token = null,
        sessionInvalid = false;

  final String? token;
  final bool sessionInvalid;
}
