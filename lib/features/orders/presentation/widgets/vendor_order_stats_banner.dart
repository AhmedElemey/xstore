import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/utils/extensions/context_extensions.dart';

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
    final fill = Color.lerp(context.surfaceColor, AppColors.primary, 0.9)!;
    const onFill = Colors.white;
    final muted = Colors.white.withValues(alpha: 0.75);
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: fill,
        borderRadius: BorderRadius.circular(AppSpacing.xl),
      ),
      child: Column(
        children: [
          Row(
            children: [
              _item(
                context,
                '$pendingCount',
                context.l10n.vendorStatPendingOrders,
                valueColor: AppColors.warning,
                labelColor: AppColors.warning,
              ),
              _divider(muted),
              _item(
                context,
                '$activeCount',
                context.l10n.vendorStatActiveOrders,
                valueColor: onFill,
                labelColor: muted,
              ),
              _divider(muted),
              _item(
                context,
                '$totalCount',
                context.l10n.vendorStatTotalOrders,
                valueColor: onFill,
                labelColor: muted,
              ),
              _divider(muted),
              _item(
                context,
                context.formatCurrency(totalRevenue),
                context.l10n.vendorStatRevenue,
                valueColor: onFill,
                labelColor: muted,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Divider(color: muted.withValues(alpha: 0.35), height: 1),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              _chip(
                context,
                label: context.l10n.vendorConfirmAllPending,
                onTap: onConfirmAllPending,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _item(
    BuildContext context,
    String value,
    String label, {
    String? suffix,
    Color? valueColor,
    Color? labelColor,
  }) {
    final valueFg = valueColor ?? context.textPrimary;
    final labelFg = labelColor ?? context.textSecondary;
    return Expanded(
      child: Column(
        children: [
          RichText(
            text: TextSpan(
              text: value,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: valueFg,
                fontWeight: FontWeight.w800,
              ),
              children: [
                if (suffix != null)
                  TextSpan(
                    text: ' $suffix',
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: valueFg.withValues(alpha: 0.9),
                    ),
                  ),
              ],
            ),
          ),
          Text(
            label,
            textAlign: TextAlign.center,
            style: Theme.of(
              context,
            ).textTheme.labelSmall?.copyWith(color: labelFg),
          ),
        ],
      ),
    );
  }

  Widget _divider(Color color) => Container(
    width: 1,
    height: AppSpacing.x3l,
    color: color.withValues(alpha: 0.35),
  );

  Widget _chip(
    BuildContext context, {
    required String label,
    required VoidCallback onTap,
  }) {
    return OutlinedButton(
      onPressed: onTap,
      style: OutlinedButton.styleFrom(
        side: const BorderSide(color: Colors.white),
        foregroundColor: Colors.white,
      ),
      child: Text(
        label,
        style: AppTypography.bodySmall.copyWith(fontWeight: FontWeight.w600),
      ),
    );
  }
}
