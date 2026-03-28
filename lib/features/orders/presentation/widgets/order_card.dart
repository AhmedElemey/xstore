import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/router/app_routes.dart';
import '../../domain/entities/order_entity.dart';
import '../providers/orders_provider.dart';
import 'order_status_badge.dart';

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
      color: AppColors.cardBg,
      borderRadius: BorderRadius.circular(AppSpacing.lg),
      elevation: 0,
      shadowColor: AppColors.textPrimary.withValues(alpha: 0.06),
      child: InkWell(
        onTap: () => context.push(AppRoutes.orderPath(order.id)),
        borderRadius: BorderRadius.circular(AppSpacing.lg),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppSpacing.lg),
            boxShadow: [
              BoxShadow(
                color: AppColors.textPrimary.withValues(alpha: 0.06),
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
                      '${AppStrings.orderHashPrefix}${order.formattedOrderId}',
                      style: AppTypography.titleMedium.copyWith(fontSize: 16),
                    ),
                  ),
                  OrderStatusBadge(status: order.status, compact: true),
                ],
              ),
              const Divider(height: AppSpacing.lg),
              if (first != null) ...[
                if (isVendor) ...[
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 30,
                        backgroundImage: order.consumerAvatar.isNotEmpty
                            ? NetworkImage(order.consumerAvatar)
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
                  const Divider(height: AppSpacing.lg),
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
                            ? CachedNetworkImage(
                                imageUrl: first.listingImage,
                                fit: BoxFit.cover,
                              )
                            : Container(
                                color: AppColors.textDisabled
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
                              AppStrings.ordersMoreItems(more),
                              style: AppTypography.bodySmall,
                            ),
                          const SizedBox(height: AppSpacing.xs),
                          Text(
                            '${AppStrings.ordersQtyTotalLinePrefix}: ${first.quantity} · ${_fmt(first.total)} ${AppStrings.currencyDzd}',
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
              const Divider(height: AppSpacing.lg),
              if (!isVendor)
                Text(
                  '📦 ${order.vendorStoreName} · ${_shortDate(order.createdAt)}',
                  style: AppTypography.bodySmall,
                )
              else
                Text(
                  '💳 ${paymentShort(order)} · ${_shortDate(order.createdAt)}',
                  style: AppTypography.bodySmall,
                ),
              if (!isVendor &&
                  (order.status == OrderStatus.shipped ||
                      order.status == OrderStatus.confirmed) &&
                  order.estimatedDelivery != null) ...[
                const SizedBox(height: AppSpacing.xs),
                Text(
                  '${AppStrings.ordersEstimatedDelivery}: ${_eta(order.estimatedDelivery!)}',
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
                  child: Text(AppStrings.ordersRejectOrder),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: FilledButton(
                  onPressed: () => notifier.confirmOrderVendor(order.id),
                  child: Text(AppStrings.ordersConfirmOrderCta),
                ),
              ),
            ],
          );
        case OrderStatus.confirmed:
          return SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: () => notifier.markProcessing(order.id),
              child: Text(AppStrings.ordersMarkProcessing),
            ),
          );
        case OrderStatus.processing:
          return SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: () => _shipSheet(context, ref, notifier),
              child: Text(AppStrings.ordersMarkShipped),
            ),
          );
        case OrderStatus.shipped:
          return SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () => _trackingSnack(context),
              child: Text(AppStrings.ordersViewTracking),
            ),
          );
        case OrderStatus.delivered:
        case OrderStatus.cancelled:
        case OrderStatus.refunded:
          return SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () => context.push(AppRoutes.orderPath(order.id)),
              child: Text(AppStrings.ordersViewDetails),
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
            child: Text(AppStrings.ordersCancelOrder),
          ),
        );
      case OrderStatus.shipped:
        return Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () => _trackingSnack(context),
                child: Text(AppStrings.ordersTrackOrder),
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: FilledButton(
                onPressed: () => _confirmReceipt(context, ref, notifier),
                child: Text(AppStrings.ordersConfirmReceipt),
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
                child: Text(AppStrings.ordersLeaveReview),
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: FilledButton(
                onPressed: () async {
                  await notifier.reorder(order.id);
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(AppStrings.addedToCart)),
                    );
                  }
                },
                child: Text(AppStrings.ordersReorder),
              ),
            ),
          ],
        );
      case OrderStatus.cancelled:
        return SizedBox(
          width: double.infinity,
          child: OutlinedButton(
            onPressed: () => context.push(AppRoutes.orderPath(order.id)),
            child: Text(AppStrings.ordersViewDetails),
          ),
        );
      case OrderStatus.processing:
      case OrderStatus.refunded:
        return SizedBox(
          width: double.infinity,
          child: OutlinedButton(
            onPressed: () => context.push(AppRoutes.orderPath(order.id)),
            child: Text(AppStrings.ordersViewDetails),
          ),
        );
    }
  }

  String paymentShort(OrderEntity o) => switch (o.paymentMethod) {
        PaymentMethod.cashOnDelivery => AppStrings.ordersPaymentCashOnDelivery,
        PaymentMethod.cibCard => AppStrings.ordersPaymentCib,
        PaymentMethod.dahabiCard => AppStrings.ordersPaymentDahabi,
        PaymentMethod.baridimob => AppStrings.ordersPaymentBaridimob,
      };

  String _fmt(double v) =>
      v == v.roundToDouble() ? v.toStringAsFixed(0) : v.toStringAsFixed(2);

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
        title: Text(AppStrings.ordersConfirmReceiptTitle),
        content: Text(AppStrings.ordersConfirmReceiptBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(AppStrings.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(AppStrings.ordersConfirm),
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
        title: Text(AppStrings.ordersRejectDialogTitle),
        content: TextField(
          controller: ctrl,
          decoration: InputDecoration(hintText: AppStrings.ordersRejectReasonHint),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(AppStrings.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(AppStrings.ordersConfirm),
          ),
        ],
      ),
    );
    if (ok == true && context.mounted) {
      await notifier.rejectOrder(
        order.id,
        ctrl.text.trim().isEmpty ? '—' : ctrl.text.trim(),
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
                  Text(AppStrings.ordersAddTrackingTitle,
                      style: AppTypography.titleMedium),
                  const SizedBox(height: AppSpacing.md),
                  TextField(
                    controller: trackCtrl,
                    decoration: InputDecoration(
                      labelText: AppStrings.ordersTrackingNumberLabel,
                    ),
                  ),
                  TextField(
                    controller: courierCtrl,
                    decoration: InputDecoration(
                      labelText: AppStrings.ordersCourierNameLabel,
                    ),
                  ),
                  ListTile(
                    title: Text(AppStrings.ordersEstimatedDeliveryLabel),
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
                    child: Text(AppStrings.ordersConfirmShipment),
                  ),
                ],
              );
            },
          ),
        );
      },
    );
    if (context.mounted) _errSnack(context, ref);
  }

  void _trackingSnack(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          order.trackingNumber ?? AppStrings.ordersTrackOnCourier,
        ),
      ),
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
                  Text(AppStrings.ordersReviewSheetTitle,
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
                      hintText: AppStrings.ordersReviewHint,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  FilledButton(
                    onPressed: () {
                      Navigator.pop(ctx);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(AppStrings.ordersReviewThanks)),
                      );
                    },
                    child: Text(AppStrings.ordersSubmitReview),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Future<String?> _cancelReasonDialog(BuildContext context) async {
    var selected = AppStrings.ordersCancelReasonChangedMind;
    return showDialog<String>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setS) {
          return AlertDialog(
            title: Text(AppStrings.ordersCancelDialogTitle),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  AppStrings.ordersCancelReasonLabel,
                  style: AppTypography.labelLarge,
                ),
                const SizedBox(height: AppSpacing.sm),
                DropdownButton<String>(
                  isExpanded: true,
                  value: selected,
                  items: [
                    AppStrings.ordersCancelReasonChangedMind,
                    AppStrings.ordersCancelReasonBetterPrice,
                    AppStrings.ordersCancelReasonMistake,
                    AppStrings.ordersCancelReasonOther,
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
                child: Text(AppStrings.cancel),
              ),
              FilledButton(
                onPressed: () => Navigator.pop(ctx, selected),
                child: Text(AppStrings.ordersConfirm),
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
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(err)));
      ref.read(ordersNotifierProvider.notifier).clearError();
    }
  }
}
