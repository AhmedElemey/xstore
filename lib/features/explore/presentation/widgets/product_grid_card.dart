import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gap/gap.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../shared/widgets/app_cached_network_image.dart';
import '../../../../shared/widgets/wish_heart_button.dart';
import '../../domain/entities/search_result_entity.dart';
import '../../../../core/utils/extensions/context_extensions.dart';

class ProductGridCard extends StatelessWidget {
  const ProductGridCard({
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Positioned.fill(
                      child: item.imageUrl != null
                          ? Semantics(
                              image: true,
                              label:
                                  '${item.name} · ${context.l10n.listingPhotoSectionTitle}',
                              child: AppCachedNetworkImage(
                                imageUrl: item.imageUrl!,
                                fit: BoxFit.cover,
                                placeholder: (_, __) => ColoredBox(
                                  color: context.textDisabled,
                                ),
                                errorWidget: (_, __, ___) => ColoredBox(
                                  color: context.textDisabled,
                                ),
                              ),
                            )
                          : ColoredBox(color: context.textDisabled),
                    ),
                    Positioned(
                      left: AppSpacing.sm,
                      top: AppSpacing.sm,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.sm,
                          vertical: AppSpacing.xs,
                        ),
                        decoration: BoxDecoration(
                          color:
                              context.textPrimary.withValues(alpha: 0.65),
                          borderRadius: BorderRadius.circular(AppSpacing.xs),
                        ),
                        child: Text(
                          item.condition,
                          style: AppTypography.labelSmall
                              .copyWith(color: context.surfaceColor),
                        ),
                      ),
                    ),
                    Positioned(
                      right: AppSpacing.sm,
                      top: AppSpacing.sm,
                      child: WishHeartButton(
                        listingId: item.id,
                        size: AppSpacing.x2l,
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.bodyMedium.copyWith(fontWeight: FontWeight.w600),
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
    );
  }
}
