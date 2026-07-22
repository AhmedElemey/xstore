import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_typography.dart';
import '../providers/notifications_provider.dart';
import '../../../../core/utils/extensions/context_extensions.dart';

class NotificationFilterTabs extends ConsumerWidget {
  const NotificationFilterTabs({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Commented out — backend only supports role=ALL currently (see
    // notifications_remote_datasource.dart _roleParam). Re-enable once
    // backend implements per-role filtering.
    /*
    final role = ref.watch(
      authProvider.select((a) => a.valueOrNull?.role ?? UserRole.consumer),
    );
    final selectedFilter = ref.watch(
      notificationsProvider.select((s) => s.selectedFilter),
    );
    final n = ref.read(notificationsProvider.notifier);
    final isVendor = role == UserRole.vendor;
    final filters = isVendor
        ? NotificationFilter.values.where((f) => f != NotificationFilter.deals).toList()
        : NotificationFilter.values.where((f) => f != NotificationFilter.listings).toList();

    String label(NotificationFilter f) {
      switch (f) {
        case NotificationFilter.all:
          return context.l10n.notificationsFilterAll;
        case NotificationFilter.orders:
          return context.l10n.notificationsFilterOrders;
        case NotificationFilter.deals:
          return context.l10n.notificationsFilterDeals;
        case NotificationFilter.listings:
          return context.l10n.notificationsFilterListings;
        case NotificationFilter.messages:
          return context.l10n.notificationsFilterMessages;
        case NotificationFilter.system:
          return context.l10n.notificationsFilterSystem;
      }
    }

    return SizedBox(
      height: AppSpacing.x3l + AppSpacing.sm,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
        itemCount: filters.length,
        separatorBuilder: (_, __) => const SizedBox(width: AppSpacing.sm),
        itemBuilder: (context, i) {
          final f = filters[i];
          final sel = selectedFilter == f;
          final unread = n.unreadInFilter(f);
          final base = label(f);
          return FilterChip(
            label: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  base,
                  style: AppTypography.labelLarge.copyWith(
                    color: sel ? AppColors.white : context.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (unread > 0) ...[
                  const SizedBox(width: AppSpacing.xs),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.xs,
                      vertical: AppSpacing.xs / 2,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.error,
                      borderRadius: BorderRadius.circular(AppSpacing.x3l),
                    ),
                    child: Text(
                      '$unread',
                      style: AppTypography.labelSmall.copyWith(
                        color: AppColors.white,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ],
            ),
            selected: sel,
            showCheckmark: false,
            selectedColor: AppColors.primary,
            backgroundColor: context.surfaceColor,
            side: BorderSide(color: sel ? AppColors.primary : context.textDisabled),
            onSelected: (_) => n.applyFilter(f),
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
          );
        },
      ),
    );
    */
    return const SizedBox.shrink();
  }
}

class NotificationUnreadSummaryBanner extends ConsumerWidget {
  const NotificationUnreadSummaryBanner({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final unread = ref.watch(notificationsProvider.select((s) => s.unreadCount));
    return AnimatedSlide(
      duration: const Duration(milliseconds: 320),
      curve: Curves.easeOutCubic,
      offset: unread > 0 ? Offset.zero : const Offset(0, -0.2),
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 280),
        opacity: unread > 0 ? 1 : 0,
        child: unread <= 0
            ? const SizedBox.shrink()
            : Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.lg,
                  0,
                  AppSpacing.lg,
                  AppSpacing.sm,
                ),
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: AppColors.notificationBannerBackground,
                    borderRadius: BorderRadius.circular(AppSpacing.md),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.lg,
                      vertical: AppSpacing.md,
                    ),
                    child: Text(
                      context.l10n.notificationsUnreadBannerLine(unread),
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
      ),
    );
  }
}

