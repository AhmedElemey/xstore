import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/utils/extensions/context_extensions.dart';
import '../../../../shared/widgets/app_snackbar.dart';
import '../../domain/entities/notification_entity.dart';
import '../providers/notifications_provider.dart';
import '../providers/notifications_state.dart';
import '../widgets/notification_unread_summary_banner.dart';
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
    // The backend only returns role=ALL, so the inbox always shows All.
    // Fetch on every open: notificationsProvider is keepAlive, so a previous
    // session's list would otherwise sit stale until the user pulled to refresh.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final notifier = ref.read(notificationsProvider.notifier);
      notifier.applyFilter(NotificationFilter.all);
      unawaited(notifier.fetchNotifications());
    });
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
    AppSnackbar.show(
      context,
      message: context.l10n.notificationsDeletedSnack(e.title),
      action: SnackBarAction(
        label: context.l10n.notificationsUndo,
        onPressed: () =>
            ref.read(notificationsProvider.notifier).cancelDeleteUndo(e),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final n = ref.read(notificationsProvider.notifier);
    final unreadCount = ref.watch(
      notificationsProvider.select((s) => s.unreadCount),
    );
    return Scaffold(
      backgroundColor: context.backgroundColor,
      appBar: AppBar(
        backgroundColor: context.backgroundColor,
        surfaceTintColor: AppColors.transparent,
        centerTitle: true,
        title: Text(
          context.l10n.notifications,
          style: AppTypography.titleMedium.copyWith(
            fontWeight: FontWeight.w700,
            color: context.textPrimary,
          ),
        ),
        actions: [
          if (unreadCount > 0)
            TextButton(
              onPressed: n.markAllRead,
              child: Text(context.l10n.notificationsMarkAllRead, style: AppTypography.labelLarge.copyWith(color: AppColors.primary)),
            ),
        ],
      ),
      body: RefreshIndicator(
        color: AppColors.primary,
        onRefresh: n.refreshNotifications,
        child: CustomScrollView(
          controller: _scroll,
          cacheExtent: 800,
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            const SliverToBoxAdapter(child: NotificationUnreadSummaryBanner()),
            ...NotificationsFeedSlivers.build(context: context, ref: ref, onDelete: _delete),
          ],
        ),
      ),
    );
  }
}
