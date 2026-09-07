import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:gap/gap.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/utils/extensions/context_extensions.dart';
import '../../../../core/utils/formatters.dart';
import '../../domain/entities/listing_entity.dart';
import 'listing_thumbnail.dart';
import 'status_badge.dart';

class ListingCardList extends StatelessWidget {
  const ListingCardList({
    super.key,
    required this.listing,
    required this.onOpenMenu,
  });

  final ListingEntity listing;
  final VoidCallback onOpenMenu;

  String get _metaLine {
    final cat = listing.categoryLabel.trim();
    final cond = listing.conditionLabel.trim();
    if (cat.isEmpty && cond.isEmpty) {
      return '—';
    }
    if (cat.isEmpty) {
      return cond;
    }
    if (cond.isEmpty) {
      return cat;
    }
    return '$cat • $cond';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final thumb = listing.imageUrls.isNotEmpty ? listing.imageUrls.first : '';
    final accent = listingStatusAccent(context, listing.status);
    final radius = BorderRadius.circular(16);
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: radius,
        boxShadow: [
          BoxShadow(
            color: context.cardShadowColor,
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Material(
        color: context.surfaceColor,
        borderRadius: radius,
        clipBehavior: Clip.antiAlias,
        child: Ink(
          decoration: BoxDecoration(
            border: Border.all(color: accent.withValues(alpha: 0.45)),
            borderRadius: radius,
          ),
          child: Stack(
            children: [
              Padding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ListingThumbnail(
                      imageUrl: thumb,
                      size: 80,
                      borderRadius: 10,
                    ),
                    const Gap(AppSpacing.lg),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            listing.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppTypography.body15.copyWith(
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const Gap(AppSpacing.sm),
                          Text(
                            context.formatCurrency(listing.price),
                            style: AppTypography.body15.copyWith(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const Gap(AppSpacing.xs),
                          Text(
                            _metaLine,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                          const Gap(AppSpacing.sm),
                          StatusBadge(status: listing.status),
                          if (listing.postedAt != null) ...[
                            const Gap(AppSpacing.xs),
                            Text(
                              'Posted ${Formatters.shortDate(listing.postedAt!)}',
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant
                                    .withValues(alpha: 0.75),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(LucideIcons.moreVertical, size: 18),
                      onPressed: onOpenMenu,
                    ),
                  ],
                ),
              ),
              Positioned(
                left: 0,
                top: 0,
                bottom: 0,
                width: 4,
                child: ColoredBox(color: accent),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
