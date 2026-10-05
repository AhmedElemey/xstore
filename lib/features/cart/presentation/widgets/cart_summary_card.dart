import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_colors.dart';
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

    return Material(
      color: context.surfaceColor,
      borderRadius: BorderRadius.circular(AppSpacing.lg),
      elevation: 1,
      shadowColor: context.textPrimary.withValues(alpha: 0.06),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              context.l10n.cartOrderSummary,
              style: AppTypography.titleMedium.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            Divider(height: AppSpacing.x2l),
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
            Divider(height: AppSpacing.x2l),
            _row(
              context,
              context.l10n.cartTotalLine,
              context.formatCurrency(summary.total),
              emphasize: true,
            ),
            const SizedBox(height: AppSpacing.md),
            // Text(
            //   context.l10n.cartCashOnDeliveryNote,
            //   style: AppTypography.bodySmall.copyWith(
            //     color: context.textSecondary,
            //   ),
            // ),
            // const SizedBox(height: AppSpacing.xs),
            // Text(
            //   context.l10n.cartSecureCheckout,
            //   style: AppTypography.bodySmall.copyWith(
            //     color: context.textSecondary,
            //   ),
            // ),
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
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            label,
            style: emphasize
                ? AppTypography.titleMedium.copyWith(fontWeight: FontWeight.w700)
                : AppTypography.bodyMedium.copyWith(
                    color: context.textSecondary,
                  ),
          ),
        ),
        Text(
          value,
          style: (emphasize ? AppTypography.titleMedium : AppTypography.bodyMedium)
              .copyWith(
            color: emphasize ? AppColors.primary : context.textPrimary,
            fontWeight: emphasize ? FontWeight.w800 : FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
