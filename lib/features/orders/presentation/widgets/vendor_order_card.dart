import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/utils/extensions/context_extensions.dart';
import '../../../../shared/widgets/app_cached_network_image.dart';
import '../../domain/entities/order_entity.dart';
import 'order_status_badge.dart';

class VendorOrderCard extends StatelessWidget {
  const VendorOrderCard({
    super.key,
    required this.order,
    required this.onConfirm,
    required this.onReject,
    required this.onProcessing,
    required this.onShipped,
  });

  final OrderEntity order;
  final VoidCallback onConfirm;
  final VoidCallback onReject;
  final VoidCallback onProcessing;
  final VoidCallback onShipped;

  @override
  Widget build(BuildContext context) {
    final name = order.consumerName.trim();
    final phone = order.consumerPhone.trim();
    final cityLine = [
      if (order.deliveryAddress.city.trim().isNotEmpty)
        order.deliveryAddress.city.trim(),
      if (order.deliveryAddress.wilaya.trim().isNotEmpty)
        order.deliveryAddress.wilaya.trim(),
    ].join(', ');
    final item = order.items.isEmpty ? null : order.items.first;
    final accent = orderStatusColor(order.status);
    final radius = BorderRadius.circular(AppSpacing.lg);
    final actions = _actions(context);
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: radius,
        boxShadow: [
          BoxShadow(
            color: context.cardShadowColor,
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Material(
        color: context.surfaceColor,
        borderRadius: radius,
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () => context.push('${AppRoutes.vendorOrders}/${order.id}'),
          child: Ink(
            decoration: BoxDecoration(
              border: Border.all(color: accent.withValues(alpha: 0.45)),
              borderRadius: radius,
            ),
            child: Stack(
              children: [
                Padding(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${context.l10n.orderHashPrefix}${order.formattedOrderId}',
                                  style: AppTypography.titleSmall.copyWith(
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                Text(
                                  DateFormat(
                                    'HH:mm',
                                  ).format(order.createdAt.toLocal()),
                                  style: AppTypography.bodySmall.copyWith(
                                    color: context.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          OrderStatusBadge(status: order.status, compact: true),
                        ],
                      ),
                      if (name.isNotEmpty ||
                          phone.isNotEmpty ||
                          cityLine.isNotEmpty) ...[
                        const SizedBox(height: AppSpacing.sm),
                        if (name.isNotEmpty)
                          Text(
                            name,
                            style: AppTypography.bodyMedium.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        if (phone.isNotEmpty)
                          Text(
                            phone,
                            style: AppTypography.bodySmall.copyWith(
                              color: context.textSecondary,
                            ),
                          ),
                        if (cityLine.isNotEmpty)
                          Text(
                            cityLine,
                            style: AppTypography.bodySmall.copyWith(
                              color: context.textSecondary,
                            ),
                          ),
                      ],
                      if (item != null) ...[
                        const SizedBox(height: AppSpacing.sm),
                        Row(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(
                                AppSpacing.xs,
                              ),
                              child: SizedBox(
                                width: 48,
                                height: 48,
                                child: item.listingImage.trim().isNotEmpty
                                    ? AppCachedNetworkImage(
                                        imageUrl: item.listingImage,
                                        fit: BoxFit.cover,
                                        memCacheWidth: 96,
                                        memCacheHeight: 96,
                                      )
                                    : ColoredBox(
                                        color: context.textDisabled.withValues(
                                          alpha: 0.2,
                                        ),
                                      ),
                              ),
                            ),
                            const SizedBox(width: AppSpacing.sm),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item.listingName,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: AppTypography.bodyMedium.copyWith(
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  Text(
                                    '${context.formatCurrency(item.price)} · ${context.l10n.ordersQtyTotalLinePrefix} ${item.quantity}',
                                    style: AppTypography.bodySmall.copyWith(
                                      color: context.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                      const SizedBox(height: AppSpacing.md),
                      Text(
                        '${_paymentMethodLabel(context, order.paymentMethod)} · ${context.formatCurrency(order.total)}',
                        style: AppTypography.bodySmall.copyWith(
                          color: context.textSecondary,
                        ),
                      ),
                      if (actions != null) ...[
                        const SizedBox(height: AppSpacing.sm),
                        actions,
                      ],
                    ],
                  ),
                ),
                Positioned(
                  left: 0,
                  top: 0,
                  bottom: 0,
                  width: 4,
                  child: ColoredBox(color: accent),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget? _actions(BuildContext context) {
    final compact = OutlinedButton.styleFrom(
      visualDensity: VisualDensity.compact,
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
    );
    if (order.status == OrderStatus.pending) {
      return Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: onReject,
              style: compact.copyWith(
                foregroundColor: const WidgetStatePropertyAll(AppColors.error),
              ),
              child: Text(
                context.l10n.vendorRejectOrder,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: FilledButton(
              onPressed: onConfirm,
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.success,
                visualDensity: VisualDensity.compact,
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: Text(
                context.l10n.vendorConfirmOrder,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
        ],
      );
    }
    if (order.status == OrderStatus.confirmed) {
      return SizedBox(
        width: double.infinity,
        child: OutlinedButton(
          onPressed: onProcessing,
          style: compact.copyWith(
            foregroundColor: const WidgetStatePropertyAll(AppColors.accent),
          ),
          child: Text(context.l10n.vendorMarkProcessing),
        ),
      );
    }
    if (order.status == OrderStatus.processing) {
      return SizedBox(
        width: double.infinity,
        child: FilledButton(
          onPressed: onShipped,
          style: FilledButton.styleFrom(
            backgroundColor: AppColors.accent,
            visualDensity: VisualDensity.compact,
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          child: Text(context.l10n.vendorMarkShipped),
        ),
      );
    }
    return null;
  }

  String _paymentMethodLabel(BuildContext context, PaymentMethod method) =>
      switch (method) {
        PaymentMethod.cashOnDelivery =>
          context.l10n.ordersPaymentCashOnDelivery,
        PaymentMethod.cibCard => context.l10n.ordersPaymentCib,
        PaymentMethod.dahabiCard => context.l10n.ordersPaymentDahabi,
        PaymentMethod.baridimob => context.l10n.ordersPaymentBaridimob,
      };
}
