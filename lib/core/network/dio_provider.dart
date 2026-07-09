import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../features/auth/presentation/providers/auth_provider.dart';
import '../constants/prefs_keys.dart';
import 'api_endpoints.dart';

part 'dio_provider.g.dart';

@Riverpod(keepAlive: true)
Dio dio(DioRef ref) {
  const secureStorage = FlutterSecureStorage();
  final client = Dio(
    BaseOptions(
      baseUrl: ApiEndpoints.baseUrl,
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 20),
      headers: {'Accept': 'application/json'},
    ),
  );

  client.interceptors.add(
    InterceptorsWrapper(
      // Injects `Authorization: Bearer <token>` when signed in, UNLESS the
      // request already set an explicit Authorization header (e.g. the
      // static public-endpoint key from ApiAuthHeaders.public()) — public
      // calls must not be silently upgraded to Bearer just because a user
      // happens to be logged in. See core/network/api_auth_headers.dart.
      onRequest: (options, handler) async {
        if (!options.headers.containsKey('Authorization')) {
          final token = await secureStorage.read(key: PrefsKeys.authToken);
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }
        }
        handler.next(options);
      },
      onError: (error, handler) async {
        final code = error.response?.statusCode;
        if (code == 401) {
          await secureStorage.delete(key: PrefsKeys.authToken);
          await secureStorage.delete(key: PrefsKeys.authUser);
          ref.invalidate(authProvider);
        }
        handler.next(error);
      },
    ),
  );

  if (kDebugMode) {
    client.interceptors.add(
      PrettyDioLogger(
        requestHeader: true,
        requestBody: true,
        responseBody: true,
      ),
    );
  }

  ref.onDispose(client.close);
  return client;
}
