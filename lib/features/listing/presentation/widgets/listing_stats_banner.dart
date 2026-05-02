import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
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
    final colors = context.isDark
        ? <Color>[
            AppColors.darkSurfaceVariant,
            AppColors.darkSurfaceElevated,
          ]
        : <Color>[
            AppColors.notificationUnreadBackground,
            AppColors.lightSurface,
          ];

    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: colors,
        ),
        borderRadius: BorderRadius.circular(AppSpacing.lg),
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
                valueColor: Theme.of(context).colorScheme.onSurface,
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
                valueColor: AppColors.primary,
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
    final grey = Theme.of(context).colorScheme.onSurfaceVariant;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 22, color: grey.withValues(alpha: 0.85)),
        const Gap(AppSpacing.sm),
        Text(
          '$value',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w800,
                color: valueColor,
              ),
        ),
        Text(
          label,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: grey,
                fontWeight: FontWeight.w500,
              ),
        ),
      ],
    );
  }
}
