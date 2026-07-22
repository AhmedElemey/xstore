import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../constants/prefs_keys.dart';

/// Prompts for notification permission when needed (iOS / Android 13+).
/// Returns true when [getToken] is worth attempting for backend registration.
/// Denied or undetermined permission is logged and treated as a no-op, not an error.
Future<bool> requestFcmNotificationPermission() async {
  try {
    final settings = await FirebaseMessaging.instance.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );
    switch (settings.authorizationStatus) {
      case AuthorizationStatus.authorized:
      case AuthorizationStatus.provisional:
        return true;
      case AuthorizationStatus.denied:
      case AuthorizationStatus.notDetermined:
        if (kDebugMode) {
          debugPrint(
            'FCM: notification permission not granted '
            '(${settings.authorizationStatus}), skipping registration',
          );
        }
        return false;
    }
  } catch (e) {
    if (kDebugMode) {
      debugPrint('FCM: notification permission request failed: $e');
    }
    return false;
  }
}

/// Fetches the current FCM device token, persists it locally, and logs it in
/// debug builds. Called on app open (bootstrap) and before backend registration.
/// Returns the token when available, or null (simulator / permission denied).
Future<String?> refreshAndStoreFcmToken() async {
  try {
    final token = await FirebaseMessaging.instance.getToken();
    if (token == null) return null;
    await const FlutterSecureStorage()
        .write(key: PrefsKeys.fcmToken, value: token);
    if (kDebugMode) debugPrint('FCM token (saved locally): $token');
    return token;
  } catch (e) {
    // iOS simulators have no APNs — a missing token must never break
    // startup or login.
    if (kDebugMode) debugPrint('FCM token unavailable: $e');
    return null;
  }
}
