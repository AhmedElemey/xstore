import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

import '../../../../core/constants/app_spacing.dart';
import '../../../../core/utils/formatters.dart';
import '../../../listing/domain/entities/listing_entity.dart';

class ProductHeader extends StatelessWidget {
  const ProductHeader({
    super.key,
    required this.listing,
    this.compareAtPrice,
    required this.onTapReviews,
    this.locationLine = '',
    this.ratingLabel = '4.7',
    this.reviewCountLabel = '1,230',
  });

  final ListingEntity listing;
  final double? compareAtPrice;
  final VoidCallback onTapReviews;
  final String locationLine;
  final String ratingLabel;
  final String reviewCountLabel;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final price = listing.price;
    final hasCompare =
        compareAtPrice != null && compareAtPrice! > price + 0.009;
    final discount = hasCompare
        ? ((compareAtPrice! - price) / compareAtPrice! * 100).round()
        : 0;

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.md,
        AppSpacing.md,
        AppSpacing.md,
        AppSpacing.sm,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            listing.title,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const Gap(AppSpacing.sm),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                Formatters.currency(price),
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: theme.colorScheme.primary,
                ),
              ),
              if (hasCompare) ...[
                const Gap(AppSpacing.sm),
                Text(
                  Formatters.currency(compareAtPrice!),
                  style: theme.textTheme.titleMedium?.copyWith(
                    decoration: TextDecoration.lineThrough,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const Gap(AppSpacing.sm),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.sm,
                    vertical: AppSpacing.xxs,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFEDD5),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '-$discount%',
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: const Color(0xFFEA580C),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ],
          ),
          const Gap(AppSpacing.sm),
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onTapReviews,
              borderRadius: BorderRadius.circular(8),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.xxs),
                child: Row(
                  children: [
                    const Icon(Icons.star_rounded,
                        color: Color(0xFFFBBF24), size: 22),
                    const Gap(AppSpacing.xxs),
                    Text(
                      '$ratingLabel · $reviewCountLabel reviews',
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Icon(
                      Icons.chevron_right_rounded,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ],
                ),
              ),
            ),
          ),
          const Gap(AppSpacing.sm),
          Wrap(
            spacing: AppSpacing.xs,
            runSpacing: AppSpacing.xs,
            children: [
              if (listing.conditionLabel.isNotEmpty)
                Chip(
                  label: Text(listing.conditionLabel),
                  visualDensity: VisualDensity.compact,
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
              if (listing.categoryLabel.isNotEmpty)
                Chip(
                  label: Text(listing.categoryLabel),
                  visualDensity: VisualDensity.compact,
                  backgroundColor:
                      theme.colorScheme.surfaceContainerHighest.withValues(
                    alpha: 0.6,
                  ),
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
            ],
          ),
          if (locationLine.isNotEmpty) ...[
            const Gap(AppSpacing.sm),
            Text(
              locationLine,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
