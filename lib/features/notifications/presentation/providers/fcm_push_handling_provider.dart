import 'dart:async';
import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
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

  // Tray push is not guaranteed (data-only FCM, iOS simulator, denied
  // permission). Refresh the inbox/badge when the app is foregrounded again.
  final observer = _InboxResumeObserver(() {
    if (ref.read(authProvider).valueOrNull == null) return;
    unawaited(ref.read(notificationsProvider.notifier).fetchNotifications());
  });
  WidgetsBinding.instance.addObserver(observer);

  ref.onDispose(() {
    WidgetsBinding.instance.removeObserver(observer);
    for (final sub in subscriptions) {
      unawaited(sub.cancel());
    }
  });
}

class _InboxResumeObserver extends WidgetsBindingObserver {
  _InboxResumeObserver(this._onResume);

  final VoidCallback _onResume;

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) _onResume();
  }
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
    unawaited(ref.read(notificationsProvider.notifier).fetchNotifications());
  }

  final notification = message.notification;
  // iOS already banners a `notification` payload via presentation options.
  // Android never shows FCM in the foreground; data-only payloads show
  // nothing on either platform unless we raise a local notification.
  final osWillPresent = !Platform.isAndroid && notification != null;
  if (osWillPresent) return;

  final route = routeFromRemoteMessage(message) ?? AppRoutes.notifications;
  final title = notification?.title ??
      message.data['title']?.toString() ??
      'xStore';
  final body = notification?.body ??
      message.data['body']?.toString() ??
      message.data['message']?.toString() ??
      '';
  await showFcmLocalNotification(
    title: title,
    body: body,
    payloadRoute: route,
  );
}
