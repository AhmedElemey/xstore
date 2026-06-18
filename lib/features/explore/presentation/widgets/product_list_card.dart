import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gap/gap.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/network/image_cache_manager.dart';
import '../../../../shared/widgets/wish_heart_button.dart';
import '../../domain/entities/search_result_entity.dart';
import '../../../../core/utils/extensions/context_extensions.dart';

class ProductListCard extends StatelessWidget {
  const ProductListCard({
    super.key,
    required this.item,
    required this.onAddToCart,
    required this.showAddToCart,
    required this.onTap,
  });

  final SearchResultEntity item;
  final VoidCallback onAddToCart;
  final bool showAddToCart;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: context.surfaceColor,
      borderRadius: BorderRadius.circular(AppSpacing.md),
      clipBehavior: Clip.antiAlias,
      child: Semantics(
        button: true,
        label:
            '${item.name}, ${context.formatCurrency(item.price)}, ${item.condition}',
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(AppSpacing.sm),
                  child: SizedBox(
                    width: AppSpacing.x4l * 2 + AppSpacing.lg,
                    height: AppSpacing.x4l * 2 + AppSpacing.lg,
                    child: item.imageUrl != null
                        ? Semantics(
                            image: true,
                            label:
                                '${item.name} · ${context.l10n.listingPhotoSectionTitle}',
                            child: CachedNetworkImage(
                              imageUrl: item.imageUrl!,
                              cacheManager: AppImageCacheManager.instance,
                              fit: BoxFit.cover,
                              placeholder: (_, __) =>
                                  ColoredBox(color: context.textDisabled),
                              errorWidget: (_, __, ___) =>
                                  ColoredBox(color: context.textDisabled),
                            ),
                          )
                        : ColoredBox(color: context.textDisabled),
                  ),
                ),
                const Gap(AppSpacing.md),
                Expanded(
                  child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            item.name,
                            style: AppTypography.bodyMedium.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        WishHeartButton(
                          listingId: item.id,
                          size: AppSpacing.x2l,
                        ),
                      ],
                    ),
                    Text(
                      item.condition,
                      style: AppTypography.labelSmall,
                    ),
                    const Gap(AppSpacing.xs),
                    Row(
                      children: [
                        Text(
                          context.formatCurrency(item.price),
                          style: AppTypography.labelLarge.copyWith(color: AppColors.primary),
                        ),
                        if (item.compareAtPrice != null) ...[
                          const Gap(AppSpacing.sm),
                          Text(
                            context.formatCurrency(item.compareAtPrice!),
                            style: AppTypography.bodySmall.copyWith(
                              decoration: TextDecoration.lineThrough,
                            ),
                          ),
                        ],
                      ],
                    ),
                    const Gap(AppSpacing.xs),
                    Row(
                      children: [
                        Icon(LucideIcons.star, size: AppSpacing.md, color: AppColors.warning),
                        Text(
                          ' ${item.rating.toStringAsFixed(1)} (${item.reviewCount})',
                          style: AppTypography.bodySmall,
                        ),
                      ],
                    ),
                    const Gap(AppSpacing.xs),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            item.sellerName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppTypography.bodySmall,
                          ),
                        ),
                        if (item.isSellerVerified)
                          Icon(LucideIcons.badgeCheck, size: AppSpacing.lg, color: AppColors.primary),
                      ],
                    ),
                    if (showAddToCart) ...[
                      const Gap(AppSpacing.md),
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton(
                          onPressed: () {
                            HapticFeedback.lightImpact();
                            onAddToCart();
                          },
                          child: Text(context.l10n.addToCart),
                        ),
                      ),
                    ],
                  ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
