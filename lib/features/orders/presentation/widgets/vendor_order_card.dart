import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/utils/extensions/context_extensions.dart';
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
    final pending = order.status == OrderStatus.pending;
    final bg = pending
        ? (context.isDark ? const Color(0xFF292011) : const Color(0xFFFFFBEB))
        : context.surfaceColor;
    return InkWell(
      borderRadius: BorderRadius.circular(AppSpacing.lg),
      onTap: () => context.push('${AppRoutes.vendorOrders}/${order.id}'),
      child: Container(
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(AppSpacing.lg),
          border: Border.all(color: context.borderColor.withValues(alpha: 0.45)),
          boxShadow: [BoxShadow(color: context.cardShadowColor, blurRadius: 12)],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (pending) Container(width: 3, color: AppColors.warning),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            pending ? context.l10n.vendorNewOrder : order.formattedOrderId,
                            style: Theme.of(context).textTheme.labelLarge?.copyWith(
                                  color: pending ? AppColors.warning : context.textPrimary,
                                  fontWeight: FontWeight.w800,
                                ),
                          ),
                        ),
                        OrderStatusBadge(status: order.status, compact: true),
                        const SizedBox(width: AppSpacing.xs),
                        Text(
                          DateFormat('HH:mm').format(order.createdAt.toLocal()),
                          style: Theme.of(context)
                              .textTheme
                              .labelSmall
                              ?.copyWith(color: context.textSecondary),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      order.consumerName,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                    InkWell(
                      onTap: () => launchUrl(Uri(scheme: 'tel', path: order.consumerPhone)),
                      child: Text(
                        order.consumerPhone,
                        style: Theme.of(context)
                            .textTheme
                            .labelMedium
                            ?.copyWith(color: AppColors.primary),
                      ),
                    ),
                    Text(
                      '${order.deliveryAddress.city}, ${order.deliveryAddress.wilaya}',
                      style: Theme.of(context)
                          .textTheme
                          .labelMedium
                          ?.copyWith(color: context.textSecondary),
                    ),
                    const Divider(height: AppSpacing.lg),
                    Text(
                      order.items.first.listingName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                    Text(
                      '${order.items.first.condition} · ${order.items.first.category}',
                      style: Theme.of(context)
                          .textTheme
                          .labelMedium
                          ?.copyWith(color: context.textSecondary),
                    ),
                    Text(
                      '${context.formatCurrency(order.items.first.price)} · Qty: ${order.items.first.quantity}',
                      style: Theme.of(context)
                          .textTheme
                          .labelMedium
                          ?.copyWith(color: context.textSecondary),
                    ),
                    if (order.items.length > 1)
                      Text(
                        context.l10n.ordersMoreItems(order.items.length - 1),
                        style: Theme.of(context)
                            .textTheme
                            .labelSmall
                            ?.copyWith(color: context.textSecondary),
                      ),
                    const Divider(height: AppSpacing.lg),
                    Text(
                      '${_paymentMethodLabel(context, order.paymentMethod)} · ${context.formatCurrency(order.total)}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: context.textSecondary,
                          ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    _actions(context),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _actions(BuildContext context) {
    if (order.status == OrderStatus.pending) {
      return Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: onReject,
              style: OutlinedButton.styleFrom(foregroundColor: AppColors.error),
              child: Text(context.l10n.vendorRejectOrder),
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            flex: 2,
            child: FilledButton(
              onPressed: onConfirm,
              style: FilledButton.styleFrom(backgroundColor: AppColors.success),
              child: Text(context.l10n.vendorConfirmOrder),
            ),
          ),
        ],
      );
    }
    if (order.status == OrderStatus.confirmed) {
      return OutlinedButton(
        onPressed: onProcessing,
        child: Text(context.l10n.vendorMarkProcessing),
      );
    }
    if (order.status == OrderStatus.processing) {
      return FilledButton(
        onPressed: onShipped,
        child: Text(context.l10n.vendorMarkShipped),
      );
    }
    return OutlinedButton(
      onPressed: null,
      child: Text(context.l10n.ordersViewDetails),
    );
  }

  String _paymentMethodLabel(BuildContext context, PaymentMethod method) => switch (method) {
        PaymentMethod.cashOnDelivery => context.l10n.ordersPaymentCashOnDelivery,
        PaymentMethod.cibCard => context.l10n.ordersPaymentCib,
        PaymentMethod.dahabiCard => context.l10n.ordersPaymentDahabi,
        PaymentMethod.baridimob => context.l10n.ordersPaymentBaridimob,
      };
}
