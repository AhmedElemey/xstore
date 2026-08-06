import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../../core/constants/prefs_keys.dart';
import '../../../core/network/delivery_api_endpoints.dart';
import '../../auth/domain/entities/user_entity.dart';
import '../../auth/presentation/providers/auth_provider.dart';

/// Delivery-backend is a separate service with its own JWT (see
/// delivery-backend's README) — it has no real identity provider yet, only a
/// dev-only phone login that auto-provisions a matching consumer/vendor
/// identity. This bridges the app's REAL xStoreEcommerce session into a
/// delivery-backend token, silently, so package-request calls (Flow B) have
/// a Bearer token without a second real login. Courier/admin never bridge —
/// they use their own delivery-backend accounts directly (courier login is
/// its own, separate mock/demo flow — see courier-delivery-pilot).
///
/// Fire-and-forget: mirrors [syncFcmDeviceTokenWithBackend] — pass [user]
/// from inside `Auth.build()` while auth is still Loading (reading
/// `authProvider` there throws a self-dependency error).
void syncDeliveryBackendSession(Ref ref, {UserEntity? user}) {
  unawaited(_syncDeliveryBackendSession(ref, user: user));
}

Future<void> _syncDeliveryBackendSession(Ref ref, {UserEntity? user}) async {
  final sessionUser =
      user ?? await Future(() => ref.read(authProvider).valueOrNull);
  if (sessionUser == null) return;
  if (sessionUser.role != UserRole.consumer &&
      sessionUser.role != UserRole.vendor) {
    return;
  }
  await bridgeLoginToDeliveryBackend(
    phoneNumber: sessionUser.phoneNumber,
    name: sessionUser.name,
    role: sessionUser.role,
  );
}

/// Best-effort — a failure here only means delivery-backend calls will 401
/// later (surfaced per-call as a normal error), never blocks the main
/// xStoreEcommerce auth flow. Also used by [deliveryDioProvider]'s 401 retry,
/// since delivery-backend has no refresh-token endpoint — re-login IS the
/// refresh mechanism.
Future<void> bridgeLoginToDeliveryBackend({
  required String phoneNumber,
  required String name,
  required UserRole role,
}) async {
  try {
    final dio = Dio(
      BaseOptions(
        baseUrl: DeliveryApiEndpoints.baseUrl,
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
      ),
    );
    final response = await dio.post<Map<String, dynamic>>(
      DeliveryApiEndpoints.login,
      data: {'phoneNumber': phoneNumber, 'name': name, 'role': role.name},
    );
    final token = response.data?['token'] as String?;
    if (token == null || token.isEmpty) return;
    await const FlutterSecureStorage()
        .write(key: PrefsKeys.deliveryAuthToken, value: token);
    if (kDebugMode) debugPrint('Delivery-backend session bridged');
  } catch (e) {
    if (kDebugMode) debugPrint('Delivery-backend session bridge failed: $e');
  }
}

Future<void> clearDeliveryBackendSession() async {
  await const FlutterSecureStorage().delete(key: PrefsKeys.deliveryAuthToken);
}
