import 'package:flutter/material.dart';

import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/utils/extensions/context_extensions.dart';
import '../../../../shared/widgets/orbit_widgets.dart';
import '../../domain/entities/order_entity.dart';
import 'order_status_badge.dart';

/// Orbit seller stat tiles (new / preparing / ready; tapping one filters the
/// list), then an app-only line with the totals and "confirm all pending".
class VendorOrderStatsBanner extends StatelessWidget {
  const VendorOrderStatsBanner({
    super.key,
    required this.pendingCount,
    required this.processingCount,
    required this.shippedCount,
    required this.totalCount,
    required this.totalRevenue,
    required this.onFilter,
    required this.onConfirmAllPending,
  });

  final int pendingCount;
  final int processingCount;
  final int shippedCount;
  final int totalCount;
  final double totalRevenue;
  final ValueChanged<OrderStatus> onFilter;
  final VoidCallback onConfirmAllPending;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              for (final (i, status, count) in [
                (0, OrderStatus.pending, pendingCount),
                (1, OrderStatus.processing, processingCount),
                (2, OrderStatus.shipped, shippedCount),
              ]) ...[
                if (i > 0) const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: _Tile(
                    count: count,
                    label: orderStatusLabel(context, status),
                    highlight: i == 0,
                    onTap: () => onFilter(status),
                  ),
                ),
              ],
            ],
          ),
          Row(
            children: [
              Expanded(
                child: Text(
                  '$totalCount ${context.l10n.vendorStatTotalOrders} · '
                  '${context.formatCurrency(totalRevenue)}',
                  style: AppTypography.bodySmall.copyWith(
                    color: context.textSecondary,
                  ),
                ),
              ),
              if (pendingCount > 0)
                TextButton(
                  onPressed: onConfirmAllPending,
                  style: TextButton.styleFrom(
                    foregroundColor: context.cashColor,
                  ),
                  child: Text(context.l10n.vendorConfirmAllPending),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Tile extends StatelessWidget {
  const _Tile({
    required this.count,
    required this.label,
    required this.highlight,
    required this.onTap,
  });

  final int count;
  final String label;
  final bool highlight;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final warm = context.cashColor;
    return GlassCard(
      radius: 18,
      onTap: onTap,
      padding: const EdgeInsets.all(AppSpacing.md),
      color: highlight ? warm.withValues(alpha: 0.12) : null,
      borderColor: highlight ? warm.withValues(alpha: 0.4) : null,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$count',
            style: AppTypography.titleLarge.copyWith(
              fontWeight: FontWeight.w800,
              color: highlight ? warm : context.textPrimary,
            ),
          ),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTypography.labelSmall.copyWith(
              color: context.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
