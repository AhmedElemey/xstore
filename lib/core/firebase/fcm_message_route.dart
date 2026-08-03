import 'package:firebase_messaging/firebase_messaging.dart';

import '../router/app_routes.dart';

/// Resolves a go_router location from FCM [data] / notification payload.
///
/// Backend contract (see docs_business/launch_todos/06_push_lifecycle.md):
/// `actionRoute`, `orderId`, optional `type`.
String? routeFromRemoteMessageData(Map<String, dynamic> data) {
  final actionRoute = _firstNonEmpty([
    data['actionRoute'],
    data['action_route'],
  ]);
  if (actionRoute != null && isSafeInAppRoute(actionRoute)) {
    return actionRoute;
  }

  final orderId = _firstNonEmpty([
    data['orderId'],
    data['order_id'],
  ]);
  if (orderId != null) {
    return AppRoutes.orderPath(orderId);
  }

  final type = _firstNonEmpty([data['type']])?.toLowerCase();
  if (type != null &&
      (type.contains('order') ||
          type.contains('message') ||
          type.contains('listing') ||
          type.contains('deal'))) {
    return AppRoutes.notifications;
  }

  if (data.isNotEmpty) {
    return AppRoutes.notifications;
  }

  return null;
}

String? routeFromRemoteMessage(RemoteMessage message) {
  final fromData = routeFromRemoteMessageData(message.data);
  if (fromData != null) return fromData;
  if (message.notification != null) {
    return AppRoutes.notifications;
  }
  return null;
}

/// Rejects payload-supplied routes that aren't a local go_router path —
/// guards against a compromised/malicious push payload driving in-app
/// navigation to an external URL.
bool isSafeInAppRoute(String route) {
  if (!route.startsWith('/')) return false;
  if (route.startsWith('//')) return false;
  if (route.contains('://')) return false;
  return true;
}

String? _firstNonEmpty(List<Object?> values) {
  for (final value in values) {
    if (value == null) continue;
    final text = value.toString().trim();
    if (text.isNotEmpty) return text;
  }
  return null;
}
