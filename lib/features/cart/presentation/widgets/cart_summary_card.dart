import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/utils/formatters.dart';
import '../providers/cart_provider.dart';

class CartSummaryCard extends ConsumerWidget {
  const CartSummaryCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cart = ref.watch(cartProvider);
    final n = cart.selectedAvailableItems.length;
    final code = cart.coupon?.code;

    return Material(
      color: AppColors.cardBg,
      borderRadius: BorderRadius.circular(AppSpacing.lg),
      elevation: 1,
      shadowColor: AppColors.textPrimary.withValues(alpha: 0.06),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppStrings.cartOrderSummary,
              style: AppTypography.titleMedium.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const Divider(height: AppSpacing.x2l),
            _row(
              AppStrings.cartSubtotalLine(n),
              Formatters.dzdWhole(cart.subtotal),
            ),
            const SizedBox(height: AppSpacing.sm),
            _row(
              AppStrings.cartShippingLine,
              Formatters.dzdWhole(cart.shippingTotal),
            ),
            if (code != null && cart.discount > 0) ...[
              const SizedBox(height: AppSpacing.sm),
              _row(
                AppStrings.cartCouponLine(code),
                '-${Formatters.dzdWhole(cart.discount)}',
                valueColor: AppColors.success,
              ),
            ],
            const Divider(height: AppSpacing.x2l),
            _row(
              AppStrings.cartTotalLine,
              Formatters.dzdWhole(cart.total),
              emphasize: true,
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              AppStrings.cartCashOnDeliveryNote,
              style: AppTypography.bodySmall.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              AppStrings.cartSecureCheckout,
              style: AppTypography.bodySmall.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _row(
    String label,
    String value, {
    Color? valueColor,
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
                    color: AppColors.textSecondary,
                  ),
          ),
        ),
        Text(
          value,
          style: (emphasize ? AppTypography.titleMedium : AppTypography.bodyMedium)
              .copyWith(
            color: valueColor ??
                (emphasize ? AppColors.primary : AppColors.textPrimary),
            fontWeight: emphasize ? FontWeight.w800 : FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
