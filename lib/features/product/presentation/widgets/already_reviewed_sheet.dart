import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_spacing.dart';
import '../../../../core/utils/extensions/context_extensions.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../domain/entities/review_entity.dart';
import '../providers/product_dependencies.dart';

Future<ReviewEntity?> findMyListingReview(
  WidgetRef ref,
  String listingId,
) async {
  final viewer = ref.read(authProvider).valueOrNull;
  final result = await ref.read(getProductReviewsUseCaseProvider).call(
        productId: listingId,
        page: 0,
        pageSize: 20,
      );
  return result.fold((_) => null, (page) {
    for (final r in page.items) {
      if (isOwnReview(r, userId: viewer?.id, email: viewer?.email)) {
        return r;
      }
    }
    return null;
  });
}

bool isAlreadyReviewedFailure(Object failure) =>
    failure.toString().toLowerCase().contains('already');

/// Tells the buyer they already left a review for this listing.
Future<void> showAlreadyReviewedSheet(
  BuildContext context, {
  VoidCallback? onEdit,
}) {
  return showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    builder: (ctx) {
      return SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.lg,
            AppSpacing.md,
            AppSpacing.lg,
            AppSpacing.lg,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                ctx.l10n.alreadyReviewedTitle,
                style: Theme.of(ctx).textTheme.titleMedium,
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(ctx.l10n.alreadyReviewedMessage),
              const SizedBox(height: AppSpacing.lg),
              if (onEdit != null) ...[
                FilledButton(
                  onPressed: () {
                    Navigator.pop(ctx);
                    onEdit();
                  },
                  child: Text(ctx.l10n.editReview),
                ),
                const SizedBox(height: AppSpacing.sm),
              ],
              OutlinedButton(
                onPressed: () => Navigator.pop(ctx),
                child: Text(ctx.l10n.cancel),
              ),
            ],
          ),
        ),
      );
    },
  );
}
