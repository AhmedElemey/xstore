import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/utils/extensions/context_extensions.dart';
import '../../../listing/domain/entities/listing_entity.dart';

/// Top of the Orbit product sheet: category line, title in the display face
/// and the amber price (with the struck compare-at price when discounted).
class ProductHeader extends StatelessWidget {
  const ProductHeader({
    super.key,
    required this.listing,
    this.compareAtPrice,
    this.locationLine = '',
  });

  final ListingEntity listing;
  final double? compareAtPrice;
  final String locationLine;

  @override
  Widget build(BuildContext context) {
    final price = listing.price;
    final hasCompare =
        compareAtPrice != null && compareAtPrice! > price + 0.009;
    final discount = hasCompare
        ? ((compareAtPrice! - price) / compareAtPrice! * 100).round()
        : 0;
    final kicker = [
      if (listing.categoryLabel.isNotEmpty) listing.categoryLabel,
      if (listing.conditionLabel.isNotEmpty) listing.conditionLabel,
    ].join(' · ');
    final secondary = AppTypography.bodySmall.copyWith(
      color: context.textSecondary,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (kicker.isNotEmpty) ...[
                    Text(kicker, style: secondary),
                    const Gap(AppSpacing.xs + 2),
                  ],
                  Text(
                    listing.title,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: AppTypography.titleMedium.copyWith(
                      fontFamily: AppTypography.displayFontFamily,
                      fontWeight: FontWeight.w800,
                      height: 1.15,
                      color: context.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
            const Gap(AppSpacing.md),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  context.formatCurrency(price),
                  style: AppTypography.titleMedium.copyWith(
                    fontWeight: FontWeight.w700,
                    color: context.cashColor,
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
                ),
                if (hasCompare)
                  Text(
                    '${context.formatCurrency(compareAtPrice!)}  -$discount%',
                    style: secondary.copyWith(
                      decoration: TextDecoration.lineThrough,
                      decorationColor: context.textSecondary,
                    ),
                  ),
              ],
            ),
          ],
        ),
        if (locationLine.isNotEmpty) ...[
          const Gap(AppSpacing.sm),
          Row(
            children: [
              Icon(LucideIcons.mapPin, size: 14, color: context.textSecondary),
              const Gap(AppSpacing.xs),
              Expanded(
                child: Text(
                  locationLine,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: secondary,
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }
}

/// "★ 4.6 · 38 reviews   Read →" link to the reviews.
class ProductRatingLink extends StatelessWidget {
  const ProductRatingLink({
    super.key,
    required this.onTap,
    this.ratingLabel,
    this.reviewCountLabel,
  });

  final VoidCallback onTap;
  final String? ratingLabel;
  final String? reviewCountLabel;

  @override
  Widget build(BuildContext context) {
    final hasRating = ratingLabel != null && reviewCountLabel != null;
    final style = AppTypography.bodyMedium.copyWith(
      fontWeight: FontWeight.w700,
      color: context.textPrimary,
    );
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppSpacing.sm),
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: 44),
        child: Row(
          children: [
            Icon(
              Icons.star_rounded,
              size: 20,
              color: hasRating ? context.cashColor : context.textSecondary,
            ),
            const Gap(AppSpacing.sm),
            if (hasRating) ...[
              Text(ratingLabel!, style: style),
              Text(
                '${context.l10n.reviewsDotSeparator}$reviewCountLabel${context.l10n.reviewsSuffix}',
                style: style.copyWith(
                  fontWeight: FontWeight.w600,
                  color: context.textSecondary,
                ),
              ),
            ] else
              Text(
                context.l10n.noReviewsYet,
                style: style.copyWith(color: context.textSecondary),
              ),
            const Spacer(),
            Text(context.l10n.productReadReviews, style: style),
            const Gap(AppSpacing.xs),
            Icon(
              Directionality.of(context) == TextDirection.rtl
                  ? LucideIcons.arrowLeft
                  : LucideIcons.arrowRight,
              size: 16,
              color: context.textPrimary,
            ),
          ],
        ),
      ),
    );
  }
}
