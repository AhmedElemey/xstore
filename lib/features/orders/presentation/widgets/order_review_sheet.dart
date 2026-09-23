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
import '../../../../shared/widgets/xstore_button.dart';
import '../../../product/domain/entities/review_write_params.dart';
import '../../../product/presentation/providers/product_dependencies.dart';
import '../../../product/presentation/providers/product_detail_notifier.dart';
import '../../../product/presentation/widgets/already_reviewed_sheet.dart';
import '../../domain/entities/order_entity.dart';

/// "Leave a review" for a delivered order, shared by [OrderCard] and
/// [OrderActionButtons]. Reviews attach to the order's (single) listing.
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

  final result = await showModalBottomSheet<String>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (_) => _OrderReviewSheet(listingId: listingId),
  );
  if (!context.mounted) return;
  if (result == 'added') {
    AppSnackbar.success(context, context.l10n.ordersReviewThanks);
  } else if (result == 'already') {
    await showAlreadyReviewedSheet(context);
  }
}

class _OrderReviewSheet extends ConsumerStatefulWidget {
  const _OrderReviewSheet({required this.listingId});

  final String listingId;

  @override
  ConsumerState<_OrderReviewSheet> createState() => _OrderReviewSheetState();
}

class _OrderReviewSheetState extends ConsumerState<_OrderReviewSheet> {
  var _stars = 5;
  // No TextEditingController: the value is only read on submit (see the
  // dialog-controller lessons in the flutter-review skill).
  var _comment = '';
  var _posting = false;

  Future<void> _submit() async {
    final comment = _comment.trim();
    if (comment.isEmpty || _posting) return;
    setState(() => _posting = true);
    final posted = await ref
        .read(createReviewUseCaseProvider)
        .call(
          listingId: widget.listingId,
          params: ReviewWriteParams(
            rating: _stars.toDouble(),
            comment: comment,
          ),
        );
    if (!mounted) return;
    posted.fold(
      (failure) {
        if (isAlreadyReviewedFailure(failure)) {
          Navigator.pop(context, 'already');
          return;
        }
        setState(() => _posting = false);
        AppSnackbar.error(context, failure.toString());
      },
      (_) {
        ref
            .read(analyticsServiceProvider)
            .track(
              AnalyticsEvents.reviewSubmitted,
              properties: {
                AnalyticsProps.itemId: widget.listingId,
                AnalyticsProps.rating: _stars.toDouble(),
              },
            );
        ref.invalidate(productDetailProvider(widget.listingId));
        Navigator.pop(context, 'added');
      },
    );
  }

  @override
  Widget build(BuildContext context) {
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
          Text(
            context.l10n.ordersReviewSheetTitle,
            style: AppTypography.titleMedium,
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              5,
              (i) => IconButton(
                onPressed: _posting
                    ? null
                    : () => setState(() => _stars = i + 1),
                icon: Icon(
                  i < _stars ? Icons.star : Icons.star_border,
                  color: AppColors.warning,
                  size: AppSpacing.x3l,
                ),
              ),
            ),
          ),
          TextField(
            enabled: !_posting,
            onChanged: (v) => _comment = v,
            maxLines: 4,
            decoration: InputDecoration(
              hintText: context.l10n.ordersReviewHint,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          XstoreButton(
            label: context.l10n.ordersSubmitReview,
            isLoading: _posting,
            onPressed: _posting ? null : _submit,
          ),
        ],
      ),
    );
  }
}

/// Buyer cancel-reason picker, shared by [OrderCard] and
/// [OrderActionButtons]. Returns the chosen (localized) reason, or null.
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
                items:
                    [
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
