import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

import '../../../../core/constants/app_spacing.dart';
import '../../domain/entities/product_seller_entity.dart';

class SellerCard extends StatelessWidget {
  const SellerCard({
    super.key,
    required this.seller,
    required this.onVisitStore,
    required this.onCardTap,
  });

  final ProductSellerEntity seller;
  final VoidCallback onVisitStore;
  final VoidCallback onCardTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      child: Material(
        elevation: 3,
        shadowColor: Colors.black26,
        borderRadius: BorderRadius.circular(16),
        color: Colors.white,
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onCardTap,
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CircleAvatar(
                      radius: 24,
                      backgroundColor: theme.colorScheme.surfaceContainerHighest,
                      backgroundImage: seller.avatarUrl.isNotEmpty
                          ? CachedNetworkImageProvider(seller.avatarUrl)
                          : null,
                      child: seller.avatarUrl.isEmpty
                          ? const Icon(Icons.storefront_outlined)
                          : null,
                    ),
                    const Gap(AppSpacing.sm),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            seller.name,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const Gap(AppSpacing.xxs),
                          Text(
                            '⭐ ${seller.rating.toStringAsFixed(1)} Seller · ${seller.salesCount} sales',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Gap(AppSpacing.xs),
                    OutlinedButton(
                      onPressed: onVisitStore,
                      child: const Text('Visit Store'),
                    ),
                  ],
                ),
                if (seller.verified) ...[
                  const Gap(AppSpacing.sm),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.sm,
                      vertical: AppSpacing.xxs,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFDCFCE7),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '✅ Verified Seller',
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: const Color(0xFF166534),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
