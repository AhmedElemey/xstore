import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/analytics/analytics_service.dart';
import '../../../../core/analytics/event_names.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/utils/extensions/context_extensions.dart';
import '../../../../shared/widgets/app_snackbar.dart';
import '../../../product/domain/entities/review_write_params.dart';
import '../../../product/presentation/providers/product_dependencies.dart';
import '../../../product/presentation/providers/product_detail_notifier.dart';
import '../../../product/presentation/widgets/already_reviewed_sheet.dart';
import '../../domain/entities/order_entity.dart' show OrderEntity, ShippingInfo;

// Order action flows shared by OrderCard (orders list) and
// OrderActionButtons (order detail). Each returns what the user entered;
// the caller runs its own notifier call and shows its own snackbars.

/// The consumer's cancel reason, or null when the dialog is dismissed.
Future<String?> showCancelReasonDialog(BuildContext context) {
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
                    .map((e) => DropdownMenuItem(value: e, child: Text(e)))
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

/// The vendor's reject reason ('—' when left blank), or null when the
/// dialog is cancelled or dismissed.
Future<String?> showRejectReasonDialog(BuildContext context) async {
  // No TextEditingController, for the same reason as showShipOrderSheet.
  var reasonText = '';
  final ok = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: Text(context.l10n.ordersRejectDialogTitle),
      content: TextField(
        onChanged: (v) => reasonText = v,
        decoration:
            InputDecoration(hintText: context.l10n.ordersRejectReasonHint),
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
  if (ok != true) return null;
  final reason = reasonText.trim();
  return reason.isEmpty ? '—' : reason;
}

/// The tracking details the vendor entered, or null when the sheet is
/// dismissed without confirming.
Future<ShippingInfo?> showShipOrderSheet(BuildContext context) {
  // No TextEditingControllers: disposing them right after
  // showModalBottomSheet's Future resolves races the sheet's own exit
  // transition, which still has live TextFields/EditableTexts referencing
  // them — "A TextEditingController was used after being disposed."
  var trackingNumber = '';
  var courierName = '';
  DateTime? eta = DateTime.now().add(const Duration(days: 2));
  return showModalBottomSheet<ShippingInfo>(
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
                Text(
                  context.l10n.ordersAddTrackingTitle,
                  style: AppTypography.titleMedium,
                ),
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
                    eta != null ? context.formatMediumDate(eta!) : '—',
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
                  onPressed: () {
                    final tracking = trackingNumber.trim();
                    final courier = courierName.trim();
                    Navigator.pop(
                      ctx,
                      ShippingInfo(
                        trackingNumber: tracking.isEmpty ? null : tracking,
                        courierName: courier.isEmpty ? null : courier,
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
}

/// Leave-review flow for the order's first listing. Unlike the flows above
/// it submits from inside the sheet, so a failed post keeps the typed review
/// on screen (the sheet pops only on success or "already reviewed").
Future<void> showOrderReviewFlow(
  BuildContext context,
  WidgetRef ref,
  OrderEntity order,
) async {
  final listingId = order.items.isEmpty ? null : order.items.first.listingId;
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

  final createReview = ref.read(createReviewUseCaseProvider);
  final analytics = ref.read(analyticsServiceProvider);
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
                Text(
                  sheetContext.l10n.ordersReviewSheetTitle,
                  style: AppTypography.titleMedium,
                ),
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
                  onChanged: (v) => setS(() => reviewText = v),
                  maxLines: 4,
                  decoration: InputDecoration(
                    hintText: sheetContext.l10n.ordersReviewHint,
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                FilledButton(
                  // A comment is required, so the button stays disabled
                  // until one is typed rather than ignoring taps.
                  onPressed: reviewText.trim().isEmpty
                      ? null
                      : () async {
                          final posted = await createReview(
                            listingId: listingId,
                            params: ReviewWriteParams(
                              rating: stars.toDouble(),
                              comment: reviewText.trim(),
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
                              analytics.track(
                                AnalyticsEvents.reviewSubmitted,
                                properties: {
                                  AnalyticsProps.itemId: listingId,
                                  AnalyticsProps.rating: stars.toDouble(),
                                },
                              );
                              stars = 5;
                              reviewText = '';
                              Navigator.pop(ctx, 'added');
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
    ref.invalidate(productDetailProvider(listingId));
    AppSnackbar.success(context, context.l10n.ordersReviewThanks);
  } else if (result == 'already') {
    await showAlreadyReviewedSheet(context);
  }
}
