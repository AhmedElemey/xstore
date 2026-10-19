import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
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
    final accent = listingStatusAccent(context, listing.status);
    final radius = BorderRadius.circular(22);
    // Active is the normal state; only the others get an accent border.
    final borderColor = listing.status == ListingStatus.active
        ? context.borderColor
        : accent.withValues(alpha: 0.4);
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.xs),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: context.glassColor,
          borderRadius: radius,
          border: Border.all(color: borderColor),
        ),
        child: Material(
          type: MaterialType.transparency,
          borderRadius: radius,
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: onTap,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: const EdgeInsets.all(AppSpacing.sm),
                  child: SizedBox(
                    height: imageHeight,
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        ListingThumbnail(
                          imageUrl: thumb,
                          width: double.infinity,
                          height: imageHeight,
                        ),
                        // Both edges + FittedBox keep a long localized label
                        // inside the thumbnail, and mirror in Arabic.
                        PositionedDirectional(
                          top: AppSpacing.sm,
                          start: AppSpacing.sm,
                          end: AppSpacing.sm,
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            alignment: AlignmentDirectional.centerStart,
                            child: StatusBadge(
                              status: listing.status,
                              compact: true,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsetsDirectional.fromSTEB(
                    AppSpacing.md,
                    AppSpacing.xs,
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
                              style: AppTypography.mono.copyWith(
                                color: context.amberColor,
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (onOpenMenu != null)
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
          ),
        ),
      ),
    );
  }
}
