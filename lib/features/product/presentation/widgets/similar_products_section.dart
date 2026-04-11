import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

import '../../../../core/constants/app_spacing.dart';
import '../../../../core/utils/extensions/context_extensions.dart';
import '../../../home/domain/entities/deal_entity.dart';
import '../../../home/presentation/widgets/product_card.dart';

class SimilarProductsSection extends StatelessWidget {
  const SimilarProductsSection({
    super.key,
    required this.products,
    required this.onOpenProduct,
  });

  final List<DealEntity> products;
  final void Function(DealEntity deal) onOpenProduct;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    if (products.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          child: Text(
            context.l10n.youMayAlsoLike,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        const Gap(AppSpacing.md),
        SizedBox(
          height: 232,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            itemCount: products.length,
            separatorBuilder: (_, __) => const Gap(AppSpacing.md),
            itemBuilder: (context, i) {
              final d = products[i];
              return SizedBox(
                width: 160,
                child: ProductCard(
                  title: d.title,
                  price: d.price,
                  imageUrl: d.imageUrl,
                  discountPercent: d.discountPercent,
                  listingId: d.id,
                  onTap: () => onOpenProduct(d),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
