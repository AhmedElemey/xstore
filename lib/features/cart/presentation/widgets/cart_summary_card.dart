import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_typography.dart';
import '../providers/cart_provider.dart';
import '../../../../core/utils/extensions/context_extensions.dart';

class CartSummaryCard extends ConsumerWidget {
  const CartSummaryCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final summary = ref.watch(
      cartProvider.select(
        (c) => (
          selectedAvailableCount: c.selectedAvailableItems.length,
          subtotal: c.subtotal,
          shippingTotal: c.shippingTotal,
          total: c.total,
        ),
      ),
    );
    final n = summary.selectedAvailableCount;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: context.glassColor,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: context.borderColor),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              context.l10n.cartOrderSummary,
              style: AppTypography.headlineSmall.copyWith(
                fontSize: 16,
                color: context.textPrimary,
              ),
            ),
            Divider(height: AppSpacing.x2l, color: context.borderColor),
            _row(
              context,
              context.l10n.cartSubtotalLine(n),
              context.formatCurrency(summary.subtotal),
            ),
            const SizedBox(height: AppSpacing.sm),
            _row(
              context,
              context.l10n.cartShippingLine,
              context.formatCurrency(summary.shippingTotal),
            ),
            Divider(height: AppSpacing.x2l, color: context.borderColor),
            _row(
              context,
              context.l10n.cartTotalLine,
              context.formatCurrency(summary.total),
              emphasize: true,
            ),
          ],
        ),
      ),
    );
  }

  Widget _row(
    BuildContext context,
    String label,
    String value, {
    bool emphasize = false,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.baseline,
      textBaseline: TextBaseline.alphabetic,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            label,
            style: emphasize
                ? AppTypography.titleMedium.copyWith(
                    fontWeight: FontWeight.w800,
                  )
                : AppTypography.bodyMedium.copyWith(
                    color: context.textSecondary,
                  ),
          ),
        ),
        Text(
          value,
          style: AppTypography.mono.copyWith(
            fontSize: emphasize ? 20 : 14,
            fontWeight: emphasize ? FontWeight.w700 : FontWeight.w500,
            color: emphasize ? context.amberColor : context.textPrimary,
          ),
        ),
      ],
    );
  }
}
