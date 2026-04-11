import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../shared/widgets/notification_bell_button.dart';
import '../../../../shared/widgets/notification_icon_badge.dart';
import '../../../../core/utils/extensions/context_extensions.dart';

class HomeHeader extends ConsumerWidget {
  const HomeHeader({
    super.key,
    required this.onSearchTap,
    this.onCartTap,
    this.cartItemCount = 0,
  });

  final VoidCallback onSearchTap;
  final VoidCallback? onCartTap;
  final int cartItemCount;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SafeArea(
      bottom: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.lg,
          AppSpacing.sm,
          AppSpacing.lg,
          AppSpacing.md,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Text(
                  context.l10n.appName,
                  style: AppTypography.titleLarge.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const Spacer(),
                if (onCartTap != null)
                  IconButton(
                    onPressed: onCartTap,
                    icon: NotificationIconBadge(
                      count: cartItemCount,
                      child: Icon(
                        LucideIcons.shoppingCart,
                        color: context.textPrimary,
                      ),
                    ),
                  ),
                NotificationBellButton(
                  icon: LucideIcons.bellDot,
                  tooltip: context.l10n.notifications,
                ),
              ],
            ),
            const Gap(AppSpacing.md),
            Material(
              color: context.surfaceColor,
              borderRadius: BorderRadius.circular(AppSpacing.md),
              child: InkWell(
                onTap: onSearchTap,
                borderRadius: BorderRadius.circular(AppSpacing.md),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.lg,
                    vertical: AppSpacing.md,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(AppSpacing.md),
                    border: Border.all(color: context.textDisabled),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        LucideIcons.search,
                        color: context.textSecondary,
                        size: AppSpacing.x2l,
                      ),
                      const Gap(AppSpacing.md),
                      Expanded(
                        child: Text(
                          context.l10n.searchHint,
                          style: AppTypography.bodyMedium.copyWith(
                            color: context.textSecondary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const Gap(AppSpacing.md),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _TrustChip(
                    label: context.l10n.freeShippingBadge,
                  ),
                  const Gap(AppSpacing.sm),
                  _TrustChip(
                    label: context.l10n.securePayBadge,
                  ),
                  const Gap(AppSpacing.sm),
                  _TrustChip(
                    label: context.l10n.easyReturnsBadge,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TrustChip extends StatelessWidget {
  const _TrustChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: context.surfaceColor,
        borderRadius: BorderRadius.circular(AppSpacing.x3l),
        border: Border.all(color: context.textDisabled),
      ),
      child: Text(
        label,
        style: AppTypography.labelSmall.copyWith(color: context.textSecondary),
      ),
    );
  }
}
