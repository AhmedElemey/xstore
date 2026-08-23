import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../constants/prefs_keys.dart';

/// iOS/macOS: [FirebaseMessaging.getToken] throws `apns-token-not-set` if
/// called before Apple has delivered the device token.
bool get _isApplePushPlatform {
  if (kIsWeb) return false;
  return defaultTargetPlatform == TargetPlatform.iOS ||
      defaultTargetPlatform == TargetPlatform.macOS;
}

/// Polls [getApnsToken] until it returns a non-empty value, or [maxAttempts]
/// is exhausted. Does not call FCM [getToken] — that is the caller's job.
@visibleForTesting
Future<String?> waitForApnsToken({
  required Future<String?> Function() getApnsToken,
  int maxAttempts = 10,
  Duration interval = const Duration(milliseconds: 300),
  Future<void> Function(Duration duration) delay = _sleep,
}) async {
  for (var attempt = 0; attempt < maxAttempts; attempt++) {
    final token = await getApnsToken();
    if (token != null && token.isNotEmpty) return token;
    if (attempt == maxAttempts - 1) break;
    await delay(interval);
  }
  return null;
}

Future<void> _sleep(Duration duration) => Future<void>.delayed(duration);

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
    if (_isApplePushPlatform) {
      final apns = await waitForApnsToken(
        getApnsToken: FirebaseMessaging.instance.getAPNSToken,
      );
      if (apns == null) {
        if (kDebugMode) {
          debugPrint(
            'FCM: APNS token not ready (simulator has none; on a device '
            'it usually arrives within a second). Skipping getToken.',
          );
        }
        return null;
      }
    }
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
