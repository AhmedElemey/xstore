import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:gap/gap.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
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
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ListingThumbnail(imageUrl: thumb, size: 80, borderRadius: 10),
            const Gap(AppSpacing.lg),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    listing.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const Gap(AppSpacing.sm),
                  Text(
                    Formatters.currency(listing.price),
                    style: theme.textTheme.titleSmall?.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const Gap(4),
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
                    const Gap(4),
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
              icon: const Icon(LucideIcons.moreVertical),
              onPressed: onOpenMenu,
            ),
          ],
        ),
      ),
    );
  }
}
