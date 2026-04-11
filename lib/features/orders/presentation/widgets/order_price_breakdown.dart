import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_typography.dart';
import '../../domain/entities/order_entity.dart';
import '../../../../core/utils/extensions/context_extensions.dart';

String paymentMethodLabel(BuildContext context, PaymentMethod m) => switch (m) {
      PaymentMethod.cashOnDelivery => context.l10n.ordersPaymentCashOnDelivery,
      PaymentMethod.cibCard => context.l10n.ordersPaymentCib,
      PaymentMethod.dahabiCard => context.l10n.ordersPaymentDahabi,
      PaymentMethod.baridimob => context.l10n.ordersPaymentBaridimob,
    };

class OrderPriceBreakdown extends StatelessWidget {
  const OrderPriceBreakdown({
    super.key,
    required this.order,
    this.vendorMode = false,
  });

  final OrderEntity order;
  final bool vendorMode;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Icon(
              _payIcon(order.paymentMethod),
              color: context.textSecondary,
              size: AppSpacing.x2l,
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Text(
                paymentMethodLabel(context, order.paymentMethod),
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
                order.paymentMethod == PaymentMethod.cashOnDelivery && vendorMode
                    ? context.l10n.vendorCollectOnDelivery
                    : (order.isPaid
                        ? context.l10n.ordersPaidBadge
                        : context.l10n.ordersPaymentPendingBadge),
                style: AppTypography.labelLarge.copyWith(
                  color: order.paymentMethod == PaymentMethod.cashOnDelivery && vendorMode
                      ? AppColors.warning
                      : (order.isPaid ? AppColors.success : AppColors.warning),
                ),
              ),
            ),
          ],
        ),
        Divider(height: AppSpacing.x2l),
        _row(context, context.l10n.ordersSubtotal, order.subtotal),
        _row(context, context.l10n.ordersShipping, order.shippingCost),
        _row(context, context.l10n.ordersDiscount, order.discount),
        Divider(height: AppSpacing.lg),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              context.l10n.ordersTotal,
              style: AppTypography.titleMedium,
            ),
            Text(
              '${_fmt(order.total)} ${context.l10n.currencyDzd}',
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

  Widget _row(BuildContext context, String label, double value) => Padding(
        padding: const EdgeInsets.only(bottom: AppSpacing.sm),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: AppTypography.bodyMedium.copyWith(
                color: context.textSecondary,
              ),
            ),
            Text(
              '${_fmt(value)} ${context.l10n.currencyDzd}',
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
