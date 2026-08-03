import 'package:firebase_messaging/firebase_messaging.dart';

import 'fcm_background_handler.dart';
import 'fcm_local_notifications.dart';

/// Platform FCM setup that must run once during [bootstrap].
Future<void> configureFirebaseCloudMessaging() async {
  registerFcmBackgroundMessageHandler();

  await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
    alert: true,
    badge: true,
    sound: true,
  );

  await initFcmLocalNotifications();
}
