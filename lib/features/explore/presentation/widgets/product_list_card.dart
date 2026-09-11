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
    // Same chrome as wishlist list cards: soft shadow outside clip,
    // primary-tint outline, and a 4px left accent bar.
    final accent = item.compareAtPrice != null &&
            item.compareAtPrice! > item.price
        ? AppColors.success
        : AppColors.primary;
    final radius = BorderRadius.circular(AppSpacing.lg);

    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: radius,
        boxShadow: [
          BoxShadow(
            color: context.cardShadowColor,
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Material(
        color: context.surfaceColor,
        borderRadius: radius,
        clipBehavior: Clip.antiAlias,
        child: Semantics(
          button: true,
          label:
              '${item.name}, ${context.formatCurrency(item.price)}, ${item.condition}',
          child: InkWell(
            onTap: onTap,
            child: Ink(
              decoration: BoxDecoration(
                border: Border.all(color: accent.withValues(alpha: 0.45)),
                borderRadius: radius,
              ),
              child: Stack(
                children: [
                  Padding(
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
                                    child: AppCachedNetworkImage(
                                      imageUrl: item.imageUrl!,
                                      fit: BoxFit.cover,
                                      memCacheWidth: 336,
                                      memCacheHeight: 336,
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
                                  if (item.condition.trim().isNotEmpty)
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: AppSpacing.sm,
                                        vertical: AppSpacing.xs,
                                      ),
                                      decoration: BoxDecoration(
                                        color: context.isDark
                                            ? AppColors.primary.withValues(
                                                alpha: 0.2,
                                              )
                                            : AppColors.indigoTint50,
                                        borderRadius: BorderRadius.circular(
                                          AppSpacing.xs,
                                        ),
                                      ),
                                      child: Text(
                                        item.condition,
                                        style: AppTypography.labelSmall.copyWith(
                                          color: AppColors.primary,
                                          fontWeight: FontWeight.w600,
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
                                    style: AppTypography.labelLarge.copyWith(
                                      color: AppColors.primary,
                                    ),
                                  ),
                                  if (item.compareAtPrice != null) ...[
                                    const Gap(AppSpacing.sm),
                                    Text(
                                      context.formatCurrency(
                                        item.compareAtPrice!,
                                      ),
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
                                      color: AppColors.primary,
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
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Positioned(
                    left: 0,
                    top: 0,
                    bottom: 0,
                    width: 4,
                    child: ColoredBox(color: accent),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
