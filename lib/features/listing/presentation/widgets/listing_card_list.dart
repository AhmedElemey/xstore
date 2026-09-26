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

/// Orbit listing row: photo, title, status tag and stock, amber price, and
/// the options button.
class ListingCardList extends StatelessWidget {
  const ListingCardList({
    super.key,
    required this.listing,
    required this.onOpenMenu,
  });

  final ListingEntity listing;
  final VoidCallback onOpenMenu;

  @override
  Widget build(BuildContext context) {
    final thumb = listing.imageUrls.isNotEmpty ? listing.imageUrls.first : '';
    final stock = listing.stockQuantity;
    final lowStock = stock > 0 && stock <= 5;
    return GlassCard(
      radius: 20,
      padding: const EdgeInsets.all(10),
      child: Row(
        children: [
          ListingThumbnail(imageUrl: thumb, size: 64, borderRadius: 14),
          const Gap(AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  listing.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.bodyLarge.copyWith(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: context.textPrimary,
                  ),
                ),
                const Gap(AppSpacing.xs),
                Row(
                  children: [
                    StatusBadge(status: listing.status, compact: true),
                    const Gap(AppSpacing.sm),
                    Flexible(
                      child: Text(
                        lowStock
                            ? '${context.l10n.onlyLeftPrefix}$stock${context.l10n.onlyLeftSuffix}'
                            : context.l10n.myListingsInStock(stock),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTypography.labelSmall.copyWith(
                          color: lowStock
                              ? context.cashColor
                              : context.textSecondary,
                        ),
                      ),
                    ),
                  ],
                ),
                const Gap(AppSpacing.xs),
                Text(
                  context.formatCurrency(listing.price),
                  style: AppTypography.bodyMedium.copyWith(
                    fontWeight: FontWeight.w700,
                    color: context.cashColor,
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            tooltip: MaterialLocalizations.of(context).moreButtonTooltip,
            icon: Icon(
              LucideIcons.moreVertical,
              size: 18,
              color: context.textSecondary,
            ),
            onPressed: onOpenMenu,
          ),
        ],
      ),
    );
  }
}
