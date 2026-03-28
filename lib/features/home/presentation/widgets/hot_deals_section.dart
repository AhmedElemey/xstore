import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_strings.dart';
import '../../domain/entities/deal_entity.dart';
import 'product_card.dart';

class HotDealsSection extends StatelessWidget {
  const HotDealsSection({
    super.key,
    required this.deals,
    this.onOpenProduct,
  });

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
          AppStrings.hotDeals,
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const Gap(AppSpacing.md),
        LayoutBuilder(
          builder: (context, constraints) {
            const crossAxisCount = 2;
            const spacing = AppSpacing.md;
            final tileWidth =
                (constraints.maxWidth - spacing) / crossAxisCount;
            return Wrap(
              spacing: spacing,
              runSpacing: spacing,
              children: deals
                  .map(
                    (d) => SizedBox(
                      width: tileWidth,
                      child: ProductCard(
                        title: d.title,
                        price: d.price,
                        imageUrl: d.imageUrl,
                        discountPercent: d.discountPercent,
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
