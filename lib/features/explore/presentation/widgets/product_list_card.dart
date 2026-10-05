import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gap/gap.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../shared/widgets/app_cached_network_image.dart';
import '../../../../shared/widgets/sold_out_overlay.dart';
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
    final radius = BorderRadius.circular(20);

    return Material(
      color: context.glassColor,
      shape: RoundedRectangleBorder(
        borderRadius: radius,
        side: BorderSide(color: context.borderColor),
      ),
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
                  borderRadius: BorderRadius.circular(AppSpacing.lg),
                  child: SizedBox(
                    width: AppSpacing.x4l * 2 + AppSpacing.lg,
                    height: AppSpacing.x4l * 2 + AppSpacing.lg,
                    child: SoldOutOverlay(
                      soldOut: item.isSoldOut,
                      child: item.imageUrl != null
                          ? Semantics(
                              image: true,
                              label:
                                  '${item.name} · ${context.l10n.listingPhotoSectionTitle}',
                              child: AppCachedNetworkImage(
                                imageUrl: item.imageUrl!,
                                fit: BoxFit.cover,
                                memCacheWidth: 336,
                                memCacheHeight: 336,
                                placeholder: (_, __) =>
                                    ColoredBox(color: context.textDisabled),
                                errorWidget: (_, __, ___) =>
                                    ColoredBox(color: context.textDisabled),
                              ),
                            )
                          : ColoredBox(color: context.textDisabled),
                    ),
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
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                          if (item.condition.trim().isNotEmpty)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: AppSpacing.sm,
                                vertical: AppSpacing.xs,
                              ),
                              decoration: BoxDecoration(
                                color: context.glassColor,
                                borderRadius: BorderRadius.circular(
                                  AppSpacing.sm,
                                ),
                                border: Border.all(color: context.borderColor),
                              ),
                              child: Text(
                                item.condition,
                                style: AppTypography.labelSmall.copyWith(
                                  color: context.linkColor,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                        ],
                      ),
                      const Gap(AppSpacing.xs),
                      Row(
                        children: [
                          Text(
                            context.formatCurrency(item.price),
                            style: AppTypography.mono.copyWith(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: context.amberColor,
                            ),
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
                          Expanded(
                            child: Text(
                              item.sellerName,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: AppTypography.bodySmall,
                            ),
                          ),
                          if (item.isSellerVerified) ...[
                            const Gap(AppSpacing.xs),
                            Icon(
                              LucideIcons.badgeCheck,
                              size: AppSpacing.lg,
                              color: context.linkColor,
                            ),
                          ],
                          const Gap(AppSpacing.sm),
                          Icon(
                            LucideIcons.star,
                            size: AppSpacing.md,
                            color: AppColors.warning,
                          ),
                          Text(
                            ' ${item.rating.toStringAsFixed(1)} (${item.reviewCount})',
                            style: AppTypography.bodySmall,
                          ),
                        ],
                      ),
                      const Gap(AppSpacing.md),
                      Row(
                        children: [
                          WishHeartButton(
                            listingId: item.id,
                            size: AppSpacing.x2l,
                          ),
                          if (showAddToCart) ...[
                            const Gap(AppSpacing.sm),
                            Expanded(
                              child: FilledButton(
                                onPressed: item.isSoldOut
                                    ? null
                                    : () {
                                        HapticFeedback.lightImpact();
                                        onAddToCart();
                                      },
                                child: Text(
                                  item.isSoldOut
                                      ? context.l10n.soldOut
                                      : context.l10n.addToCart,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
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
