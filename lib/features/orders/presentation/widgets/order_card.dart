import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/router/app_routes.dart';
import '../../domain/entities/order_entity.dart';
import '../providers/orders_provider.dart';
import 'order_status_badge.dart';
import '../../../../core/utils/extensions/context_extensions.dart';
import '../../../../shared/widgets/app_cached_network_image.dart';
import '../../../../shared/widgets/app_snackbar.dart';

class OrderCard extends ConsumerWidget {
  const OrderCard({
    super.key,
    required this.order,
    required this.isVendor,
  });

  final OrderEntity order;
  final bool isVendor;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = ref.read(ordersNotifierProvider.notifier);
    final first = order.items.isNotEmpty ? order.items.first : null;
    final more = order.items.length - 1;

    return Material(
      color: context.surfaceColor,
      borderRadius: BorderRadius.circular(AppSpacing.lg),
      elevation: 0,
      shadowColor: context.textPrimary.withValues(alpha: 0.06),
      child: InkWell(
        onTap: () => context.push(AppRoutes.orderPath(order.id)),
        borderRadius: BorderRadius.circular(AppSpacing.lg),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppSpacing.lg),
            boxShadow: [
              BoxShadow(
                color: context.textPrimary.withValues(alpha: 0.06),
                blurRadius: AppSpacing.md,
                offset: const Offset(0, AppSpacing.xs),
              ),
            ],
          ),
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
                if (isVendor) ...[
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 30,
                        backgroundImage: order.consumerAvatar.isNotEmpty
                            ? AppNetworkImage.network(order.consumerAvatar)
                            : null,
                        child: order.consumerAvatar.isEmpty
                            ? Text(
                                order.consumerName.isNotEmpty
                                    ? order.consumerName[0].toUpperCase()
                                    : '?',
                              )
                            : null,
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              order.consumerName,
                              style: AppTypography.bodyLarge.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              '📞 ${order.consumerPhone}',
                              style: AppTypography.bodySmall,
                            ),
                            Text(
                              '📍 ${order.deliveryAddress.city}, ${order.deliveryAddress.wilaya}',
                              style: AppTypography.bodySmall,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  Divider(height: AppSpacing.lg),
                ],
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(AppSpacing.sm),
                      child: SizedBox(
                        width: 60,
                        height: 60,
                        child: first.listingImage.isNotEmpty
                            ? AppCachedNetworkImage(
                                imageUrl: first.listingImage,
                                fit: BoxFit.cover,
                              )
                            : Container(
                                color: context.textDisabled
                                    .withValues(alpha: 0.2),
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
              if (!isVendor)
                Text(
                  '📦 ${order.vendorStoreName} · ${_shortDate(order.createdAt)}',
                  style: AppTypography.bodySmall,
                )
              else
                Text(
                  '💳 ${paymentShort(context, order)} · ${_shortDate(order.createdAt)}',
                  style: AppTypography.bodySmall,
                ),
              if (!isVendor &&
                  (order.status == OrderStatus.shipped ||
                      order.status == OrderStatus.confirmed) &&
                  order.estimatedDelivery != null) ...[
                const SizedBox(height: AppSpacing.xs),
                Text(
                  '${context.l10n.ordersEstimatedDelivery}: ${_eta(order.estimatedDelivery!)}',
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
      ),
    );
  }

  Widget _actions(
    BuildContext context,
    WidgetRef ref,
    OrdersNotifier notifier,
  ) {
    if (isVendor) {
      switch (order.status) {
        case OrderStatus.pending:
          return Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => _rejectFlow(context, ref, notifier),
                  child: Text(context.l10n.ordersRejectOrder),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: FilledButton(
                  onPressed: () => notifier.confirmOrderVendor(order.id),
                  child: Text(context.l10n.ordersConfirmOrderCta),
                ),
              ),
            ],
          );
        case OrderStatus.confirmed:
          return SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: () => notifier.markProcessing(order.id),
              child: Text(context.l10n.ordersMarkProcessing),
            ),
          );
        case OrderStatus.processing:
          return SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: () => _shipSheet(context, ref, notifier),
              child: Text(context.l10n.ordersMarkShipped),
            ),
          );
        case OrderStatus.shipped:
          return SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () => _trackingSnack(context),
              child: Text(context.l10n.ordersViewTracking),
            ),
          );
        case OrderStatus.delivered:
        case OrderStatus.cancelled:
        case OrderStatus.refunded:
          return SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () => context.push(AppRoutes.orderPath(order.id)),
              child: Text(context.l10n.ordersViewDetails),
            ),
          );
      }
    }

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
        return Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () => _trackingSnack(context),
                child: Text(context.l10n.ordersTrackOrder),
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: FilledButton(
                onPressed: () => _confirmReceipt(context, ref, notifier),
                child: Text(context.l10n.ordersConfirmReceipt),
              ),
            ),
          ],
        );
      case OrderStatus.delivered:
        return Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () => _reviewSheet(context),
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
      case OrderStatus.refunded:
        return SizedBox(
          width: double.infinity,
          child: OutlinedButton(
            onPressed: () => context.push(AppRoutes.orderPath(order.id)),
            child: Text(context.l10n.ordersViewDetails),
          ),
        );
    }
  }

  String paymentShort(BuildContext context, OrderEntity o) => switch (o.paymentMethod) {
        PaymentMethod.cashOnDelivery => context.l10n.ordersPaymentCashOnDelivery,
        PaymentMethod.cibCard => context.l10n.ordersPaymentCib,
        PaymentMethod.dahabiCard => context.l10n.ordersPaymentDahabi,
        PaymentMethod.baridimob => context.l10n.ordersPaymentBaridimob,
      };

  String _shortDate(DateTime d) => DateFormat('MMM d, yyyy').format(d);

  String _eta(DateTime d) => DateFormat('EEEE, MMM d').format(d);

  Future<void> _cancelConsumer(
    BuildContext context,
    WidgetRef ref,
    OrdersNotifier notifier,
  ) async {
    final reason = await _cancelReasonDialog(context);
    if (reason == null || !context.mounted) return;
    await notifier.cancelOrder(order.id, reason);
    if (!context.mounted) return;
    _errSnack(context, ref);
  }

  Future<void> _confirmReceipt(
    BuildContext context,
    WidgetRef ref,
    OrdersNotifier notifier,
  ) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(context.l10n.ordersConfirmReceiptTitle),
        content: Text(context.l10n.ordersConfirmReceiptTitle),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(context.l10n.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(context.l10n.ordersConfirm),
          ),
        ],
      ),
    );
    if (ok == true && context.mounted) {
      await notifier.confirmReceipt(order.id);
      if (!context.mounted) return;
      _errSnack(context, ref);
    }
  }

  Future<void> _rejectFlow(
    BuildContext context,
    WidgetRef ref,
    OrdersNotifier notifier,
  ) async {
    final ctrl = TextEditingController();
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(context.l10n.ordersRejectDialogTitle),
        content: TextField(
          controller: ctrl,
          decoration: InputDecoration(hintText: context.l10n.ordersRejectReasonHint),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(context.l10n.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(context.l10n.ordersConfirm),
          ),
        ],
      ),
    );
    final reason = ctrl.text.trim();
    ctrl.dispose();
    if (ok == true && context.mounted) {
      await notifier.rejectOrder(
        order.id,
        reason.isEmpty ? '—' : reason,
      );
      if (!context.mounted) return;
      _errSnack(context, ref);
    }
  }

  Future<void> _shipSheet(
    BuildContext context,
    WidgetRef ref,
    OrdersNotifier notifier,
  ) async {
    final trackCtrl = TextEditingController();
    final courierCtrl = TextEditingController();
    DateTime? eta = DateTime.now().add(const Duration(days: 2));
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(
            left: AppSpacing.lg,
            right: AppSpacing.lg,
            bottom: MediaQuery.paddingOf(ctx).bottom + AppSpacing.lg,
            top: AppSpacing.md,
          ),
          child: StatefulBuilder(
            builder: (context, setS) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(context.l10n.ordersAddTrackingTitle,
                      style: AppTypography.titleMedium),
                  const SizedBox(height: AppSpacing.md),
                  TextField(
                    controller: trackCtrl,
                    decoration: InputDecoration(
                      labelText: context.l10n.ordersTrackingNumberLabel,
                    ),
                  ),
                  TextField(
                    controller: courierCtrl,
                    decoration: InputDecoration(
                      labelText: context.l10n.ordersCourierNameLabel,
                    ),
                  ),
                  ListTile(
                    title: Text(context.l10n.ordersEstimatedDeliveryLabel),
                    subtitle: Text(
                      eta != null ? _shortDate(eta!) : '—',
                    ),
                    trailing: const Icon(Icons.calendar_today_outlined),
                    onTap: () async {
                      final d = await showDatePicker(
                        context: context,
                        initialDate: eta ?? DateTime.now(),
                        firstDate: DateTime.now(),
                        lastDate: DateTime.now().add(const Duration(days: 365)),
                      );
                      if (!context.mounted) return;
                      if (d != null) setS(() => eta = d);
                    },
                  ),
                  const SizedBox(height: AppSpacing.md),
                  FilledButton(
                    onPressed: () async {
                      Navigator.pop(ctx);
                      await notifier.markShipped(
                        order.id,
                        ShippingInfo(
                          trackingNumber: trackCtrl.text.trim().isEmpty
                              ? null
                              : trackCtrl.text.trim(),
                          courierName: courierCtrl.text.trim().isEmpty
                              ? null
                              : courierCtrl.text.trim(),
                          estimatedDelivery: eta,
                        ),
                      );
                    },
                    child: Text(context.l10n.ordersConfirmShipment),
                  ),
                ],
              );
            },
          ),
        );
      },
    );
    trackCtrl.dispose();
    courierCtrl.dispose();
    if (context.mounted) _errSnack(context, ref);
  }

  void _trackingSnack(BuildContext context) {
    AppSnackbar.show(
      context,
      message:
          order.trackingNumber ?? context.l10n.ordersTrackOnCourier,
    );
  }

  void _reviewSheet(BuildContext context) {
    var stars = 5;
    final text = TextEditingController();
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setS) {
            return Padding(
              padding: EdgeInsets.only(
                left: AppSpacing.lg,
                right: AppSpacing.lg,
                bottom: MediaQuery.paddingOf(ctx).bottom + AppSpacing.lg,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(context.l10n.ordersReviewSheetTitle,
                      style: AppTypography.titleMedium),
                  const SizedBox(height: AppSpacing.md),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      5,
                      (i) => IconButton(
                        onPressed: () => setS(() => stars = i + 1),
                        icon: Icon(
                          i < stars ? Icons.star : Icons.star_border,
                          color: AppColors.warning,
                          size: AppSpacing.x3l,
                        ),
                      ),
                    ),
                  ),
                  TextField(
                    controller: text,
                    maxLines: 4,
                    decoration: InputDecoration(
                      hintText: context.l10n.ordersReviewHint,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  FilledButton(
                    onPressed: () {
                      Navigator.pop(ctx);
                      AppSnackbar.success(
                        context,
                        context.l10n.ordersReviewThanks,
                      );
                    },
                    child: Text(context.l10n.ordersSubmitReview),
                  ),
                ],
              ),
            );
          },
        );
      },
    ).whenComplete(text.dispose);
  }

  Future<String?> _cancelReasonDialog(BuildContext context) async {
    var selected = context.l10n.ordersCancelReasonChangedMind;
    return showDialog<String>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setS) {
          return AlertDialog(
            title: Text(context.l10n.ordersCancelDialogTitle),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  context.l10n.ordersCancelReasonLabel,
                  style: AppTypography.labelLarge,
                ),
                const SizedBox(height: AppSpacing.sm),
                DropdownButton<String>(
                  isExpanded: true,
                  value: selected,
                  items: [
                    context.l10n.ordersCancelReasonChangedMind,
                    context.l10n.ordersCancelReasonBetterPrice,
                    context.l10n.ordersCancelReasonMistake,
                    context.l10n.ordersCancelReasonOther,
                  ]
                      .map(
                        (e) => DropdownMenuItem(value: e, child: Text(e)),
                      )
                      .toList(),
                  onChanged: (v) {
                    if (v != null) setS(() => selected = v);
                  },
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: Text(context.l10n.cancel),
              ),
              FilledButton(
                onPressed: () => Navigator.pop(ctx, selected),
                child: Text(context.l10n.ordersConfirm),
              ),
            ],
          );
        },
      ),
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
