import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_strings.dart';
import '../../domain/entities/product_seller_entity.dart';
import '../../../../core/utils/extensions/context_extensions.dart';

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
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: Material(
        elevation: 3,
        shadowColor: context.textPrimary.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(AppSpacing.lg),
        color: context.surfaceColor,
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onCardTap,
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CircleAvatar(
                      radius: AppSpacing.x2l,
                      backgroundColor: theme.colorScheme.surfaceContainerHighest,
                      backgroundImage: seller.avatarUrl.isNotEmpty
                          ? CachedNetworkImageProvider(seller.avatarUrl)
                          : null,
                      child: seller.avatarUrl.isEmpty
                          ? const Icon(LucideIcons.store)
                          : null,
                    ),
                    const Gap(AppSpacing.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            seller.name,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                              fontSize: 18
                            ),
                          ),
                          const Gap(AppSpacing.xs),
                          Text(
                            '⭐ ${seller.rating.toStringAsFixed(1)}${AppStrings.sellerRatingMid}${seller.salesCount}${AppStrings.sellerSalesSuffix}',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Gap(AppSpacing.sm),
                   
                  ],
                ),
                 const Gap(AppSpacing.md),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                   OutlinedButton(
                      onPressed: onVisitStore,
                      child: Text(AppStrings.visitStore),
                    ), 
                   
                      if (seller.verified) ...[
                  
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.md,
                      vertical: AppSpacing.xs,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.success.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(AppSpacing.sm),
                    ),
                    child: Text(
                      AppStrings.verifiedSeller,
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: AppColors.success,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
                  ],),
              
              ],
            ),
          ),
        ),
      ),
    );
  }
}
