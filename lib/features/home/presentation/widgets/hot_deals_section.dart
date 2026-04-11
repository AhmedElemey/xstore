import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:gap/gap.dart';

import '../../../../core/animations/app_animations.dart';
import '../../../../core/animations/animation_extensions.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/utils/extensions/context_extensions.dart';
import '../../domain/entities/deal_entity.dart';
import 'product_card.dart';

class HotDealsSection extends StatelessWidget {
  const HotDealsSection({super.key, required this.deals, this.onOpenProduct});

  final List<DealEntity> deals;
  final void Function(DealEntity deal)? onOpenProduct;

  @override
  Widget build(BuildContext context) {
    if (deals.isEmpty) {
      return const SizedBox.shrink();
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          context.l10n.hotDeals,
          style: Theme.of(context).textTheme.titleLarge,
        ).fadeSlideIn(delay: const Duration(milliseconds: 200)),
        const Gap(AppSpacing.md),
        LayoutBuilder(
          builder: (context, constraints) {
            const crossAxisCount = 2;
            const spacing = AppSpacing.md;
            final tileWidth = (constraints.maxWidth - spacing) / crossAxisCount;
            return Wrap(
              spacing: spacing,
              runSpacing: spacing,
              children: deals.asMap().entries.map(
                (entry) {
                  final i = entry.key;
                  final d = entry.value;
                  final delay = AppAnimations.staggerDelayCapped(i);
                  return SizedBox(
                    key: ValueKey<String>(d.id),
                    width: tileWidth,
                    child: RepaintBoundary(
                      child: ProductCard(
                        key: ValueKey<String>('hot-deal-${d.id}'),
                        title: d.title,
                        price: d.price,
                        imageUrl: d.imageUrl,
                        discountPercent: d.discountPercent,
                        listingId: d.id,
                        onTap: () => onOpenProduct?.call(d),
                      )
                          .fadeSlideIn(delay: delay, offsetY: 0)
                          .animate(delay: delay)
                          .slideX(
                            begin: 0.05,
                            end: 0,
                            duration: AppAnimations.normal,
                            curve: AppAnimations.enter,
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
