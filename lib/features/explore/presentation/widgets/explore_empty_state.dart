import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/utils/extensions/context_extensions.dart';

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
              color: context.textDisabled,
            ),
            const Gap(AppSpacing.lg),
            Text(
              context.l10n.noResultsTitle,
              style: AppTypography.titleMedium,
              textAlign: TextAlign.center,
            ),
            const Gap(AppSpacing.sm),
            Text(
              context.l10n.noResultsSubtitle,
              style: AppTypography.bodyMedium.copyWith(color: context.textSecondary),
              textAlign: TextAlign.center,
            ),
            const Gap(AppSpacing.x2l),
            Wrap(
              spacing: AppSpacing.sm,
              alignment: WrapAlignment.center,
              children: [
                ActionChip(
                  label: Text(context.l10n.mensFashion),
                  onPressed: () => onPickCategory(context.l10n.categoryQueryMens),
                ),
                ActionChip(
                  label: Text(context.l10n.womensFashion),
                  onPressed: () => onPickCategory(context.l10n.categoryQueryWomens),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
