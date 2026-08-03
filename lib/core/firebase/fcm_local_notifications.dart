import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

/// Android channel for transactional FCM (order updates, inbox alerts).
const fcmDefaultAndroidChannelId = 'xstore_transactional';

final FlutterLocalNotificationsPlugin _localNotifications =
    FlutterLocalNotificationsPlugin();

void Function(String route)? _onNotificationTap;

/// Route staged when the app is cold-launched by tapping a local
/// notification — `onDidReceiveNotificationResponse` is never invoked for
/// that launch, so [initFcmLocalNotifications] captures it separately via
/// [FlutterLocalNotificationsPlugin.getNotificationAppLaunchDetails].
String? _pendingLaunchRoute;

/// Wires tap callbacks before [initFcmLocalNotifications].
void bindFcmLocalNotificationTapHandler(void Function(String route) onTap) {
  _onNotificationTap = onTap;
}

/// Consumes (and clears) the route captured from a cold-start tap, if any.
String? consumePendingLocalNotificationLaunchRoute() {
  final route = _pendingLaunchRoute;
  _pendingLaunchRoute = null;
  return route;
}

Future<void> initFcmLocalNotifications() async {
  if (!Platform.isAndroid) return;

  const androidInit = AndroidInitializationSettings('@drawable/ic_stat_notify');
  const initSettings = InitializationSettings(android: androidInit);

  await _localNotifications.initialize(
    initSettings,
    onDidReceiveNotificationResponse: (details) {
      final payload = details.payload?.trim();
      if (payload == null || payload.isEmpty) return;
      _onNotificationTap?.call(payload);
    },
  );

  final launchDetails =
      await _localNotifications.getNotificationAppLaunchDetails();
  if (launchDetails?.didNotificationLaunchApp ?? false) {
    final payload =
        launchDetails?.notificationResponse?.payload?.trim();
    if (payload != null && payload.isNotEmpty) {
      _pendingLaunchRoute = payload;
    }
  }

  const channel = AndroidNotificationChannel(
    fcmDefaultAndroidChannelId,
    'Order & account updates',
    description: 'Order status, messages, and important xStore alerts',
    importance: Importance.high,
  );

  await _localNotifications
      .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(channel);
}

Future<void> showAndroidForegroundFcmNotification({
  required String title,
  required String body,
  required String payloadRoute,
}) async {
  if (!Platform.isAndroid) return;
  if (title.isEmpty && body.isEmpty) return;

  const details = AndroidNotificationDetails(
    fcmDefaultAndroidChannelId,
    'Order & account updates',
    channelDescription: 'Order status, messages, and important xStore alerts',
    importance: Importance.high,
    priority: Priority.high,
  );

  try {
    await _localNotifications.show(
      DateTime.now().millisecondsSinceEpoch.remainder(1 << 31),
      title.isEmpty ? 'xStore' : title,
      body,
      const NotificationDetails(android: details),
      payload: payloadRoute,
    );
  } catch (e) {
    if (kDebugMode) {
      debugPrint('FCM local notification failed: $e');
    }
  }
}
