import 'package:flutter/material.dart';
import '../../../../shared/widgets/orbit_widgets.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:gap/gap.dart';

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
    this.onOpenMenu,
    this.onTap,
    this.imageHeight = 140,
  });

  final ListingEntity listing;
  final VoidCallback? onOpenMenu;
  final VoidCallback? onTap;
  final double imageHeight;

  @override
  Widget build(BuildContext context) {
    final thumb = listing.imageUrls.isNotEmpty ? listing.imageUrls.first : '';
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.xs + 2),
      child: GlassCard(
        radius: 22,
        padding: const EdgeInsets.all(10),
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(
              height: imageHeight,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  ListingThumbnail(
                    imageUrl: thumb,
                    width: double.infinity,
                    height: imageHeight,
                    borderRadius: 16,
                  ),
                  // Live listings need no tag; anything else says why.
                  if (listing.status != ListingStatus.active)
                    PositionedDirectional(
                      top: AppSpacing.sm,
                      end: AppSpacing.sm,
                      child: StatusBadge(status: listing.status, compact: true),
                    ),
                ],
              ),
            ),
            const Gap(AppSpacing.sm),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        listing.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTypography.bodyMedium.copyWith(
                          fontWeight: FontWeight.w700,
                          color: context.textPrimary,
                        ),
                      ),
                      const Gap(AppSpacing.xs),
                      Text(
                        context.formatCurrency(listing.price),
                        style: AppTypography.bodyMedium.copyWith(
                          color: context.cashColor,
                          fontWeight: FontWeight.w700,
                          fontFeatures: const [FontFeature.tabularFigures()],
                        ),
                      ),
                    ],
                  ),
                ),
                if (onOpenMenu != null)
                  IconButton(
                    tooltip: MaterialLocalizations.of(context).moreButtonTooltip,
                    icon: Icon(
                      LucideIcons.moreVertical,
                      size: 18,
                      color: context.textSecondary,
                    ),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(
                      minWidth: 32,
                      minHeight: 32,
                    ),
                    onPressed: onOpenMenu,
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
