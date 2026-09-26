import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/analytics/analytics_service.dart';
import '../../../../core/analytics/event_names.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/router/app_routes.dart';
import '../../../product/domain/entities/review_write_params.dart';
import '../../../product/presentation/providers/product_dependencies.dart';
import '../../../product/presentation/providers/product_detail_notifier.dart';
import '../../../product/presentation/widgets/already_reviewed_sheet.dart';
import '../../domain/entities/order_entity.dart';
import '../providers/orders_provider.dart';
import 'delivery_method_sheet.dart';
import 'order_status_badge.dart';
import '../../../../core/utils/extensions/context_extensions.dart';
import '../../../../shared/widgets/app_cached_network_image.dart';
import '../../../../shared/widgets/app_snackbar.dart';
import '../../../../shared/widgets/orbit_widgets.dart';

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
    final itemCount = order.items.fold<int>(0, (n, i) => n + i.quantity);
    final accent = orderStatusColor(order.status);
    final live = order.status != OrderStatus.delivered &&
        order.status != OrderStatus.cancelled;
    final who = isVendor
        ? order.consumerName
        : (order.vendorStoreName.isNotEmpty
            ? order.vendorStoreName
            : order.vendorName);

    // Orbit order card: status pill and number, thumbnail with store (or
    // buyer) and date, amber total, and a five-step trail while in flight.
    return GlassCard(
      radius: 22,
      padding: const EdgeInsets.all(AppSpacing.lg),
      borderColor: live ? accent.withValues(alpha: 0.45) : null,
      onTap: () => context.push(AppRoutes.orderPath(order.id)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm + 2,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: 0.16),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  orderStatusLabel(context, order.status).toUpperCase(),
                  style: AppTypography.labelSmall.copyWith(
                    color: accent,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.6,
                  ),
                ),
              ),
              const Spacer(),
              Text(
                '#${order.formattedOrderId}',
                style: AppTypography.labelMedium.copyWith(
                  color: context.textSecondary,
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: SizedBox(
                  width: 56,
                  height: 56,
                  child: first != null && first.listingImage.isNotEmpty
                      ? AppCachedNetworkImage(
                          imageUrl: first.listingImage,
                          fit: BoxFit.cover,
                          memCacheWidth: 168,
                          memCacheHeight: 168,
                        )
                      : DecoratedBox(
                          decoration: BoxDecoration(
                            gradient: orbitOrbGradient(order.id.hashCode),
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
                      who,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.bodyLarge.copyWith(
                        fontWeight: FontWeight.w800,
                        color: context.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      context.l10n.ordersCardItemsDate(
                        itemCount,
                        _shortDate(context, order.createdAt),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.bodySmall.copyWith(
                        color: context.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Text(
                context.formatCurrency(order.total),
                style: AppTypography.bodyLarge.copyWith(
                  color: context.cashColor,
                  fontWeight: FontWeight.w800,
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
              ),
            ],
          ),
          if (live) ...[
            const SizedBox(height: AppSpacing.md),
            _Trail(step: _step(order.status), color: accent),
          ],
          const SizedBox(height: AppSpacing.md),
          _actions(context, ref, notifier),
        ],
      ),
    );
  }

  static int _step(OrderStatus s) => switch (s) {
        OrderStatus.pending => 0,
        OrderStatus.confirmed => 1,
        OrderStatus.processing => 2,
        OrderStatus.shipped => 3,
        OrderStatus.delivered || OrderStatus.cancelled => 4,
      };

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
                  onPressed: () async {
                    final method = await showModalBottomSheet<DeliveryMethod>(
                      context: context,
                      isScrollControlled: true,
                      builder: (_) => const DeliveryMethodSheet(),
                    );
                    if (method == null) return;
                    await notifier.confirmOrderVendor(order.id, method);
                  },
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
            child: FilledButton(
              onPressed: () => notifier.markDelivered(order.id),
              child: Text(context.l10n.ordersMarkDelivered),
            ),
          );
        case OrderStatus.delivered:
        case OrderStatus.cancelled:
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
                onPressed: () => _reviewSheet(context, ref),
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

  String paymentShort(BuildContext context, OrderEntity o) => switch (o.paymentMethod) {
        PaymentMethod.cashOnDelivery => context.l10n.ordersPaymentCashOnDelivery,
        PaymentMethod.cibCard => context.l10n.ordersPaymentCib,
        PaymentMethod.dahabiCard => context.l10n.ordersPaymentDahabi,
        PaymentMethod.baridimob => context.l10n.ordersPaymentBaridimob,
      };

  String _shortDate(BuildContext context, DateTime d) =>
      DateFormat('MMM d, yyyy', context.l10n.localeName).format(d);

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

  Future<void> _rejectFlow(
    BuildContext context,
    WidgetRef ref,
    OrdersNotifier notifier,
  ) async {
    // No TextEditingController: a controller disposed right after
    // showDialog's Future resolves races the dialog's own exit transition,
    // which still has a live TextField/EditableText referencing it —
    // "A TextEditingController was used after being disposed."
    var reasonText = '';
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(context.l10n.ordersRejectDialogTitle),
        content: TextField(
          onChanged: (v) => reasonText = v,
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
    final reason = reasonText.trim();
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
    // No TextEditingControllers: disposing them right after
    // showModalBottomSheet's Future resolves races the sheet's own exit
    // transition, which still has live TextFields/EditableTexts
    // referencing them — "A TextEditingController was used after being
    // disposed." Same fix as _rejectFlow's dialog above.
    var trackingNumber = '';
    var courierName = '';
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
                    onChanged: (v) => trackingNumber = v,
                    decoration: InputDecoration(
                      labelText: context.l10n.ordersTrackingNumberLabel,
                    ),
                  ),
                  TextField(
                    onChanged: (v) => courierName = v,
                    decoration: InputDecoration(
                      labelText: context.l10n.ordersCourierNameLabel,
                    ),
                  ),
                  ListTile(
                    title: Text(context.l10n.ordersEstimatedDeliveryLabel),
                    subtitle: Text(
                      eta != null ? _shortDate(context, eta!) : '—',
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
                          trackingNumber: trackingNumber.trim().isEmpty
                              ? null
                              : trackingNumber.trim(),
                          courierName: courierName.trim().isEmpty
                              ? null
                              : courierName.trim(),
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
    if (context.mounted) _errSnack(context, ref);
  }

  void _trackingSnack(BuildContext context) {
    AppSnackbar.show(
      context,
      message:
          order.trackingNumber ?? context.l10n.ordersTrackOnCourier,
    );
  }

  Future<void> _reviewSheet(BuildContext context, WidgetRef ref) async {
    final listingId =
        order.items.isEmpty ? null : order.items.first.listingId;
    if (listingId == null || listingId.isEmpty) return;
    final existing = await findMyListingReview(ref, listingId);
    if (!context.mounted) return;
    if (existing != null) {
      await showAlreadyReviewedSheet(
        context,
        onEdit: () {
          if (!context.mounted) return;
          context.push('${AppRoutes.product}/$listingId/reviews');
        },
      );
      return;
    }

    var stars = 5;
    var reviewText = '';
    final result = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (sheetContext, setS) {
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
                  Text(sheetContext.l10n.ordersReviewSheetTitle,
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
                    onChanged: (v) => reviewText = v,
                    maxLines: 4,
                    decoration: InputDecoration(
                      hintText: sheetContext.l10n.ordersReviewHint,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  FilledButton(
                    onPressed: () async {
                      final comment = reviewText.trim();
                      if (comment.isEmpty) return;
                      final posted =
                          await ref.read(createReviewUseCaseProvider).call(
                        listingId: listingId,
                        params: ReviewWriteParams(
                          rating: stars.toDouble(),
                          comment: comment,
                        ),
                      );
                      if (!sheetContext.mounted) return;
                      posted.fold(
                        (failure) {
                          if (isAlreadyReviewedFailure(failure)) {
                            Navigator.pop(ctx, 'already');
                            return;
                          }
                          AppSnackbar.error(
                            sheetContext,
                            failure.toString(),
                          );
                        },
                        (_) {
                          ref.read(analyticsServiceProvider).track(
                            AnalyticsEvents.reviewSubmitted,
                            properties: {
                              AnalyticsProps.itemId: listingId,
                              AnalyticsProps.rating: stars.toDouble(),
                            },
                          );
                          stars = 5;
                          reviewText = '';
                          Navigator.pop(ctx, 'added');
                          ref.invalidate(productDetailProvider(listingId));
                        },
                      );
                    },
                    child: Text(sheetContext.l10n.ordersSubmitReview),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
    if (!context.mounted) return;
    if (result == 'added') {
      AppSnackbar.success(context, context.l10n.ordersReviewThanks);
    } else if (result == 'already') {
      await showAlreadyReviewedSheet(context);
    }
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

/// Five short segments, lit up to the order's current step.
class _Trail extends StatelessWidget {
  const _Trail({required this.step, required this.color});

  final int step;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return ExcludeSemantics(
      child: Row(
        children: [
          for (var i = 0; i < 5; i++) ...[
            if (i > 0) const SizedBox(width: 4),
            Expanded(
              child: Container(
                height: 4,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(2),
                  color: i <= step
                      ? color
                      : context.textSecondary.withValues(alpha: 0.18),
                  boxShadow: i == step
                      ? [BoxShadow(color: color.withValues(alpha: 0.7), blurRadius: 8)]
                      : null,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
