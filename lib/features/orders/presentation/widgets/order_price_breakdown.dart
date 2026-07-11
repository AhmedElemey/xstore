import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../commission/domain/entities/commission_breakdown.dart';
import '../../../commission/domain/entities/commission_status.dart';
import '../../../commission/presentation/providers/commission_config_provider.dart';
import '../../domain/entities/order_entity.dart';
import '../../../../core/utils/extensions/context_extensions.dart';

String commissionStatusLabel(BuildContext context, CommissionStatus s) =>
    switch (s) {
      CommissionStatus.pending => context.l10n.commissionStatusPending,
      CommissionStatus.due => context.l10n.commissionStatusDue,
      CommissionStatus.settled => context.l10n.commissionStatusSettled,
      CommissionStatus.voided => context.l10n.commissionStatusVoided,
    };

String paymentMethodLabel(BuildContext context, PaymentMethod m) => switch (m) {
      PaymentMethod.cashOnDelivery => context.l10n.ordersPaymentCashOnDelivery,
      PaymentMethod.cibCard => context.l10n.ordersPaymentCib,
      PaymentMethod.dahabiCard => context.l10n.ordersPaymentDahabi,
      PaymentMethod.baridimob => context.l10n.ordersPaymentBaridimob,
    };

class OrderPriceBreakdown extends ConsumerWidget {
  const OrderPriceBreakdown({
    super.key,
    required this.order,
    this.vendorMode = false,
  });

  final OrderEntity order;
  final bool vendorMode;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Buyer never sees the platform fee — computed only in vendor mode.
    final rate = vendorMode
        ? ref.watch(commissionRateForCategoryProvider(null))
        : 0.0;
    final commission = vendorMode
        ? CommissionBreakdown.forPrice(order.total, ratePercent: rate)
        : null;
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
              context.formatCurrency(order.total),
              style: AppTypography.titleMedium.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        if (commission != null) ...[
          Divider(height: AppSpacing.x2l),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                context.l10n.commissionStatusLabel,
                style: AppTypography.bodyMedium.copyWith(
                  color: context.textSecondary,
                ),
              ),
              Text(
                commissionStatusLabel(
                  context,
                  commissionStatusForOrder(order.status),
                ),
                style: AppTypography.bodyMedium.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                context.l10n.commissionYouEarn,
                style: AppTypography.bodyMedium.copyWith(
                  color: context.textSecondary,
                ),
              ),
              Text(
                context.formatCurrency(commission.vendorEarns),
                style: AppTypography.bodyLarge.copyWith(
                  color: context.isDark
                      ? AppColors.successLight
                      : AppColors.success,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          _row(
            context,
            '${context.l10n.commissionPlatformFee} (${commission.ratePercent.toStringAsFixed(0)}%)',
            commission.feeAmount,
          ),
        ],
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
              context.formatCurrency(value),
              style: AppTypography.bodyLarge,
            ),
          ],
        ),
      );

}
