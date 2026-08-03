import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../router/app_router.dart';
import '../router/app_routes.dart';
import '../../features/auth/presentation/providers/auth_provider.dart';
import '../../features/notifications/presentation/providers/notifications_provider.dart';
import '../../features/notifications/presentation/providers/pending_push_route_provider.dart';
import 'fcm_message_route.dart';

Future<void> navigateToPushRoute(
  Ref ref,
  String route, {
  bool deferUntilAuthenticated = false,
}) async {
  if (!isSafeInAppRoute(route)) return;

  if (deferUntilAuthenticated) {
    ref.read(pendingPushRouteProvider.notifier).stage(route);
    return;
  }

  final auth = ref.read(authProvider);
  if (auth.isLoading) {
    try {
      await ref.read(authProvider.future);
    } catch (_) {
      ref.read(pendingPushRouteProvider.notifier).stage(route);
      return;
    }
  }

  if (ref.read(authProvider).valueOrNull == null) {
    ref.read(pendingPushRouteProvider.notifier).stage(route);
    return;
  }

  ref.read(goRouterProvider).go(route);
  _refreshInboxIfNeeded(ref, route);
}

void flushPendingPushRoute(Ref ref) {
  final route = ref.read(pendingPushRouteProvider.notifier).consume();
  if (route == null) return;
  final router = ref.read(goRouterProvider);
  if (!isSafeInAppRoute(route)) return;
  router.go(route);
  _refreshInboxIfNeeded(ref, route);
}

void _refreshInboxIfNeeded(Ref ref, String route) {
  if (route == AppRoutes.notifications ||
      route.startsWith('${AppRoutes.orderDetail}/')) {
    ref.read(notificationsProvider.notifier).fetchNotifications();
  }
}
