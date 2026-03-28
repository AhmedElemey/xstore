import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/router/app_routes.dart';
import '../../../auth/domain/entities/user_entity.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../domain/entities/order_entity.dart'
    show OrderEntity, OrderStatus, ShippingInfo;
import '../providers/order_detail_provider.dart';

/// Sticky footer actions on order detail — routes actions to [OrderDetailNotifier].
class OrderActionButtons extends ConsumerWidget {
  const OrderActionButtons({
    super.key,
    required this.orderId,
    required this.order,
  });

  final String orderId;
  final OrderEntity order;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final detail = ref.watch(orderDetailNotifierProvider(orderId));
    final notifier = ref.read(orderDetailNotifierProvider(orderId).notifier);
    final isVendor =
        ref.watch(authProvider).valueOrNull?.role == UserRole.vendor;
    final busy = detail.isActioning;

    if (isVendor) {
      return _vendor(context, ref, notifier, busy);
    }
    return _consumer(context, ref, notifier, busy);
  }

  Widget _vendor(
    BuildContext context,
    WidgetRef ref,
    OrderDetailNotifier notifier,
    bool busy,
  ) {
    switch (order.status) {
      case OrderStatus.pending:
        return Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: busy
                    ? null
                    : () async {
                        final ok = await _rejectDialog(context);
                        if (ok != null && context.mounted) {
                          await notifier.rejectOrder(ok);
                          if (!context.mounted) return;
                          _err(context, ref, orderId);
                        }
                      },
                child: Text(AppStrings.ordersRejectOrder),
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: FilledButton(
                onPressed: busy
                    ? null
                    : () => _run(context, ref, orderId, notifier.confirmOrderVendor),
                child: Text(AppStrings.ordersConfirmOrderCta),
              ),
            ),
          ],
        );
      case OrderStatus.confirmed:
        return SizedBox(
          width: double.infinity,
          child: FilledButton(
            onPressed: busy
                ? null
                : () => _run(context, ref, orderId, notifier.markProcessing),
            child: Text(AppStrings.ordersMarkProcessing),
          ),
        );
      case OrderStatus.processing:
        return SizedBox(
          width: double.infinity,
          child: FilledButton(
            onPressed: busy
                ? null
                : () => _ship(context, ref, orderId, notifier),
            child: Text(AppStrings.ordersMarkShipped),
          ),
        );
      case OrderStatus.shipped:
      case OrderStatus.delivered:
      case OrderStatus.cancelled:
      case OrderStatus.refunded:
        return const SizedBox.shrink();
    }
  }

  Widget _consumer(
    BuildContext context,
    WidgetRef ref,
    OrderDetailNotifier notifier,
    bool busy,
  ) {
    switch (order.status) {
      case OrderStatus.pending:
      case OrderStatus.confirmed:
        return SizedBox(
          width: double.infinity,
          child: OutlinedButton(
            onPressed: busy
                ? null
                : () async {
                    final r = await _cancelReason(context);
                    if (r != null && context.mounted) {
                      await notifier.cancelOrder(r);
                      if (!context.mounted) return;
                      _err(context, ref, orderId);
                    }
                  },
            child: Text(AppStrings.ordersCancelOrder),
          ),
        );
      case OrderStatus.shipped:
        return Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: busy
                    ? null
                    : () => ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              order.trackingNumber ??
                                  AppStrings.ordersTrackOnCourier,
                            ),
                          ),
                        ),
                child: Text(AppStrings.ordersTrackOrder),
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: FilledButton(
                onPressed: busy
                    ? null
                    : () async {
                        final ok = await _confirmReceiptDlg(context);
                        if (ok == true && context.mounted) {
                          await notifier.confirmReceipt();
                          if (!context.mounted) return;
                          _err(context, ref, orderId);
                        }
                      },
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
                onPressed: busy ? null : () => _review(context),
                child: Text(AppStrings.ordersLeaveReview),
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: FilledButton(
                onPressed: busy
                    ? null
                    : () async {
                        await notifier.reorder();
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
          child: FilledButton(
            onPressed: () => context.go(AppRoutes.explore),
            child: Text(AppStrings.ordersShopAgain),
          ),
        );
      case OrderStatus.processing:
      case OrderStatus.refunded:
        return const SizedBox.shrink();
    }
  }

  Future<void> _run(
    BuildContext context,
    WidgetRef ref,
    String id,
    Future<void> Function() action,
  ) async {
    await action();
    if (!context.mounted) return;
    _err(context, ref, id);
  }

  void _err(BuildContext context, WidgetRef ref, String id) {
    final e = ref.read(orderDetailNotifierProvider(id)).error;
    if (e != null && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e)));
      ref.read(orderDetailNotifierProvider(id).notifier).clearError();
    }
  }

  Future<String?> _rejectDialog(BuildContext context) async {
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
    if (ok == true) return ctrl.text.trim().isEmpty ? '—' : ctrl.text.trim();
    return null;
  }

  Future<void> _ship(
    BuildContext context,
    WidgetRef ref,
    String id,
    OrderDetailNotifier notifier,
  ) async {
    final trackCtrl = TextEditingController();
    final courierCtrl = TextEditingController();
    DateTime? eta = DateTime.now().add(const Duration(days: 2));
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setS) {
          return Padding(
            padding: EdgeInsets.only(
              left: AppSpacing.lg,
              right: AppSpacing.lg,
              bottom: MediaQuery.paddingOf(context).bottom + AppSpacing.lg,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(AppStrings.ordersAddTrackingTitle,
                    style: AppTypography.titleMedium),
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
                  subtitle: Text(eta != null ? '${eta!.toLocal()}' : '—'),
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
                FilledButton(
                  onPressed: () async {
                    Navigator.pop(ctx);
                    await notifier.markShipped(
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
            ),
          );
        },
      ),
    );
    if (context.mounted) _err(context, ref, id);
  }

  Future<String?> _cancelReason(BuildContext context) async {
    var selected = AppStrings.ordersCancelReasonChangedMind;
    return showDialog<String>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setS) {
          return AlertDialog(
            title: Text(AppStrings.ordersCancelDialogTitle),
            content: DropdownButton<String>(
              isExpanded: true,
              value: selected,
              items: [
                AppStrings.ordersCancelReasonChangedMind,
                AppStrings.ordersCancelReasonBetterPrice,
                AppStrings.ordersCancelReasonMistake,
                AppStrings.ordersCancelReasonOther,
              ].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
              onChanged: (v) {
                if (v != null) setS(() => selected = v);
              },
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

  Future<bool?> _confirmReceiptDlg(BuildContext context) {
    return showDialog<bool>(
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
  }

  void _review(BuildContext context) {
    var stars = 5;
    final text = TextEditingController();
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setS) {
          return Padding(
            padding: EdgeInsets.only(
              left: AppSpacing.lg,
              right: AppSpacing.lg,
              bottom: MediaQuery.paddingOf(context).bottom + AppSpacing.lg,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(AppStrings.ordersReviewSheetTitle,
                    style: AppTypography.titleMedium),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    5,
                    (i) => IconButton(
                      onPressed: () => setS(() => stars = i + 1),
                      icon: Icon(
                        i < stars ? Icons.star : Icons.star_border,
                        color: AppColors.warning,
                      ),
                    ),
                  ),
                ),
                TextField(
                  controller: text,
                  maxLines: 3,
                  decoration: InputDecoration(hintText: AppStrings.ordersReviewHint),
                ),
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
      ),
    );
  }
}
