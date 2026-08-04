import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_typography.dart';
import '../providers/notifications_provider.dart';
import '../providers/notifications_state.dart';
import '../../../../core/utils/extensions/context_extensions.dart';
import '../../../../shared/widgets/pulsing_animation_builder.dart';
import '../../../../shared/widgets/xstore_button.dart';

class NotificationEmptyState extends ConsumerWidget {
  const NotificationEmptyState({super.key, required this.isAllFilter});

  final bool isAllFilter;

  String _filterName(BuildContext context, NotificationFilter f) {
    switch (f) {
      case NotificationFilter.all:
        return context.l10n.notificationsFilterAll.toLowerCase();
      case NotificationFilter.orders:
        return context.l10n.notificationsFilterOrders.toLowerCase();
      case NotificationFilter.deals:
        return context.l10n.notificationsFilterDeals.toLowerCase();
      case NotificationFilter.listings:
        return context.l10n.notificationsFilterListings.toLowerCase();
      case NotificationFilter.messages:
        return context.l10n.notificationsFilterMessages.toLowerCase();
      case NotificationFilter.system:
        return context.l10n.notificationsFilterSystem.toLowerCase();
    }
  }

  String _scope(NotificationFilter f) {
    switch (f) {
      case NotificationFilter.orders:
        return 'orders';
      case NotificationFilter.deals:
        return 'deals';
      case NotificationFilter.listings:
        return 'listings';
      case NotificationFilter.messages:
        return 'messages';
      case NotificationFilter.system:
        return 'system';
      default:
        return '';
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filter = ref.watch(notificationsProvider.select((s) => s.selectedFilter));
    final n = ref.read(notificationsProvider.notifier);
    final all = isAllFilter;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.x3l),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (all)
              PulsingAnimationBuilder(
                duration: const Duration(seconds: 2),
                builder: (context, animation, child) => RotationTransition(
                  turns: Tween<double>(begin: -0.04, end: 0.04).animate(
                    CurvedAnimation(parent: animation, curve: Curves.easeInOut),
                  ),
                  child: child,
                ),
                child: Icon(LucideIcons.bell, size: AppSpacing.x3l * 2, color: AppColors.primary.withValues(alpha: 0.35)),
              )
            else
              Icon(LucideIcons.bellOff, size: AppSpacing.x3l * 2, color: context.textDisabled),
            SizedBox(height: AppSpacing.x2l),
            Text(
              all
                  ? context.l10n.notificationsEmptyAllTitle
                  : context.l10n.notificationsEmptyFilterTitle(_filterName(context, filter)),
              textAlign: TextAlign.center,
              style: AppTypography.titleMedium.copyWith(fontWeight: FontWeight.w700, color: context.textPrimary),
            ),
            SizedBox(height: AppSpacing.sm),
            Text(
              all
                  ? context.l10n.notificationsEmptyFilterSubtitle(
                      context.l10n.notificationsFilterAll.toLowerCase(),
                    )
                  : context.l10n.notificationsEmptyFilterSubtitle(_scope(filter)),
              textAlign: TextAlign.center,
              style: AppTypography.bodyMedium.copyWith(color: context.textSecondary),
            ),
            if (!all) ...[
              SizedBox(height: AppSpacing.x2l),
              XstoreButton(
                label: context.l10n.notificationsShowAll,
                onPressed: () => n.applyFilter(NotificationFilter.all),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
