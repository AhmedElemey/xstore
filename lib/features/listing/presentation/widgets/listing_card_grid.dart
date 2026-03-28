import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:gap/gap.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/utils/formatters.dart';
import '../../domain/entities/listing_entity.dart';
import 'listing_thumbnail.dart';
import 'status_badge.dart';

class ListingCardGrid extends StatelessWidget {
  const ListingCardGrid({
    super.key,
    required this.listing,
    required this.onOpenMenu,
  });

  final ListingEntity listing;
  final VoidCallback onOpenMenu;

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
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              ListingThumbnail(
                imageUrl: thumb,
                width: double.infinity,
                height: 140,
                borderRadius: 0,
              ),
              Positioned(
                top: AppSpacing.md,
                right: AppSpacing.md,
                child: StatusBadge(status: listing.status, compact: true),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.md,
              AppSpacing.md,
              AppSpacing.xs,
              AppSpacing.md,
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        listing.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.titleSmall?.copyWith(
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
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(LucideIcons.moreVertical, size: 22),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(
                    minWidth: 40,
                    minHeight: 40,
                  ),
                  onPressed: onOpenMenu,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
