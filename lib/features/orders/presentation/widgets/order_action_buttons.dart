import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/utils/extensions/context_extensions.dart';
import '../../../auth/domain/entities/user_entity.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../domain/entities/order_entity.dart'
    show OrderEntity, OrderStatus, ShippingInfo;
import '../providers/order_detail_provider.dart';
import '../../../../shared/widgets/app_snackbar.dart';
import '../../../../shared/widgets/xstore_button.dart';

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
                child: Text(context.l10n.ordersRejectOrder),
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: FilledButton(
                onPressed: busy
                    ? null
                    : () => _run(context, ref, orderId, notifier.confirmOrderVendor),
                child: Text(context.l10n.ordersConfirmOrderCta),
              ),
            ),
          ],
        );
      case OrderStatus.confirmed:
        return XstoreButton(
          label: context.l10n.ordersMarkProcessing,
          isLoading: busy,
          onPressed: busy
              ? null
              : () => _run(context, ref, orderId, notifier.markProcessing),
        );
      case OrderStatus.processing:
        return XstoreButton(
          label: context.l10n.ordersMarkShipped,
          isLoading: busy,
          onPressed: busy ? null : () => _ship(context, ref, orderId, notifier),
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
            child: Text(context.l10n.ordersCancelOrder),
          ),
        );
      case OrderStatus.shipped:
        return Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: busy
                    ? null
                    : () => AppSnackbar.show(
                          context,
                          message: order.trackingNumber ??
                              context.l10n.ordersTrackOnCourier,
                        ),
                child: Text(context.l10n.ordersTrackOrder),
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
                onPressed: busy ? null : () => _review(context),
                child: Text(context.l10n.ordersLeaveReview),
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
                          AppSnackbar.success(
                            context,
                            context.l10n.addedToCart,
                          );
                        }
                      },
                child: Text(context.l10n.ordersReorder),
              ),
            ),
          ],
        );
      case OrderStatus.cancelled:
        return XstoreButton(
          label: context.l10n.ordersShopAgain,
          onPressed: () => context.go(AppRoutes.explore),
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
      AppSnackbar.error(context, e);
      ref.read(orderDetailNotifierProvider(id).notifier).clearError();
    }
  }

  Future<String?> _rejectDialog(BuildContext context) async {
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
                Text(context.l10n.ordersAddTrackingTitle,
                    style: AppTypography.titleMedium),
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
                XstoreButton(
                  label: context.l10n.ordersConfirmShipment,
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
    var selected = context.l10n.ordersCancelReasonChangedMind;
    return showDialog<String>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setS) {
          return AlertDialog(
            title: Text(context.l10n.ordersCancelDialogTitle),
            content: DropdownButton<String>(
              isExpanded: true,
              value: selected,
              items: [
                context.l10n.ordersCancelReasonChangedMind,
                context.l10n.ordersCancelReasonBetterPrice,
                context.l10n.ordersCancelReasonMistake,
                context.l10n.ordersCancelReasonOther,
              ].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
              onChanged: (v) {
                if (v != null) setS(() => selected = v);
              },
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

  Future<bool?> _confirmReceiptDlg(BuildContext context) {
    return showDialog<bool>(
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
                Text(context.l10n.ordersReviewSheetTitle,
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
                  decoration: InputDecoration(hintText: context.l10n.ordersReviewHint),
                ),
                Tooltip(
                  message: context.l10n.placeholderScreenSubtitle,
                  child: XstoreButton(
                    label: context.l10n.ordersSubmitReview,
                    onPressed: null,
                  ),
                ),
                Text(
                  context.l10n.placeholderScreenSubtitle,
                  textAlign: TextAlign.center,
                  style: AppTypography.bodySmall.copyWith(
                    color: context.textSecondary,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
