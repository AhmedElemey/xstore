import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

import '../../../../core/animations/app_animations.dart';
import '../../../../core/animations/animation_extensions.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/utils/extensions/context_extensions.dart';
import '../../../../shared/widgets/orbit_widgets.dart';
import '../../../listing/domain/entities/listing_entity.dart';
import 'product_card.dart';

class NewArrivalsGrid extends StatelessWidget {
  const NewArrivalsGrid({
    super.key,
    required this.items,
    this.onOpenProduct,
    this.onSeeAll,
  });

  final List<ListingEntity> items;
  final void Function(ListingEntity listing)? onOpenProduct;
  final VoidCallback? onSeeAll;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return const SizedBox.shrink();
    }
    final display = items.take(4).toList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        OrbitSectionHeader(
          title: context.l10n.homeFreshInOrbit,
          actionLabel: onSeeAll == null ? null : context.l10n.seeAll,
          onAction: onSeeAll,
        ),
        const Gap(AppSpacing.sm),
        LayoutBuilder(
          builder: (context, constraints) {
            const crossAxisCount = 2;
            const spacing = AppSpacing.md;
            final tileWidth = (constraints.maxWidth - spacing) / crossAxisCount;
            return Wrap(
              spacing: spacing,
              runSpacing: spacing,
              children: display.asMap().entries.map(
                (entry) {
                  final i = entry.key;
                  final listing = entry.value;
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
                        discountPercent: 0,
                        listingId: listing.id,
                        onTap: () => onOpenProduct?.call(listing),
                      ).fadeSlideIn(
                        delay: AppAnimations.staggerDelayCapped(i),
                      ),
                    ),
                  );
                },
              ).toList(),
            );
          },
        ),
      ],
    );
  }
}
