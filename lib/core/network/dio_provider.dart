import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../features/auth/presentation/providers/auth_provider.dart';
import '../../features/listing/presentation/providers/listing_dependencies.dart';
import '../../features/profile/presentation/providers/profile_provider.dart';
import '../../features/store/presentation/providers/store_hours_provider.dart';
import '../constants/prefs_keys.dart';
import '../utils/app_location_cache.dart';
import 'api_auth_headers.dart';
import 'api_endpoints.dart';
import 'logging_interceptor.dart';
import 'server_error_provider.dart';
import 'token_refresh_interceptor.dart';

part 'dio_provider.g.dart';

/// Clears a session that the backend no longer recognizes (failed token
/// refresh, or get-profile 404 "user not found" for the stored token) and
/// forces the app back to a logged-out state — mirrors the manual logout
/// cleanup in `Auth.logout()` minus the remote logout call, which is
/// pointless for a session the backend already doesn't know about.
Future<void> _clearInvalidSession(
  Ref ref,
  FlutterSecureStorage secureStorage,
) async {
  await secureStorage.delete(key: PrefsKeys.authToken);
  await secureStorage.delete(key: PrefsKeys.authRefreshToken);
  await secureStorage.delete(key: PrefsKeys.authUser);
  resetProfileData(ref);
  resetListingLocalCache(ref);
  resetStoreHoursData(ref);
  ref.invalidate(authProvider);
}

@Riverpod(keepAlive: true)
Dio dio(DioRef ref) {
  const secureStorage = FlutterSecureStorage();
  final client = Dio(
    BaseOptions(
      baseUrl: ApiEndpoints.baseUrl,
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 20),
      // Without this an upload that stalls mid-send (flaky mobile data)
      // hangs until the OS gives up instead of failing fast.
      sendTimeout: const Duration(seconds: 20),
      // CONFIRMED against a live backend: the static Basic license key is
      // required on EVERY request (public and authenticated alike) — it is
      // NOT replaced by per-user auth. Set once here instead of per-call.
      headers: {
        'Accept': 'application/json',
        'Authorization': ApiAuthHeaders.basicLicenseKey,
      },
    ),
  );

  client.interceptors.add(
    InterceptorsWrapper(
      // CONFIRMED: per-user auth is a SEPARATE `X-Auth-Token: <token>`
      // header, not `Authorization: Bearer <token>` — Authorization is
      // always the static Basic key above. Added automatically whenever a
      // token is stored; harmless to send on endpoints that don't need it.
      onRequest: (options, handler) async {
        final token = await secureStorage.read(key: PrefsKeys.authToken);
        if (token != null && token.isNotEmpty) {
          options.headers['X-Auth-Token'] = token;
          if (kDebugMode) {
            debugPrint(
              '── request header (${options.method} ${options.path}) ──',
            );
            debugPrint('X-Auth-Token: ${options.headers['X-Auth-Token']}');
          }
        }
        // CONFIRMED (live probe, 2026-08-14): listing reads 400 without
        // these. Best-known device fix, falling back to Cairo — see
        // AppLocationCache.
        options.headers['X-Latitude'] = AppLocationCache.latitude.toString();
        options.headers['X-Longitude'] = AppLocationCache.longitude.toString();
        handler.next(options);
      },
    ),
  );

  // Refreshes the access token and retries once on a 401 from an
  // authenticated request; only clears the session if the refresh itself
  // fails (invalid/expired refresh token, no session to refresh, etc).
  client.interceptors.add(
    TokenRefreshInterceptor(
      dio: client,
      secureStorage: secureStorage,
      onRefreshFailed: () => _clearInvalidSession(ref, secureStorage),
    ),
  );

  // Flags any 5xx response so the router can swap the current screen for a
  // full-page server-error screen instead of the failing screen's own inline
  // error UI. Errors still propagate to `handler.next` so existing
  // per-call `mapDioException` handling is unaffected.
  //
  // Also treats a 404 "user not found" from get-profile as an invalid
  // session: restoreSession() trusts the locally-cached user without ever
  // validating it against the backend, so a token for a deleted/foreign-
  // environment account otherwise keeps getting resent on every request
  // forever, 404ing silently with no way back to a clean logged-out state.
  client.interceptors.add(
    InterceptorsWrapper(
      onError: (error, handler) async {
        final code = error.response?.statusCode;
        if (code != null && code >= 500) {
          ref.read(serverErrorProvider.notifier).trigger();
        }
        if (code == 404 &&
            error.requestOptions.path == ApiEndpoints.getProfile &&
            error.requestOptions.headers.containsKey('X-Auth-Token')) {
          await _clearInvalidSession(ref, secureStorage);
        }
        handler.next(error);
      },
    ),
  );

  if (kDebugMode) {
    client.interceptors.add(LoggingInterceptor());
  }

  ref.onDispose(client.close);
  return client;
}
