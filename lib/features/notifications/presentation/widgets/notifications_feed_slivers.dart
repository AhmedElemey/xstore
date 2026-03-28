import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_typography.dart';
import '../../domain/entities/notification_entity.dart';
import '../providers/notifications_provider.dart';
import '../providers/notifications_state.dart';
import 'notification_action_bar.dart';
import 'notification_empty_state.dart';
import 'notification_group_header.dart';
import 'notification_tile.dart';

/// Main feed: grouped sticky headers + tiles + footer (keeps [NotificationsScreen] small).
abstract final class NotificationsFeedSlivers {
  static List<Widget> build({
    required BuildContext context,
    required WidgetRef ref,
    required void Function(BuildContext context, NotificationEntity e) onDelete,
  }) {
    final s = ref.watch(notificationsProvider);
    final n = ref.read(notificationsProvider.notifier);
    if (s.isLoading) {
      return const [
        SliverFillRemaining(child: Center(child: CircularProgressIndicator.adaptive())),
      ];
    }
    if (s.error != null) {
      return [
        SliverFillRemaining(
          child: Center(
            child: Text(s.error!, style: AppTypography.bodyMedium.copyWith(color: AppColors.error)),
          ),
        ),
      ];
    }
    if (s.filteredNotifications.isEmpty) {
      return [
        SliverFillRemaining(
          child: NotificationEmptyState(isAllFilter: s.selectedFilter == NotificationFilter.all),
        ),
      ];
    }
    return [
      for (final g in s.groups)
        SliverMainAxisGroup(
          slivers: [
            SliverPersistentHeader(
              pinned: true,
              delegate: NotificationGroupHeaderDelegate(g.label),
            ),
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, i) {
                  final e = g.notifications[i];
                  return NotificationTile(
                    entity: e,
                    markAllReadAnimating: s.markAllReadAnimating,
                    onTap: () {
                      n.markAsRead(e.id);
                      final r = e.actionRoute;
                      if (r != null && r.isNotEmpty) context.push(r);
                    },
                    onDeleteConfirmed: () => onDelete(context, e),
                    onSwipeMarkRead: () => n.markAsRead(e.id),
                    onMarkUnread: () => n.markAsUnread(e.id),
                  );
                },
                childCount: g.notifications.length,
              ),
            ),
          ],
        ),
      const SliverToBoxAdapter(child: NotificationActionBar()),
    ];
  }
}
