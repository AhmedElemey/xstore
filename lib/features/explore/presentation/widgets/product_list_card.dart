import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/utils/formatters.dart';
import '../../domain/entities/search_result_entity.dart';

class ProductListCard extends StatelessWidget {
  const ProductListCard({
    super.key,
    required this.item,
    required this.isFavorite,
    required this.onToggleFavorite,
    required this.onAddToCart,
    required this.showAddToCart,
    required this.onTap,
  });

  final SearchResultEntity item;
  final bool isFavorite;
  final VoidCallback onToggleFavorite;
  final VoidCallback onAddToCart;
  final bool showAddToCart;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.cardBg,
      borderRadius: BorderRadius.circular(AppSpacing.md),
      clipBehavior: Clip.antiAlias,
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
                      ? CachedNetworkImage(
                          imageUrl: item.imageUrl!,
                          fit: BoxFit.cover,
                        )
                      : const ColoredBox(color: AppColors.textDisabled),
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
                        IconButton(
                          onPressed: onToggleFavorite,
                          icon: Icon(
                            LucideIcons.heart,
                            color: isFavorite ? AppColors.error : AppColors.textSecondary,
                          ),
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
                          Formatters.currency(item.price),
                          style: AppTypography.labelLarge.copyWith(color: AppColors.primary),
                        ),
                        if (item.compareAtPrice != null) ...[
                          const Gap(AppSpacing.sm),
                          Text(
                            Formatters.currency(item.compareAtPrice!),
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
                        Text(
                          '${AppStrings.starChar} ${item.rating.toStringAsFixed(1)} · ${item.sellerName}',
                          style: AppTypography.bodySmall,
                        ),
                        if (item.isSellerVerified) ...[
                          const Gap(AppSpacing.xs),
                          Icon(
                            LucideIcons.badgeCheck,
                            size: AppSpacing.md,
                            color: AppColors.primary,
                          ),
                        ],
                      ],
                    ),
                    if (showAddToCart) ...[
                      const Gap(AppSpacing.md),
                      FilledButton(
                        onPressed: onAddToCart,
                        child: Text(AppStrings.addToCart),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
