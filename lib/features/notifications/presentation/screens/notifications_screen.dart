import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/router/app_routes.dart';
import '../../domain/entities/notification_entity.dart';
import '../providers/notifications_provider.dart';
import '../widgets/notification_filter_tabs.dart';
import '../widgets/notifications_feed_slivers.dart';

class NotificationsScreen extends ConsumerStatefulWidget {
  const NotificationsScreen({super.key});

  @override
  ConsumerState<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends ConsumerState<NotificationsScreen> {
  final _scroll = ScrollController();

  @override
  void initState() {
    super.initState();
    _scroll.addListener(_onScroll);
  }

  void _onScroll() {
    if (!_scroll.hasClients) return;
    final p = _scroll.position;
    if (p.pixels > p.maxScrollExtent - 120) {
      ref.read(notificationsProvider.notifier).loadMore();
    }
  }

  @override
  void dispose() {
    _scroll.removeListener(_onScroll);
    _scroll.dispose();
    super.dispose();
  }

  void _delete(BuildContext context, NotificationEntity e) {
    ref.read(notificationsProvider.notifier).onDeleteConfirmed(e);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(AppStrings.notificationsDeletedSnack(e.title)),
        action: SnackBarAction(
          label: AppStrings.notificationsUndo,
          onPressed: () => ref.read(notificationsProvider.notifier).cancelDeleteUndo(e),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final s = ref.watch(notificationsProvider);
    final n = ref.read(notificationsProvider.notifier);
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        surfaceTintColor: AppColors.transparent,
        centerTitle: true,
        title: Text(AppStrings.notifications, style: AppTypography.titleMedium.copyWith(fontWeight: FontWeight.w700)),
        actions: [
          if (s.unreadCount > 0)
            TextButton(
              onPressed: n.markAllRead,
              child: Text(AppStrings.notificationsMarkAllRead, style: AppTypography.labelLarge.copyWith(color: AppColors.primary)),
            ),
          IconButton(
            icon: const Icon(LucideIcons.settings),
            onPressed: () => context.push(AppRoutes.notificationSettings),
            tooltip: AppStrings.notificationSettingsTitle,
          ),
        ],
      ),
      body: RefreshIndicator(
        color: AppColors.primary,
        onRefresh: n.refreshNotifications,
        child: CustomScrollView(
          controller: _scroll,
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            const SliverToBoxAdapter(child: NotificationFilterTabs()),
            const SliverToBoxAdapter(child: NotificationUnreadSummaryBanner()),
            ...NotificationsFeedSlivers.build(context: context, ref: ref, onDelete: _delete),
          ],
        ),
      ),
    );
  }
}
