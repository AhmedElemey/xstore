import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

import '../../../../core/constants/app_spacing.dart';
import '../../domain/entities/deal_entity.dart';
import 'product_card.dart';

class NewArrivalsGrid extends StatelessWidget {
  const NewArrivalsGrid({
    super.key,
    required this.items,
    this.onOpenProduct,
  });

  final List<DealEntity> items;
  final void Function(DealEntity deal)? onOpenProduct;

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
          'New arrivals',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const Gap(AppSpacing.sm),
        LayoutBuilder(
          builder: (context, constraints) {
            const crossAxisCount = 2;
            const spacing = AppSpacing.sm;
            final tileWidth =
                (constraints.maxWidth - spacing) / crossAxisCount;
            return Wrap(
              spacing: spacing,
              runSpacing: spacing,
              children: display
                  .map(
                    (d) => SizedBox(
                      width: tileWidth,
                      child: ProductCard(
                        title: d.title,
                        price: d.price,
                        imageUrl: d.imageUrl,
                        discountPercent: 0,
                        onTap: () => onOpenProduct?.call(d),
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
