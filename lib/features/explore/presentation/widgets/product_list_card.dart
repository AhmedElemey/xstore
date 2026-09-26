import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gap/gap.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../shared/widgets/app_cached_network_image.dart';
import '../../../../shared/widgets/orbit_widgets.dart';
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
    // Orbit result row: glass card, rounded thumbnail, bold name, seller and
    // rating line, amber price; heart and Add to cart stay on the right.
    return Semantics(
      button: true,
      label:
          '${item.name}, ${context.formatCurrency(item.price)}, ${item.condition}',
      child: GlassCard(
        onTap: onTap,
        radius: 20,
        padding: const EdgeInsets.all(AppSpacing.sm + 2),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: SizedBox(
                width: 78,
                height: 78,
                child: item.imageUrl != null
                    ? Semantics(
                        image: true,
                        label:
                            '${item.name} · ${context.l10n.listingPhotoSectionTitle}',
                        child: AppCachedNetworkImage(
                          imageUrl: item.imageUrl!,
                          fit: BoxFit.cover,
                          memCacheWidth: 240,
                          memCacheHeight: 240,
                          placeholder: (_, __) => DecoratedBox(
                            decoration: BoxDecoration(
                              gradient: orbitOrbGradient(item.id.hashCode),
                            ),
                          ),
                          errorWidget: (_, __, ___) => DecoratedBox(
                            decoration: BoxDecoration(
                              gradient: orbitOrbGradient(item.id.hashCode),
                            ),
                          ),
                        ),
                      )
                    : DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: orbitOrbGradient(item.id.hashCode),
                        ),
                      ),
              ),
            ),
            const Gap(AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: AppTypography.bodyMedium.copyWith(
                      fontWeight: FontWeight.w800,
                      color: context.textPrimary,
                    ),
                  ),
                  const Gap(4),
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          item.sellerName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTypography.bodySmall.copyWith(
                            color: context.textSecondary,
                          ),
                        ),
                      ),
                      if (item.isSellerVerified) ...[
                        const Gap(AppSpacing.xs),
                        Icon(
                          LucideIcons.badgeCheck,
                          size: 14,
                          color: context.primaryColor,
                        ),
                      ],
                      if (item.reviewCount > 0) ...[
                        const Gap(AppSpacing.sm),
                        const Icon(
                          Icons.star_rounded,
                          size: 14,
                          color: AppColors.warning,
                        ),
                        Text(
                          ' ${item.rating.toStringAsFixed(1)}',
                          style: AppTypography.bodySmall.copyWith(
                            color: context.textSecondary,
                          ),
                        ),
                      ],
                    ],
                  ),
                  const Gap(4),
                  Row(
                    children: [
                      Text(
                        context.formatCurrency(item.price),
                        style: AppTypography.bodyMedium.copyWith(
                          color: context.cashColor,
                          fontWeight: FontWeight.w800,
                          fontFeatures: const [FontFeature.tabularFigures()],
                        ),
                      ),
                      if (item.compareAtPrice != null) ...[
                        const Gap(AppSpacing.sm),
                        Text(
                          context.formatCurrency(item.compareAtPrice!),
                          style: AppTypography.bodySmall.copyWith(
                            color: context.textSecondary,
                            decoration: TextDecoration.lineThrough,
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
            const Gap(AppSpacing.sm),
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                WishHeartButton(listingId: item.id, size: 20),
                if (showAddToCart) ...[
                  const Gap(AppSpacing.xs),
                  OrbitCircleButton(
                    tooltip: context.l10n.addToCart,
                    onPressed: () {
                      HapticFeedback.lightImpact();
                      onAddToCart();
                    },
                    child: Icon(
                      LucideIcons.shoppingCart,
                      size: 18,
                      color: context.primaryColor,
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}
