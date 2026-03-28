import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';

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
        gradient: LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [
            AppColors.primary.withValues(alpha: 0.10),
            AppColors.secondary.withValues(alpha: 0.08),
            AppColors.surface,
          ],
        ),
        borderRadius: BorderRadius.circular(AppSpacing.md),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm,
          vertical: AppSpacing.md,
        ),
        child: Row(
          children: [
            Expanded(
              child: _MiniStat(
                icon: Icons.inventory_2_outlined,
                value: totalCount,
                label: 'Total Listings',
                valueColor: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            Expanded(
              child: _MiniStat(
                icon: Icons.check_circle_outline,
                value: activeCount,
                label: 'Active',
                valueColor: const Color(0xFF16A34A),
              ),
            ),
            Expanded(
              child: _MiniStat(
                icon: Icons.local_shipping_outlined,
                value: soldCount,
                label: 'Sold',
                valueColor: const Color(0xFF2563EB),
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
        const Gap(AppSpacing.xs),
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
