import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../core/router/app_routes.dart';
import '../../features/notifications/presentation/providers/notifications_provider.dart';
import '../utils/require_login.dart';
import 'notification_icon_badge.dart';
import '../../core/utils/extensions/context_extensions.dart';

/// Bell + unread badge; count comes only from [notificationsProvider].
class NotificationBellButton extends ConsumerWidget {
  const NotificationBellButton({
    super.key,
    this.icon = LucideIcons.bellDot,
    this.color,
    this.tooltip,
  });

  final IconData icon;
  final Color? color;
  final String? tooltip;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final count = ref.watch(notificationsProvider.select((s) => s.unreadCount));
    return IconButton(
      tooltip: tooltip,
      onPressed: () {
        if (!requireLogin(context, ref)) return;
        context.push(AppRoutes.notifications);
      },
      icon: NotificationIconBadge(
        count: count,
        child: Icon(icon, color: color ?? context.textPrimary),
      ),
    );
  }
}
