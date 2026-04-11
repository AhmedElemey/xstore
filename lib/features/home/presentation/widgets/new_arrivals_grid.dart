import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

import '../../../../core/constants/app_spacing.dart';
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
          style: Theme.of(context).textTheme.titleLarge,
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
              children: display
                  .map(
                    (listing) => SizedBox(
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
                          discountPercent: 0,
                          listingId: listing.id,
                          onTap: () => onOpenProduct?.call(listing),
                        ),
                      ),
                    ),
                  )
                  .toList(),
            );
          },
        ),
      ],
    );
  }
}
