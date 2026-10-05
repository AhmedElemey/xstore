import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_spacing.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/utils/extensions/context_extensions.dart';
import '../../../auth/domain/entities/user_entity.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../domain/entities/order_entity.dart'
    show DeliveryMethod, OrderEntity, OrderStatus;
import '../providers/order_detail_provider.dart';
import 'delivery_method_sheet.dart';
import 'order_flow_sheets.dart';
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
                        final ok = await showRejectReasonDialog(context);
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
                    : () async {
                        final method = await showModalBottomSheet<DeliveryMethod>(
                          context: context,
                          isScrollControlled: true,
                          builder: (_) => const DeliveryMethodSheet(),
                        );
                        if (method == null || !context.mounted) return;
                        await _run(
                          context,
                          ref,
                          orderId,
                          () => notifier.confirmOrderVendor(method),
                        );
                      },
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
        return XstoreButton(
          label: context.l10n.ordersMarkDelivered,
          isLoading: busy,
          onPressed: busy
              ? null
              : () => _run(context, ref, orderId, notifier.markDeliveredVendor),
        );
      case OrderStatus.delivered:
      case OrderStatus.cancelled:
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
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            OutlinedButton.icon(
              onPressed: busy
                  ? null
                  : () async {
                      await notifier.updateDeliveryLocation();
                      if (!context.mounted) return;
                      final e =
                          ref.read(orderDetailNotifierProvider(orderId)).error;
                      if (e == 'locationServiceDisabled') {
                        AppSnackbar.error(
                          context,
                          context.l10n.locationServiceDisabled,
                        );
                        ref
                            .read(orderDetailNotifierProvider(orderId).notifier)
                            .clearError();
                      } else if (e == 'locationPermissionDenied') {
                        AppSnackbar.error(
                          context,
                          context.l10n.locationPermissionDenied,
                        );
                        ref
                            .read(orderDetailNotifierProvider(orderId).notifier)
                            .clearError();
                      } else if (e != null) {
                        _err(context, ref, orderId);
                      } else {
                        AppSnackbar.success(
                          context,
                          context.l10n.ordersDeliveryLocationUpdated,
                        );
                      }
                    },
              icon: const Icon(Icons.my_location, size: 18),
              label: Text(context.l10n.ordersUpdateDeliveryLocation),
            ),
            const SizedBox(height: AppSpacing.sm),
            OutlinedButton(
              onPressed: busy
                  ? null
                  : () async {
                      final r = await showCancelReasonDialog(context);
                      if (r != null && context.mounted) {
                        await notifier.cancelOrder(r);
                        if (!context.mounted) return;
                        _err(context, ref, orderId);
                      }
                    },
              child: Text(context.l10n.ordersCancelOrder),
            ),
          ],
        );
      case OrderStatus.shipped:
        final compact = ButtonStyle(
          visualDensity: VisualDensity.compact,
          padding: const WidgetStatePropertyAll(
            EdgeInsets.symmetric(horizontal: AppSpacing.sm),
          ),
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        );
        return SizedBox(
          width: double.infinity,
          child: OutlinedButton(
            style: compact,
            onPressed: busy
                ? null
                : () => AppSnackbar.show(
                      context,
                      message: order.trackingNumber ??
                          context.l10n.ordersTrackOnCourier,
                    ),
            child: Text(
              context.l10n.ordersTrackOrder,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
            ),
          ),
        );
      case OrderStatus.delivered:
        return Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed:
                    busy ? null : () => showOrderReviewFlow(context, ref, order),
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

  Future<void> _ship(
    BuildContext context,
    WidgetRef ref,
    String id,
    OrderDetailNotifier notifier,
  ) async {
    final info = await showShipOrderSheet(context);
    if (info == null || !context.mounted) return;
    await _run(context, ref, id, () => notifier.markShipped(info));
  }
}
