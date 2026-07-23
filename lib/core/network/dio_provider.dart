import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../features/auth/presentation/providers/auth_provider.dart';
import '../../features/profile/presentation/providers/profile_provider.dart';
import '../constants/prefs_keys.dart';
import 'api_auth_headers.dart';
import 'api_endpoints.dart';
import 'logging_interceptor.dart';
import 'token_refresh_interceptor.dart';

part 'dio_provider.g.dart';

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
      onRefreshFailed: () async {
        await secureStorage.delete(key: PrefsKeys.authToken);
        await secureStorage.delete(key: PrefsKeys.authRefreshToken);
        await secureStorage.delete(key: PrefsKeys.authUser);
        resetProfileData(ref);
        ref.invalidate(authProvider);
      },
    ),
  );

  if (kDebugMode) {
    client.interceptors.add(LoggingInterceptor());
  }

  ref.onDispose(client.close);
  return client;
}
