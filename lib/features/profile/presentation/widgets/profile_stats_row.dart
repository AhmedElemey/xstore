import 'package:flutter/material.dart';

import 'package:gap/gap.dart';

import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/utils/extensions/context_extensions.dart';
import '../../../../shared/widgets/orbit_widgets.dart';

/// Seller stats on the profile: sales, rating and response rate.
class ProfileStatsRow extends StatelessWidget {
  const ProfileStatsRow({
    super.key,
    this.sales,
    this.rating,
    this.responsePercent,
    this.onSalesTap,
  });

  final int? sales;
  final double? rating;
  final int? responsePercent;
  final VoidCallback? onSalesTap;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
      child: Row(
        children: [
          Expanded(
            child: _StatCell(
              value: '${sales ?? 0}',
              label: context.l10n.statSales,
              onTap: onSalesTap,
            ),
          ),
          const _VertDivider(),
          Expanded(
            child: _StatCell(
              value: '${rating?.toStringAsFixed(1) ?? '0.0'} ★',
              label: context.l10n.statRating,
            ),
          ),
          const _VertDivider(),
          Expanded(
            child: _StatCell(
              value: '${responsePercent ?? 0}%',
              label: context.l10n.statResponse,
            ),
          ),
        ],
      ),
    );
  }
}

class _VertDivider extends StatelessWidget {
  const _VertDivider();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: 40,
      color: context.borderColor,
    );
  }
}

class _StatCell extends StatelessWidget {
  const _StatCell({
    required this.value,
    required this.label,
    this.onTap,
  });

  final String value;
  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
        child: Column(
          children: [
            Text(
              value,
              style: AppTypography.titleMedium.copyWith(
                color: context.primaryColor,
                fontWeight: FontWeight.w700,
              ),
            ),
            const Gap(AppSpacing.xs),
            Text(
              label,
              style: AppTypography.bodySmall.copyWith(
                color: context.textSecondary,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
            ),
          ],
        ),
      ),
    );
  }
}
