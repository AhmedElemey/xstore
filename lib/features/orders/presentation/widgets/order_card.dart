import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/router/app_routes.dart';
import '../../domain/entities/order_entity.dart';
import '../providers/orders_provider.dart';
import 'order_flow_sheets.dart';
import 'order_status_badge.dart';
import '../../../../core/utils/extensions/context_extensions.dart';
import '../../../../shared/widgets/app_cached_network_image.dart';
import '../../../../shared/widgets/app_snackbar.dart';

class OrderCard extends ConsumerWidget {
  const OrderCard({
    super.key,
    required this.order,
  });

  final OrderEntity order;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = ref.read(ordersNotifierProvider.notifier);
    final first = order.items.isNotEmpty ? order.items.first : null;
    final more = order.items.length - 1;
    final accent = orderStatusColor(order.status);
    final radius = BorderRadius.circular(AppSpacing.lg);

    // Same chrome as VendorOrderCard: soft shadow outside clip, status-tint
    // outline, and a 4px left accent bar.
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
          onTap: () => context.push(AppRoutes.orderPath(order.id)),
          child: Ink(
            decoration: BoxDecoration(
              border: Border.all(color: accent.withValues(alpha: 0.45)),
              borderRadius: radius,
            ),
            child: Stack(
              children: [
                Padding(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              '${context.l10n.orderHashPrefix}${order.formattedOrderId}',
                              style: AppTypography.bodyLarge.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          OrderStatusBadge(status: order.status, compact: true),
                        ],
                      ),
                      Divider(height: AppSpacing.lg),
                      if (first != null) ...[
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(
                                AppSpacing.sm,
                              ),
                              child: SizedBox(
                                width: 60,
                                height: 60,
                                child: first.listingImage.isNotEmpty
                                    ? AppCachedNetworkImage(
                                        imageUrl: first.listingImage,
                                        fit: BoxFit.cover,
                                        memCacheWidth: 180,
                                        memCacheHeight: 180,
                                      )
                                    : Container(
                                        color: context.textDisabled.withValues(
                                          alpha: 0.2,
                                        ),
                                      ),
                              ),
                            ),
                            const SizedBox(width: AppSpacing.md),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    first.listingName,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: AppTypography.bodyLarge.copyWith(
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  if (more > 0)
                                    Text(
                                      context.l10n.ordersMoreItems(more),
                                      style: AppTypography.bodySmall,
                                    ),
                                  const SizedBox(height: AppSpacing.xs),
                                  Text(
                                    '${context.l10n.ordersQtyTotalLinePrefix}: ${first.quantity} · ${context.formatCurrency(first.total)}',
                                    style: AppTypography.bodyLarge.copyWith(
                                      color: AppColors.primary,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                      Divider(height: AppSpacing.lg),
                      Text(
                        '📦 ${order.vendorStoreName} · ${context.formatMediumDate(order.createdAt)}',
                        style: AppTypography.bodySmall,
                      ),
                      if ((order.status == OrderStatus.shipped ||
                              order.status == OrderStatus.confirmed) &&
                          order.estimatedDelivery != null) ...[
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          '${context.l10n.ordersEstimatedDelivery}: ${context.formatWeekdayDate(order.estimatedDelivery!)}',
                          style: AppTypography.bodySmall.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                      const SizedBox(height: AppSpacing.md),
                      _actions(context, ref, notifier),
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

  Widget _actions(
    BuildContext context,
    WidgetRef ref,
    OrdersNotifier notifier,
  ) {
    switch (order.status) {
      case OrderStatus.pending:
      case OrderStatus.confirmed:
        return SizedBox(
          width: double.infinity,
          child: OutlinedButton(
            onPressed: () => _cancelConsumer(context, ref, notifier),
            child: Text(context.l10n.ordersCancelOrder),
          ),
        );
      case OrderStatus.shipped:
        return SizedBox(
          width: double.infinity,
          child: OutlinedButton(
            onPressed: () => _trackingSnack(context),
            child: Text(context.l10n.ordersTrackOrder),
          ),
        );
      case OrderStatus.delivered:
        return Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () => showOrderReviewFlow(context, ref, order),
                child: Text(context.l10n.ordersLeaveReview),
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: FilledButton(
                onPressed: () async {
                  await notifier.reorder(order.id);
                  if (context.mounted) {
                    AppSnackbar.success(context, context.l10n.addedToCart);
                  }
                },
                child: Text(context.l10n.ordersReorder),
              ),
            ),
          ],
        );
      case OrderStatus.cancelled:
        return SizedBox(
          width: double.infinity,
          child: OutlinedButton(
            onPressed: () => context.push(AppRoutes.orderPath(order.id)),
            child: Text(context.l10n.ordersViewDetails),
          ),
        );
      case OrderStatus.processing:
        return SizedBox(
          width: double.infinity,
          child: OutlinedButton(
            onPressed: () => context.push(AppRoutes.orderPath(order.id)),
            child: Text(context.l10n.ordersViewDetails),
          ),
        );
    }
  }

  Future<void> _cancelConsumer(
    BuildContext context,
    WidgetRef ref,
    OrdersNotifier notifier,
  ) async {
    final reason = await showCancelReasonDialog(context);
    if (reason == null || !context.mounted) return;
    await notifier.cancelOrder(order.id, reason);
    if (!context.mounted) return;
    _errSnack(context, ref);
  }

  void _trackingSnack(BuildContext context) {
    AppSnackbar.show(
      context,
      message:
          order.trackingNumber ?? context.l10n.ordersTrackOnCourier,
    );
  }

  void _errSnack(BuildContext context, WidgetRef ref) {
    final err = ref.read(ordersNotifierProvider).error;
    if (err != null) {
      AppSnackbar.error(context, err);
      ref.read(ordersNotifierProvider.notifier).clearError();
    }
  }
}
