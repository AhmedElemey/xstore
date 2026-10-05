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
  const OrderCard({super.key, required this.order});

  final OrderEntity order;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = ref.read(ordersNotifierProvider.notifier);
    final first = order.items.isNotEmpty ? order.items.first : null;
    final more = order.items.length - 1;
    final accent = orderStatusColor(order.status);
    final radius = BorderRadius.circular(22);
    // Active orders get a status-tinted outline like the Orbit mockup;
    // finished ones keep the plain glass border.
    final active =
        order.status != OrderStatus.delivered &&
        order.status != OrderStatus.cancelled;

    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: radius,
        border: Border.all(
          color: active ? accent.withValues(alpha: 0.4) : context.borderColor,
        ),
        color: context.glassColor,
      ),
      child: Material(
        type: MaterialType.transparency,
        borderRadius: radius,
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () => context.push(AppRoutes.orderPath(order.id)),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    OrderStatusBadge(status: order.status, compact: true),
                    const Spacer(),
                    Text(
                      '${context.l10n.orderHashPrefix}${order.formattedOrderId}',
                      style: AppTypography.mono.copyWith(
                        fontSize: 12,
                        color: context.labelColor,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),
                if (first != null)
                  Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(14),
                        child: SizedBox(
                          width: 56,
                          height: 56,
                          child: first.listingImage.isNotEmpty
                              ? AppCachedNetworkImage(
                                  imageUrl: first.listingImage,
                                  fit: BoxFit.cover,
                                  memCacheWidth: 168,
                                  memCacheHeight: 168,
                                )
                              : ColoredBox(
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
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            if (more > 0)
                              Text(
                                context.l10n.ordersMoreItems(more),
                                style: AppTypography.bodySmall.copyWith(
                                  color: context.labelColor,
                                ),
                              ),
                            const SizedBox(height: 2),
                            Text(
                              '${context.l10n.ordersQtyTotalLinePrefix}: ${first.quantity}',
                              style: AppTypography.bodySmall.copyWith(
                                color: context.labelColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Text(
                        context.formatCurrency(first.total),
                        style: AppTypography.mono.copyWith(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: context.amberColor,
                        ),
                      ),
                    ],
                  ),
                if (order.status != OrderStatus.cancelled) ...[
                  const SizedBox(height: AppSpacing.md),
                  _ProgressTrack(status: order.status),
                ],
                const SizedBox(height: AppSpacing.md),
                Text(
                  '📦 ${order.vendorStoreName} · ${context.formatMediumDate(order.createdAt)}',
                  style: AppTypography.bodySmall.copyWith(
                    color: context.labelColor,
                  ),
                ),
                if ((order.status == OrderStatus.shipped ||
                        order.status == OrderStatus.confirmed) &&
                    order.estimatedDelivery != null) ...[
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    '${context.l10n.ordersEstimatedDelivery}: ${context.formatWeekdayDate(order.estimatedDelivery!)}',
                    style: AppTypography.bodySmall.copyWith(
                      color: context.linkColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
                const SizedBox(height: AppSpacing.md),
                _actions(context, ref, notifier),
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
      message: order.trackingNumber ?? context.l10n.ordersTrackOnCourier,
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

/// Five-segment progress bar: one segment per step up to the current status.
class _ProgressTrack extends StatelessWidget {
  const _ProgressTrack({required this.status});

  final OrderStatus status;

  @override
  Widget build(BuildContext context) {
    // Cancelled orders never reach this widget.
    final reached = switch (status) {
      OrderStatus.pending => 1,
      OrderStatus.confirmed => 2,
      OrderStatus.processing => 3,
      OrderStatus.shipped => 4,
      OrderStatus.delivered || OrderStatus.cancelled => 5,
    };
    final on = context.isDark ? AppColors.primaryLight : AppColors.primary;
    return Row(
      children: [
        for (var i = 1; i <= 5; i++) ...[
          if (i > 1) const SizedBox(width: 4),
          Expanded(
            child: Container(
              height: 4,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(2),
                color: i <= reached ? on : context.borderColor,
                boxShadow: i == reached && status != OrderStatus.delivered
                    ? [
                        BoxShadow(
                          color: on.withValues(alpha: 0.6),
                          blurRadius: 8,
                        ),
                      ]
                    : null,
              ),
            ),
          ),
        ],
      ],
    );
  }
}
