import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/utils/extensions/context_extensions.dart';
import '../../../listing/domain/entities/listing_entity.dart';

class ProductHeader extends StatelessWidget {
  const ProductHeader({
    super.key,
    required this.listing,
    this.compareAtPrice,
    required this.onTapReviews,
    this.locationLine = '',
    this.ratingLabel,
    this.reviewCountLabel,
  });

  final ListingEntity listing;
  final double? compareAtPrice;
  final VoidCallback onTapReviews;
  final String locationLine;
  final String? ratingLabel;
  final String? reviewCountLabel;

  @override
  Widget build(BuildContext context) {
    final price = listing.price;
    final hasCompare =
        compareAtPrice != null && compareAtPrice! > price + 0.009;
    final discount = hasCompare
        ? ((compareAtPrice! - price) / compareAtPrice! * 100).round()
        : 0;
    final hasRating = ratingLabel != null && reviewCountLabel != null;
    final captionStyle = AppTypography.body12.copyWith(
      fontSize: 13,
      color: context.labelColor,
    );

    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(
        AppSpacing.xl,
        AppSpacing.x2l,
        AppSpacing.xl,
        AppSpacing.lg,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (listing.categoryLabel.isNotEmpty) ...[
                      Text(listing.categoryLabel, style: captionStyle),
                      const Gap(6),
                    ],
                    Text(
                      listing.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.headlineSmall.copyWith(
                        fontSize: 22,
                        color: context.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
              const Gap(AppSpacing.md),
              // Amounts the customer pays: amber, mono digits.
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    context.formatCurrency(price),
                    style: AppTypography.mono.copyWith(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: context.amberColor,
                    ),
                  ),
                  if (hasCompare) ...[
                    const Gap(AppSpacing.xs),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.sm,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: context.amberColor.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(AppSpacing.md),
                          ),
                          child: Text(
                            '-$discount%',
                            style: AppTypography.mono.copyWith(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: context.amberColor,
                            ),
                          ),
                        ),
                        const Gap(AppSpacing.sm),
                        Text(
                          context.formatCurrency(compareAtPrice!),
                          style: AppTypography.mono.copyWith(
                            fontSize: 13,
                            decoration: TextDecoration.lineThrough,
                            color: context.labelColor,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ],
          ),
          if (listing.conditionLabel.isNotEmpty || locationLine.isNotEmpty) ...[
            const Gap(AppSpacing.md),
            Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.sm,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                if (listing.conditionLabel.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.md,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: context.glassColor,
                      borderRadius: BorderRadius.circular(AppSpacing.lg),
                      border: Border.all(color: context.borderColor),
                    ),
                    child: Text(
                      listing.conditionLabel,
                      style: AppTypography.labelMedium.copyWith(
                        fontWeight: FontWeight.w700,
                        color: context.textSecondary,
                      ),
                    ),
                  ),
                if (locationLine.isNotEmpty)
                  Text(locationLine, style: captionStyle),
              ],
            ),
          ],
          const Gap(AppSpacing.sm),
          Material(
            color: AppColors.transparent,
            child: InkWell(
              onTap: onTapReviews,
              borderRadius: BorderRadius.circular(AppSpacing.sm),
              child: ConstrainedBox(
                constraints: const BoxConstraints(minHeight: 44),
                child: Row(
                  children: [
                    Icon(
                      hasRating
                          ? Icons.star_rounded
                          : Icons.star_outline_rounded,
                      color: hasRating
                          ? context.amberColor
                          : context.labelColor,
                      size: 20,
                    ),
                    const Gap(AppSpacing.sm),
                    Expanded(
                      child: Text(
                        hasRating
                            ? '$ratingLabel${context.l10n.reviewsDotSeparator}$reviewCountLabel${context.l10n.reviewsSuffix}'
                            : context.l10n.noReviewsYet,
                        style: AppTypography.bodyMedium.copyWith(
                          fontWeight: FontWeight.w700,
                          color: hasRating
                              ? context.textPrimary
                              : context.labelColor,
                        ),
                      ),
                    ),
                    Icon(
                      context.chevronForward,
                      size: 20,
                      color: context.linkColor,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
