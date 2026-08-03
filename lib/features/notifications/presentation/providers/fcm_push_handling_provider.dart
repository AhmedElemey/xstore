import 'dart:async';
import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/firebase/fcm_local_notifications.dart';
import '../../../../core/firebase/fcm_message_route.dart';
import '../../../../core/firebase/fcm_push_navigation.dart';
import '../../../../core/router/app_routes.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import 'notifications_provider.dart';

part 'fcm_push_handling_provider.g.dart';

/// Foreground display, tap routing, and inbox refresh for FCM.
@Riverpod(keepAlive: true)
void fcmPushHandling(FcmPushHandlingRef ref) {
  bindFcmLocalNotificationTapHandler((route) {
    unawaited(navigateToPushRoute(ref, route));
  });

  ref.listen(authProvider, (previous, next) {
    if (next.isLoading) return;
    if (next.valueOrNull != null) {
      Future.microtask(() => flushPendingPushRoute(ref));
    }
  });

  final subscriptions = <StreamSubscription<dynamic>>[];

  subscriptions.add(
    FirebaseMessaging.onMessage.listen((message) {
      unawaited(_onForegroundMessage(ref, message));
    }),
  );

  subscriptions.add(
    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      _openFromMessage(ref, message);
    }),
  );

  unawaited(_handleInitialMessage(ref));
  _handlePendingLocalNotificationLaunch(ref);

  ref.onDispose(() {
    for (final sub in subscriptions) {
      unawaited(sub.cancel());
    }
  });
}

Future<void> _handleInitialMessage(Ref ref) async {
  final message = await FirebaseMessaging.instance.getInitialMessage();
  if (message == null) return;
  _openFromMessage(ref, message, deferUntilAuthenticated: true);
}

/// Android cold-launch-by-tap: `onDidReceiveNotificationResponse` never
/// fires for the launch itself, so pick up the route captured at
/// [initFcmLocalNotifications] time instead.
void _handlePendingLocalNotificationLaunch(Ref ref) {
  final route = consumePendingLocalNotificationLaunchRoute();
  if (route == null) return;
  unawaited(
    navigateToPushRoute(ref, route, deferUntilAuthenticated: true),
  );
}

void _openFromMessage(
  Ref ref,
  RemoteMessage message, {
  bool deferUntilAuthenticated = false,
}) {
  final route = routeFromRemoteMessage(message);
  if (route == null) return;
  unawaited(
    navigateToPushRoute(
      ref,
      route,
      deferUntilAuthenticated: deferUntilAuthenticated,
    ),
  );
}

Future<void> _onForegroundMessage(Ref ref, RemoteMessage message) async {
  if (kDebugMode) {
    debugPrint('FCM foreground message: ${message.messageId}');
  }

  if (ref.read(authProvider).valueOrNull != null) {
    ref.read(notificationsProvider.notifier).fetchNotifications();
  }

  if (Platform.isAndroid) {
    final notification = message.notification;
    final route =
        routeFromRemoteMessage(message) ?? AppRoutes.notifications;
    final title = notification?.title ??
        message.data['title']?.toString() ??
        'xStore';
    final body = notification?.body ?? message.data['body']?.toString() ?? '';
    await showAndroidForegroundFcmNotification(
      title: title,
      body: body,
      payloadRoute: route,
    );
  }
}
