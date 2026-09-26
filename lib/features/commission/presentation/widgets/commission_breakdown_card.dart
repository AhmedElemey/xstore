import 'package:flutter/material.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../shared/widgets/orbit_widgets.dart';

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
    String money(double v) => '$currencyCode ${v.toStringAsFixed(2)}';
    return GlassCard(
      radius: 20,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            context.l10n.commissionEachSale.toUpperCase(),
            style: AppTypography.labelSmall.copyWith(
              fontWeight: FontWeight.w800,
              letterSpacing: 1.2,
              color: context.textSecondary,
            ),
          ),
          const SizedBox(height: 10),
          _row(
            context,
            label: context.l10n.commissionCustomerPays,
            value: money(breakdown.price),
            valueColor: context.textPrimary,
          ),
          const SizedBox(height: 6),
          _row(
            context,
            label: context.l10n.commissionPlatformFee,
            value: '− ${money(breakdown.feeAmount)}',
            valueColor: context.textSecondary,
          ),
          Divider(height: 20, color: context.borderColor),
          _row(
            context,
            label: context.l10n.commissionYouEarn,
            value: money(breakdown.vendorEarns),
            valueColor: context.cashColor,
            bold: true,
          ),
        ],
      ),
    );
  }

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
