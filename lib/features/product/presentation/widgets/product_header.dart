import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:lucide_icons/lucide_icons.dart';

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
        AppSpacing.lg,
        AppSpacing.lg,
        AppSpacing.lg,
        AppSpacing.md,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            listing.title,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: AppTypography.titleSmall.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const Gap(AppSpacing.md),
          Wrap(
            crossAxisAlignment: WrapCrossAlignment.end,
            spacing: AppSpacing.md,
            runSpacing: AppSpacing.xs,
            children: [
              Text(
                context.formatCurrency(price),
                style: AppTypography.titleSmall.copyWith(
                  fontWeight: FontWeight.w800,
                  color: theme.colorScheme.primary,
                ),
              ),
              if (hasCompare) ...[
                Text(
                  context.formatCurrency(compareAtPrice!),
                  style: AppTypography.titleSmall.copyWith(
                    decoration: TextDecoration.lineThrough,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                    vertical: AppSpacing.xs,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.accent.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(AppSpacing.xl),
                  ),
                  child: Text(
                    '-$discount%',
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: AppColors.accent,
                      fontWeight: FontWeight.w600,
                      
                    ),
                  ),
                ),
              ],
            ],
          ),
          const Gap(AppSpacing.md),
          Material(
            color: AppColors.transparent,
            child: InkWell(
              onTap: onTapReviews,
              borderRadius: BorderRadius.circular(AppSpacing.sm),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
                child: Row(
                  children: [
                    Icon(
                      LucideIcons.star,
                      color: AppColors.warning,
                      size: AppSpacing.xl + AppSpacing.xs,
                    ),
                    const Gap(AppSpacing.xs),
                    Text(
                      '$ratingLabel${context.l10n.reviewsDotSeparator}$reviewCountLabel${context.l10n.reviewsSuffix}',
                      style: AppTypography.titleSmall.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Icon(
                      LucideIcons.chevronRight,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ],
                ),
              ),
            ),
          ),
          const Gap(AppSpacing.md),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
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
            const Gap(AppSpacing.md),
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
