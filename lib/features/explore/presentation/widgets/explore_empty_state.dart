import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/constants/app_typography.dart';

class ExploreEmptyState extends StatelessWidget {
  const ExploreEmptyState({
    super.key,
    required this.onPickCategory,
  });

  final ValueChanged<String> onPickCategory;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.x2l),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              LucideIcons.searchX,
              size: AppSpacing.x3l * 2,
              color: AppColors.textDisabled,
            ),
            const Gap(AppSpacing.lg),
            Text(
              AppStrings.noResultsTitle,
              style: AppTypography.titleMedium,
              textAlign: TextAlign.center,
            ),
            const Gap(AppSpacing.sm),
            Text(
              AppStrings.noResultsSubtitle,
              style: AppTypography.bodyMedium.copyWith(color: AppColors.textSecondary),
              textAlign: TextAlign.center,
            ),
            const Gap(AppSpacing.x2l),
            Wrap(
              spacing: AppSpacing.sm,
              alignment: WrapAlignment.center,
              children: [
                ActionChip(
                  label: Text(AppStrings.mensFashion),
                  onPressed: () => onPickCategory(AppStrings.categoryQueryMens),
                ),
                ActionChip(
                  label: Text(AppStrings.womensFashion),
                  onPressed: () => onPickCategory(AppStrings.categoryQueryWomens),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
