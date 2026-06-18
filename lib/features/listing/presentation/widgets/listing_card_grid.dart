import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:gap/gap.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/utils/extensions/context_extensions.dart';
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
    final thumb = listing.imageUrls.isNotEmpty ? listing.imageUrls.first : '';
    return Container(
      decoration: BoxDecoration(
        color: context.surfaceColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: context.borderColor.withValues(alpha: 0.45)),
        boxShadow: [
          BoxShadow(
            color: context.cardShadowColor,
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
                        style: AppTypography.body15.copyWith(
                          fontWeight: FontWeight.w600,
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
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(LucideIcons.moreVertical, size: 18),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(
                    minWidth: 20,
                    minHeight: 20,
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
