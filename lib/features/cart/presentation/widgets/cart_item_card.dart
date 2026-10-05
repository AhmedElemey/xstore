import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/utils/extensions/context_extensions.dart';
import '../../../../shared/widgets/app_cached_network_image.dart';
import '../../domain/entities/cart_item_entity.dart';
import 'quantity_control.dart';

/// One cart line, drawn flat inside its store's glass card.
class CartItemCard extends StatelessWidget {
  const CartItemCard({
    super.key,
    required this.item,
    required this.selected,
    required this.onToggleSelect,
    required this.onDecrement,
    required this.onIncrement,
    required this.onEditQuantity,
    required this.onRemove,
    required this.onSaveForLater,
    required this.onOpenProduct,
  });

  final CartItemEntity item;
  final bool selected;
  final VoidCallback onToggleSelect;
  final VoidCallback onDecrement;
  final VoidCallback onIncrement;
  final VoidCallback onEditQuantity;
  final VoidCallback onRemove;
  final VoidCallback onSaveForLater;
  final VoidCallback onOpenProduct;

  static const double _imageSize = 72;

  @override
  Widget build(BuildContext context) {
    final available = item.isAvailable;
    final compare = item.compareAtPrice;
    final shippingLabel = item.shippingAvailable
        ? (item.shippingCost <= 0
              ? context.l10n.cartShippingFree
              : context.l10n.cartShippingPaid(item.shippingCost.round()))
        : context.l10n.cartPickupOnly;
    final shippingColor = item.shippingAvailable
        ? (item.shippingCost <= 0 ? AppColors.success : context.textSecondary)
        : AppColors.error;
    final meta = [
      if (item.condition.trim().isNotEmpty) item.condition.trim(),
      if (item.category.trim().isNotEmpty) item.category.trim(),
    ];

    return Material(
      color: AppColors.transparent,
      child: InkWell(
        onTap: available ? onOpenProduct : null,
        borderRadius: BorderRadius.circular(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: 28,
                  height: 28,
                  child: Checkbox(
                    value: selected,
                    onChanged: available ? (_) => onToggleSelect() : null,
                    activeColor: context.brandGradient.first,
                    checkColor: context.onBrandColor,
                    side: BorderSide(
                      color: context.textSecondary.withValues(alpha: 0.6),
                      width: 1.5,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(7),
                    ),
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    visualDensity: VisualDensity.compact,
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                SizedBox(
                  width: _imageSize,
                  height: _imageSize,
                  child: Stack(
                    children: [
                      Positioned.fill(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(14),
                          child: AppCachedNetworkImage(
                            imageUrl: item.listingImage,
                            fit: BoxFit.cover,
                            memCacheWidth: 144,
                            memCacheHeight: 144,
                            placeholder: (_, __) => ColoredBox(
                              color: context.glassColor,
                              child: Icon(
                                Icons.image_outlined,
                                color: context.textDisabled,
                              ),
                            ),
                            errorWidget: (_, __, ___) => ColoredBox(
                              color: context.glassColor,
                              child: Icon(
                                Icons.broken_image_outlined,
                                color: context.textDisabled,
                              ),
                            ),
                          ),
                        ),
                      ),
                      if (!available)
                        Positioned.fill(
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(14),
                              color: AppColors.darkBackground.withValues(
                                alpha: 0.55,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.listingName,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: AppTypography.titleSmall.copyWith(
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          height: 1.3,
                          color: available
                              ? context.textPrimary
                              : context.textDisabled,
                        ),
                      ),
                      if (meta.isNotEmpty) ...[
                        const SizedBox(height: 2),
                        Text(
                          meta.join(context.l10n.reviewsDotSeparator),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTypography.labelSmall.copyWith(
                            fontSize: 12,
                            color: available
                                ? context.textSecondary
                                : context.textDisabled,
                          ),
                        ),
                      ],
                      const SizedBox(height: AppSpacing.xs),
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              context.formatCurrency(item.price),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: AppTypography.mono.copyWith(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: available
                                    ? context.amberColor
                                    : context.textDisabled,
                              ),
                            ),
                          ),
                          if (compare != null && compare > item.price) ...[
                            const SizedBox(width: AppSpacing.sm),
                            Text(
                              context.formatCurrency(compare),
                              style: AppTypography.mono.copyWith(
                                fontSize: 11,
                                color: context.textSecondary,
                                decoration: TextDecoration.lineThrough,
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        shippingLabel,
                        style: AppTypography.labelSmall.copyWith(
                          color: available
                              ? shippingColor
                              : context.textDisabled,
                          fontWeight:
                              item.shippingAvailable && item.shippingCost <= 0
                              ? FontWeight.w700
                              : FontWeight.w500,
                        ),
                      ),
                      if (!available) ...[
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          context.l10n.cartUnavailableHint,
                          style: AppTypography.labelSmall.copyWith(
                            color: AppColors.error,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.sm,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                QuantityControl(
                  quantity: item.quantity,
                  maxQuantity: item.maxQuantity,
                  enabled: available,
                  onDecrement: onDecrement,
                  onIncrement: onIncrement,
                  onEditQuantity: onEditQuantity,
                ),
                _ActionPill(
                  label: context.l10n.cartRemove,
                  onPressed: onRemove,
                ),
                if (available)
                  _ActionPill(
                    label: context.l10n.cartSaveForLater,
                    onPressed: onSaveForLater,
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ActionPill extends StatelessWidget {
  const _ActionPill({required this.label, required this.onPressed});

  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.transparent,
      shape: StadiumBorder(side: BorderSide(color: context.borderColor)),
      child: InkWell(
        onTap: onPressed,
        customBorder: const StadiumBorder(),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm,
          ),
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: AppTypography.labelSmall.copyWith(
              color: context.textPrimary,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
    );
  }
}
