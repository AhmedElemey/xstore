import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../auth/domain/entities/user_entity.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../providers/notifications_provider.dart';
import '../providers/notifications_state.dart';

class NotificationFilterTabs extends ConsumerWidget {
  const NotificationFilterTabs({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final role = ref.watch(authProvider).valueOrNull?.role ?? UserRole.consumer;
    final state = ref.watch(notificationsProvider);
    final n = ref.read(notificationsProvider.notifier);
    final isVendor = role == UserRole.vendor;
    final filters = isVendor
        ? NotificationFilter.values.where((f) => f != NotificationFilter.deals).toList()
        : NotificationFilter.values.where((f) => f != NotificationFilter.listings).toList();

    String label(NotificationFilter f) {
      switch (f) {
        case NotificationFilter.all:
          return AppStrings.notificationsFilterAll;
        case NotificationFilter.orders:
          return AppStrings.notificationsFilterOrders;
        case NotificationFilter.deals:
          return AppStrings.notificationsFilterDeals;
        case NotificationFilter.listings:
          return AppStrings.notificationsFilterListings;
        case NotificationFilter.messages:
          return AppStrings.notificationsFilterMessages;
        case NotificationFilter.system:
          return AppStrings.notificationsFilterSystem;
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
          final sel = state.selectedFilter == f;
          final unread = n.unreadInFilter(f);
          final base = label(f);
          return FilterChip(
            label: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  base,
                  style: AppTypography.labelLarge.copyWith(
                    color: sel ? AppColors.white : AppColors.textPrimary,
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
            backgroundColor: AppColors.cardBg,
            side: BorderSide(color: sel ? AppColors.primary : AppColors.textDisabled),
            onSelected: (_) => n.applyFilter(f),
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
          );
        },
      ),
    );
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
                      AppStrings.notificationsUnreadBannerLine(unread),
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

