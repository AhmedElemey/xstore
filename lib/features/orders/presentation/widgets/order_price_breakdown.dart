import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/constants/app_typography.dart';
import '../../domain/entities/order_entity.dart';

String paymentMethodLabel(PaymentMethod m) => switch (m) {
      PaymentMethod.cashOnDelivery => AppStrings.ordersPaymentCashOnDelivery,
      PaymentMethod.cibCard => AppStrings.ordersPaymentCib,
      PaymentMethod.dahabiCard => AppStrings.ordersPaymentDahabi,
      PaymentMethod.baridimob => AppStrings.ordersPaymentBaridimob,
    };

class OrderPriceBreakdown extends StatelessWidget {
  const OrderPriceBreakdown({
    super.key,
    required this.order,
  });

  final OrderEntity order;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Icon(
              _payIcon(order.paymentMethod),
              color: AppColors.textSecondary,
              size: AppSpacing.x2l,
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Text(
                paymentMethodLabel(order.paymentMethod),
                style: AppTypography.bodyLarge.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.xs,
              ),
              decoration: BoxDecoration(
                color: order.isPaid
                    ? AppColors.success.withValues(alpha: 0.12)
                    : AppColors.warning.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(AppSpacing.x4l),
              ),
              child: Text(
                order.isPaid
                    ? AppStrings.ordersPaidBadge
                    : AppStrings.ordersPaymentPendingBadge,
                style: AppTypography.labelLarge.copyWith(
                  color: order.isPaid ? AppColors.success : AppColors.warning,
                ),
              ),
            ),
          ],
        ),
        const Divider(height: AppSpacing.x2l),
        _row(AppStrings.ordersSubtotal, order.subtotal),
        _row(AppStrings.ordersShipping, order.shippingCost),
        _row(AppStrings.ordersDiscount, order.discount),
        const Divider(height: AppSpacing.lg),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              AppStrings.ordersTotal,
              style: AppTypography.titleMedium,
            ),
            Text(
              '${_fmt(order.total)} ${AppStrings.currencyDzd}',
              style: AppTypography.titleMedium.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ],
    );
  }

  IconData _payIcon(PaymentMethod m) => switch (m) {
        PaymentMethod.cashOnDelivery => Icons.payments_outlined,
        _ => Icons.credit_card_outlined,
      };

  Widget _row(String label, double value) => Padding(
        padding: const EdgeInsets.only(bottom: AppSpacing.sm),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            Text(
              '${_fmt(value)} ${AppStrings.currencyDzd}',
              style: AppTypography.bodyLarge,
            ),
          ],
        ),
      );

  String _fmt(double v) {
    if (v == v.roundToDouble()) return v.toStringAsFixed(0);
    return v.toStringAsFixed(2);
  }
}
