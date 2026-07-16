import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../constants/prefs_keys.dart';

/// Fetches the current FCM device token, persists it locally, and logs it in
/// debug builds. Called on app open (bootstrap) and after every login/session
/// adopt so the stored value tracks token rotations.
/// TODO(backend): also send the token to a device-registration endpoint once
/// one exists.
Future<void> refreshAndStoreFcmToken() async {
  try {
    final token = await FirebaseMessaging.instance.getToken();
    if (token == null) return;
    await const FlutterSecureStorage()
        .write(key: PrefsKeys.fcmToken, value: token);
    if (kDebugMode) debugPrint('FCM token (saved locally): $token');
  } catch (e) {
    // iOS simulators have no APNs — a missing token must never break
    // startup or login.
    if (kDebugMode) debugPrint('FCM token unavailable: $e');
  }
}
