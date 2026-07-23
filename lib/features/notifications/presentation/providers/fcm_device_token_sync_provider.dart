import 'dart:async';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/constants/prefs_keys.dart';
import '../../../../core/firebase/fcm_token.dart';
import '../../../auth/domain/entities/user_entity.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import 'notifications_dependencies.dart';

part 'fcm_device_token_sync_provider.g.dart';

/// Fire-and-forget: fetch/persist the FCM token and register it with the
/// backend when a session exists. Mirrors [prefetchProfileData] — pass
/// [user] from inside `Auth.build()` while auth is still Loading.
void syncFcmDeviceTokenWithBackend(Ref ref, {UserEntity? user}) {
  unawaited(_syncFcmDeviceTokenWithBackend(ref, user: user));
}

Future<void> _syncFcmDeviceTokenWithBackend(
  Ref ref, {
  UserEntity? user,
}) async {
  // When [user] is omitted, defer the auth read so callers inside
  // Auth.build() don't hit Riverpod's self-dependency assert.
  final sessionUser = user ??
      await Future(() => ref.read(authProvider).valueOrNull);
  if (sessionUser == null) return;

  if (!await requestFcmNotificationPermission()) return;

  final token = await refreshAndStoreFcmToken();
  if (token == null) return;

  await _registerTokenWithBackend(ref, token);
}

Future<void> _persistFcmToken(String token) async {
  await const FlutterSecureStorage()
      .write(key: PrefsKeys.fcmToken, value: token);
}

Future<void> _registerTokenWithBackend(Ref ref, String token) async {
  final result =
      await ref.read(notificationsRepositoryProvider).registerDeviceToken(token);
  result.fold(
    (failure) {
      if (kDebugMode) {
        debugPrint('FCM device token registration failed: $failure');
      }
    },
    (_) {
      if (kDebugMode) debugPrint('FCM device token registered with backend');
    },
  );
}

/// Best-effort backend deregister + local token clear on logout.
/// Must run while the session token is still valid (before auth storage delete).
void unregisterFcmDeviceTokenOnLogout(Ref ref) {
  unawaited(_unregisterFcmDeviceTokenOnLogout(ref));
}

Future<void> _unregisterFcmDeviceTokenOnLogout(Ref ref) async {
  final token =
      await const FlutterSecureStorage().read(key: PrefsKeys.fcmToken);
  if (token == null || token.isEmpty) return;

  final result = await ref
      .read(notificationsRepositoryProvider)
      .unregisterDeviceToken(token);
  result.fold(
    (failure) {
      if (kDebugMode) {
        debugPrint('FCM device token unregister failed: $failure');
      }
    },
    (_) {
      if (kDebugMode) debugPrint('FCM device token unregistered from backend');
    },
  );
  await const FlutterSecureStorage().delete(key: PrefsKeys.fcmToken);
}

/// Subscribes to [FirebaseMessaging.onTokenRefresh] for the app lifetime.
@Riverpod(keepAlive: true)
void fcmDeviceTokenSync(FcmDeviceTokenSyncRef ref) {
  final subscription = FirebaseMessaging.instance.onTokenRefresh.listen(
    (token) => unawaited(_onTokenRefresh(ref, token)),
  );
  ref.onDispose(subscription.cancel);
}

Future<void> _onTokenRefresh(Ref ref, String token) async {
  await _persistFcmToken(token);
  if (ref.read(authProvider).valueOrNull == null) return;
  await _registerTokenWithBackend(ref, token);
}
