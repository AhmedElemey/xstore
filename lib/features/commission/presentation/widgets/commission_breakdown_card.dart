import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/extensions/context_extensions.dart';
import '../../domain/entities/commission_breakdown.dart';

class CommissionBreakdownCard extends StatelessWidget {
  const CommissionBreakdownCard({
    super.key,
    required this.breakdown,
    required this.currencyCode,
  });

  final CommissionBreakdown breakdown;
  final String currencyCode;

  @override
  Widget build(BuildContext context) {
    final earnColor = context.isDark ? AppColors.successLight : AppColors.success;
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: context.scaledPx(14),
        vertical: context.scaledPx(12),
      ),
      decoration: BoxDecoration(
        color: context.surfaceVariantColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _row(
            context,
            label: context.l10n.commissionYouEarn,
            value:
                _money(context, breakdown.vendorEarns),
            valueColor: earnColor,
            bold: true,
          ),
          const SizedBox(height: 6),
          _row(
            context,
            label: context.l10n.commissionPlatformFee,
            value: _money(context, breakdown.feeAmount),
            valueColor: context.textSecondary,
          ),
        ],
      ),
    );
  }

  /// Fee amounts keep their piastres (unlike `formatCurrency`, which rounds
  /// to whole pounds), in Arabic-Indic digits when the app is Arabic.
  String _money(BuildContext context, double amount) => context.isArabic
      ? '${NumberFormat('#,##0.00', 'ar_EG').format(amount)} ج.م'
      : '$currencyCode ${amount.toStringAsFixed(2)}';

  Widget _row(
    BuildContext context, {
    required String label,
    required String value,
    required Color valueColor,
    bool bold = false,
  }) {
    final base = Theme.of(context).textTheme.bodyMedium;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: base?.copyWith(color: context.textSecondary)),
        Text(
          value,
          style: base?.copyWith(
            color: valueColor,
            fontWeight: bold ? FontWeight.w700 : FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
