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
    required this.onViewAnalytics,
  });

  final int pendingCount;
  final int activeCount;
  final int totalCount;
  final double totalRevenue;
  final VoidCallback onConfirmAllPending;
  final VoidCallback onViewAnalytics;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).colorScheme.onPrimary;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
             color:  AppColors.primary,

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
                valueColor: AppColors.warningLight,
                labelColor: AppColors.warningLight,
              ),
              _divider(text),
              _item(context, '$activeCount', context.l10n.vendorStatActiveOrders),
              _divider(text),
              _item(context, '$totalCount', context.l10n.vendorStatTotalOrders),
              _divider(text),
              _item(
                context,
                _fmt(totalRevenue),
                context.l10n.vendorStatRevenue,
                suffix: context.l10n.currencyDzd,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Divider(color: text.withValues(alpha: 0.2), height: 1),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              _chip(
                context,
                label: context.l10n.vendorConfirmAllPending,
                onTap: onConfirmAllPending,
              ),
              const SizedBox(width: AppSpacing.sm),
              _chip(
                context,
                label: context.l10n.vendorViewAnalytics,
                onTap: onViewAnalytics,
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
    final text = Theme.of(context).colorScheme.onPrimary;
    return Expanded(
      child: Column(
        children: [
          RichText(
            text: TextSpan(
              text: value,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: valueColor ?? text,
                    fontWeight: FontWeight.w800,
                  ),
              children: [
                if (suffix != null)
                  TextSpan(
                    text: ' $suffix',
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: (valueColor ?? text).withValues(alpha: 0.9),
                        ),
                  ),
              ],
            ),
          ),
          Text(
            label,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: labelColor ?? text.withValues(alpha: 0.9),
                ),
          ),
        ],
      ),
    );
  }

  Widget _divider(Color color) => Container(
        width: 1,
        height: AppSpacing.x3l,
        color: color.withValues(alpha: 0.2),
      );

  Widget _chip(
    BuildContext context, {
    required String label,
    required VoidCallback onTap,
  }) {
    return OutlinedButton(
      onPressed: onTap,
      style: OutlinedButton.styleFrom(
        side: BorderSide(color: Theme.of(context).colorScheme.onPrimary.withValues(alpha: 0.7)),
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
      ),
      child: Text(
        label,
        style: AppTypography.bodySmall.copyWith(fontWeight: FontWeight.w600),
      ),
    );
  }

  String _fmt(double value) => value == value.roundToDouble()
      ? value.toStringAsFixed(0)
      : value.toStringAsFixed(1);
}
