import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/utils/extensions/context_extensions.dart';

/// Orbit glass summary: mono counts (revenue in amber) over a Confirm-all
/// action that keeps the success treatment.
class VendorOrderStatsBanner extends StatelessWidget {
  const VendorOrderStatsBanner({
    super.key,
    required this.pendingCount,
    required this.activeCount,
    required this.totalCount,
    required this.totalRevenue,
    required this.onConfirmAllPending,
  });

  final int pendingCount;
  final int activeCount;
  final int totalCount;
  final double totalRevenue;
  final VoidCallback onConfirmAllPending;

  @override
  Widget build(BuildContext context) {
    final success = context.isDark ? AppColors.successLight : AppColors.success;
    return Container(
      margin: const EdgeInsetsDirectional.symmetric(horizontal: AppSpacing.xl),
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: context.glassColor,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: context.borderColor),
      ),
      child: Column(
        children: [
          Row(
            children: [
              _item(
                context,
                '$pendingCount',
                context.l10n.vendorStatPendingOrders,
                valueColor: context.isDark
                    ? AppColors.warning
                    : Color.lerp(AppColors.warning, AppColors.black, 0.35),
              ),
              _divider(context),
              _item(
                context,
                '$activeCount',
                context.l10n.vendorStatActiveOrders,
              ),
              _divider(context),
              _item(context, '$totalCount', context.l10n.vendorStatTotalOrders),
              _divider(context),
              _item(
                context,
                context.formatCurrency(totalRevenue),
                context.l10n.vendorStatRevenue,
                valueColor: context.amberColor,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: onConfirmAllPending,
              style: OutlinedButton.styleFrom(
                foregroundColor: success,
                side: BorderSide(color: success.withValues(alpha: 0.6)),
              ),
              child: Text(
                context.l10n.vendorConfirmAllPending,
                style: AppTypography.bodySmall.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _item(
    BuildContext context,
    String value,
    String label, {
    Color? valueColor,
  }) {
    return Expanded(
      child: Column(
        children: [
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              value,
              maxLines: 1,
              style: AppTypography.mono.copyWith(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: valueColor ?? context.textPrimary,
              ),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            textAlign: TextAlign.center,
            style: AppTypography.labelSmall.copyWith(color: context.labelColor),
          ),
        ],
      ),
    );
  }

  Widget _divider(BuildContext context) =>
      Container(width: 1, height: AppSpacing.x3l, color: context.borderColor);
}
