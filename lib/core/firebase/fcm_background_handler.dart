import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';

/// Registers the FCM background isolate handler. Call once before [runApp].
void registerFcmBackgroundMessageHandler() {
  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
}

/// Handles data-only / silent work when the app is backgrounded or terminated.
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  if (Firebase.apps.isEmpty) {
    // Native google-services / GoogleService-Info match the built flavor.
    await Firebase.initializeApp();
  }
  if (kDebugMode) {
    debugPrint(
      'FCM background message: ${message.messageId} data=${message.data}',
    );
  }
}
