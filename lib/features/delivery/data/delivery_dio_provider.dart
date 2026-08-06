import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/constants/prefs_keys.dart';
import '../../../core/network/delivery_api_endpoints.dart';
import '../../auth/presentation/providers/auth_provider.dart';
import 'delivery_backend_session.dart';

part 'delivery_dio_provider.g.dart';

/// Dio client for the standalone delivery-backend service. Separate from
/// [dioProvider]: different host, and `Authorization: Bearer <token>` auth
/// (delivery-backend's own JWT — see [bridgeLoginToDeliveryBackend]) instead
/// of the marketplace's `X-Auth-Token` + Basic-license scheme.
@Riverpod(keepAlive: true)
Dio deliveryDio(DeliveryDioRef ref) {
  const secureStorage = FlutterSecureStorage();
  final client = Dio(
    BaseOptions(
      baseUrl: DeliveryApiEndpoints.baseUrl,
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 20),
      headers: {'Accept': 'application/json'},
    ),
  );

  client.interceptors.add(
    InterceptorsWrapper(
      onRequest: (options, handler) async {
        final token =
            await secureStorage.read(key: PrefsKeys.deliveryAuthToken);
        if (token != null && token.isNotEmpty) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        handler.next(options);
      },
      // delivery-backend has no refresh-token endpoint — re-running the
      // bridge login IS the refresh mechanism. Retry once per request.
      onError: (error, handler) async {
        final alreadyRetried =
            error.requestOptions.extra['deliveryRetried'] == true;
        if (error.response?.statusCode != 401 || alreadyRetried) {
          handler.next(error);
          return;
        }
        final user = ref.read(authProvider).valueOrNull;
        if (user == null) {
          handler.next(error);
          return;
        }
        await bridgeLoginToDeliveryBackend(
          phoneNumber: user.phoneNumber,
          name: user.name,
          role: user.role,
        );
        final token =
            await secureStorage.read(key: PrefsKeys.deliveryAuthToken);
        if (token == null || token.isEmpty) {
          handler.next(error);
          return;
        }
        try {
          final retryOptions = error.requestOptions
            ..headers['Authorization'] = 'Bearer $token'
            ..extra['deliveryRetried'] = true;
          handler.resolve(await client.fetch(retryOptions));
        } catch (_) {
          handler.next(error);
        }
      },
    ),
  );

  ref.onDispose(client.close);
  return client;
}
