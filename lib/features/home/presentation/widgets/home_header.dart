import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/constants/app_typography.dart';

class HomeHeader extends StatelessWidget {
  const HomeHeader({
    super.key,
    required this.onSearchTap,
    this.onNotificationsTap,
  });

  final VoidCallback onSearchTap;
  final VoidCallback? onNotificationsTap;

  @override
  Widget build(BuildContext context) {
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
                  AppStrings.appName,
                  style: AppTypography.titleLarge.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const Spacer(),
                IconButton(
                  onPressed: onNotificationsTap,
                  icon: Icon(
                    LucideIcons.bellDot,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
            const Gap(AppSpacing.md),
            Material(
              color: AppColors.cardBg,
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
                    border: Border.all(color: AppColors.textDisabled),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        LucideIcons.search,
                        color: AppColors.textSecondary,
                        size: AppSpacing.x2l,
                      ),
                      const Gap(AppSpacing.md),
                      Expanded(
                        child: Text(
                          AppStrings.searchHint,
                          style: AppTypography.bodyMedium.copyWith(
                            color: AppColors.textSecondary,
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
                    label: AppStrings.freeShippingBadge,
                  ),
                  const Gap(AppSpacing.sm),
                  _TrustChip(
                    label: AppStrings.securePayBadge,
                  ),
                  const Gap(AppSpacing.sm),
                  _TrustChip(
                    label: AppStrings.easyReturnsBadge,
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
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(AppSpacing.x3l),
        border: Border.all(color: AppColors.textDisabled),
      ),
      child: Text(
        label,
        style: AppTypography.labelSmall.copyWith(color: AppColors.textSecondary),
      ),
    );
  }
}
