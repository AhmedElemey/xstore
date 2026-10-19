import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

import '../router/app_routes.dart';
import 'fcm_local_notifications.dart';
import 'fcm_message_route.dart';

/// Registers the FCM background isolate handler. Call once before [runApp].
void registerFcmBackgroundMessageHandler() {
  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
}

/// Handles data-only / silent work when the app is backgrounded or terminated.
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  WidgetsFlutterBinding.ensureInitialized();
  if (Firebase.apps.isEmpty) {
    // Native google-services / GoogleService-Info match the built flavor.
    await Firebase.initializeApp();
  }
  if (kDebugMode) {
    debugPrint(
      'FCM background message: ${message.messageId} data=${message.data}',
    );
  }

  // A `notification` payload is already shown by the OS. Data-only FCM
  // is silent unless we raise a local notification in this isolate.
  if (message.notification != null) return;

  final title = message.data['title']?.toString() ?? 'xStore';
  final body = message.data['body']?.toString() ??
      message.data['message']?.toString() ??
      '';
  await showFcmLocalNotification(
    title: title,
    body: body,
    payloadRoute: routeFromRemoteMessage(message) ?? AppRoutes.notifications,
  );
}
