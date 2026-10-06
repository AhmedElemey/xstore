import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/utils/extensions/context_extensions.dart';
import '../../../../shared/widgets/app_cached_network_image.dart';
import '../../domain/entities/order_entity.dart';
import 'order_status_badge.dart';
import 'order_price_breakdown.dart';

class VendorOrderCard extends StatelessWidget {
  const VendorOrderCard({
    super.key,
    required this.order,
    required this.onConfirm,
    required this.onReject,
    required this.onProcessing,
    required this.onShipped,
    required this.onDelivered,
  });

  final OrderEntity order;
  final VoidCallback onConfirm;
  final VoidCallback onReject;
  final VoidCallback onProcessing;
  final VoidCallback onShipped;
  final VoidCallback onDelivered;

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
    final radius = BorderRadius.circular(22);
    final actions = _actions(context);
    // Active orders get a status-tinted outline, like the consumer card;
    // finished ones keep the plain glass border.
    final active =
        order.status != OrderStatus.delivered &&
        order.status != OrderStatus.cancelled;
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: radius,
        color: context.glassColor,
        border: Border.all(
          color: active ? accent.withValues(alpha: 0.4) : context.borderColor,
        ),
      ),
      child: Material(
        type: MaterialType.transparency,
        borderRadius: radius,
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () => context.push('${AppRoutes.vendorOrders}/${order.id}'),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    OrderStatusBadge(status: order.status, compact: true),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: Text(
                        context.formatTime(order.createdAt.toLocal()),
                        style: AppTypography.bodySmall.copyWith(
                          color: context.labelColor,
                        ),
                      ),
                    ),
                    Text(
                      '${context.l10n.orderHashPrefix}${order.formattedOrderId}',
                      style: AppTypography.mono.copyWith(
                        fontSize: 12,
                        color: context.labelColor,
                      ),
                    ),
                  ],
                ),
                if (name.isNotEmpty ||
                    phone.isNotEmpty ||
                    cityLine.isNotEmpty) ...[
                  const SizedBox(height: AppSpacing.md),
                  if (name.isNotEmpty)
                    Text(
                      name,
                      style: AppTypography.bodyMedium.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  if (phone.isNotEmpty)
                    Text(
                      phone,
                      style: AppTypography.bodySmall.copyWith(
                        color: context.labelColor,
                      ),
                    ),
                  if (cityLine.isNotEmpty)
                    Text(
                      cityLine,
                      style: AppTypography.bodySmall.copyWith(
                        color: context.labelColor,
                      ),
                    ),
                ],
                if (item != null) ...[
                  const SizedBox(height: AppSpacing.md),
                  Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(14),
                        child: SizedBox(
                          width: 56,
                          height: 56,
                          child: item.listingImage.trim().isNotEmpty
                              ? AppCachedNetworkImage(
                                  imageUrl: item.listingImage,
                                  fit: BoxFit.cover,
                                  memCacheWidth: 168,
                                  memCacheHeight: 168,
                                  errorWidget: (context, _, _) =>
                                      _thumbPlaceholder(context),
                                )
                              : _thumbPlaceholder(context),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.listingName,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: AppTypography.bodyLarge.copyWith(
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '${context.formatCurrency(item.price)} · ${context.l10n.ordersQtyTotalLinePrefix} ${item.quantity}',
                              style: AppTypography.bodySmall.copyWith(
                                color: context.labelColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
                const SizedBox(height: AppSpacing.md),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        paymentMethodLabel(context, order.paymentMethod),
                        style: AppTypography.bodySmall.copyWith(
                          color: context.labelColor,
                        ),
                      ),
                    ),
                    Text(
                      context.formatCurrency(order.total),
                      style: AppTypography.mono.copyWith(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: context.amberColor,
                      ),
                    ),
                  ],
                ),
                if (actions != null) ...[
                  const SizedBox(height: AppSpacing.md),
                  actions,
                ],
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
    if (order.status == OrderStatus.shipped) {
      return SizedBox(
        width: double.infinity,
        child: FilledButton(
          onPressed: onDelivered,
          style: FilledButton.styleFrom(
            backgroundColor: AppColors.accent,
            visualDensity: VisualDensity.compact,
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          child: Text(context.l10n.vendorMarkDelivered),
        ),
      );
    }
    return null;
  }
}

Widget _thumbPlaceholder(BuildContext context) =>
    ColoredBox(color: context.textDisabled.withValues(alpha: 0.2));
