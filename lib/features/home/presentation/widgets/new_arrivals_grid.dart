import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

import '../../../../core/animations/app_animations.dart';
import '../../../../core/animations/animation_extensions.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/utils/extensions/context_extensions.dart';
import '../../../listing/domain/entities/listing_entity.dart';
import 'product_card.dart';

class NewArrivalsGrid extends StatelessWidget {
  const NewArrivalsGrid({super.key, required this.items, this.onOpenProduct});

  final List<ListingEntity> items;
  final void Function(ListingEntity listing)? onOpenProduct;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return const SizedBox.shrink();
    }
    final display = items.take(4).toList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          context.l10n.newArrivals,
          style: AppTypography.headlineSmall.copyWith(
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        const Gap(AppSpacing.md),
        LayoutBuilder(
          builder: (context, constraints) {
            const crossAxisCount = 2;
            const spacing = AppSpacing.md;
            final tileWidth = (constraints.maxWidth - spacing) / crossAxisCount;
            return Wrap(
              spacing: spacing,
              runSpacing: spacing,
              children: display.asMap().entries.map((entry) {
                final i = entry.key;
                final listing = entry.value;
                final hasDiscount =
                    listing.compareAtPrice != null &&
                    listing.compareAtPrice! > listing.price + 0.009;
                final discountPercent = hasDiscount
                    ? ((listing.compareAtPrice! - listing.price) /
                              listing.compareAtPrice! *
                              100)
                          .roundToDouble()
                    : 0.0;
                return SizedBox(
                  key: ValueKey<String>(listing.id),
                  width: tileWidth,
                  child: RepaintBoundary(
                    child: ProductCard(
                      key: ValueKey<String>('new-arrival-${listing.id}'),
                      title: listing.title,
                      price: listing.price,
                      imageUrl: listing.imageUrls.isNotEmpty
                          ? listing.imageUrls.first
                          : null,
                      discountPercent: discountPercent,
                      listingId: listing.id,
                      isSoldOut: isSoldOutListing(status: listing.status),
                      onTap: () => onOpenProduct?.call(listing),
                    ).fadeSlideIn(delay: AppAnimations.staggerDelayCapped(i)),
                  ),
                );
              }).toList(),
            );
          },
        ),
      ],
    );
  }
}
