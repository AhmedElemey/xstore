import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/utils/extensions/context_extensions.dart';

class ListingStatsBanner extends StatelessWidget {
  const ListingStatsBanner({
    super.key,
    required this.totalCount,
    required this.activeCount,
    required this.soldCount,
  });

  final int totalCount;
  final int activeCount;
  final int soldCount;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: context.glassColor,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: context.borderColor),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.lg,
        ),
        child: Row(
          children: [
            Expanded(
              child: _MiniStat(
                icon: LucideIcons.boxes,
                value: totalCount,
                label: context.l10n.listingTotalListings,
                valueColor: context.textPrimary,
              ),
            ),
            Expanded(
              child: _MiniStat(
                icon: LucideIcons.checkCircle,
                value: activeCount,
                label: context.l10n.active,
                valueColor: AppColors.success,
              ),
            ),
            Expanded(
              child: _MiniStat(
                icon: LucideIcons.truck,
                value: soldCount,
                label: context.l10n.listingSoldStat,
                valueColor: context.linkColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MiniStat extends StatelessWidget {
  const _MiniStat({
    required this.icon,
    required this.value,
    required this.label,
    required this.valueColor,
  });

  final IconData icon;
  final int value;
  final String label;
  final Color valueColor;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 20, color: context.textSecondary),
        const Gap(AppSpacing.sm),
        Text(
          '$value',
          style: AppTypography.mono.copyWith(
            fontSize: 24,
            fontWeight: FontWeight.w700,
            color: valueColor,
          ),
        ),
        Text(
          label.toUpperCase(),
          textAlign: TextAlign.center,
          style: AppTypography.fieldLabel.copyWith(
            fontSize: 10,
            color: context.labelColor,
          ),
        ),
      ],
    );
  }
}
