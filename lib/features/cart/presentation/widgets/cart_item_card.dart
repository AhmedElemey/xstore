import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/utils/extensions/context_extensions.dart';
import '../../../../shared/widgets/app_cached_network_image.dart';
import '../../domain/entities/cart_item_entity.dart';
import 'quantity_control.dart';

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

  static const double _imageSize = 112;

  @override
  Widget build(BuildContext context) {
    final available = item.isAvailable;
    final compare = item.compareAtPrice;
    final store = item.vendorStoreName.trim();
    final shippingLabel = item.shippingAvailable
        ? (item.shippingCost <= 0
            ? context.l10n.cartShippingFree
            : context.l10n.cartShippingPaid(item.shippingCost.round()))
        : context.l10n.cartPickupOnly;
    final shippingColor = item.shippingAvailable
        ? (item.shippingCost <= 0
            ? AppColors.success
            : context.textSecondary)
        : AppColors.error;

    return Material(
      color: context.surfaceColor,
      borderRadius: BorderRadius.circular(AppSpacing.md),
      child: InkWell(
        onTap: available ? onOpenProduct : null,
        borderRadius: BorderRadius.circular(AppSpacing.md),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: _imageSize,
                    height: _imageSize,
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        Positioned.fill(
                          child: ClipRRect(
                            borderRadius:
                                BorderRadius.circular(AppSpacing.sm),
                            child: AppCachedNetworkImage(
                              imageUrl: item.listingImage,
                              fit: BoxFit.cover,
                              memCacheWidth: 224,
                              memCacheHeight: 224,
                              placeholder: (_, __) => ColoredBox(
                                color: context.backgroundColor,
                                child: Icon(
                                  Icons.image_outlined,
                                  color: context.textDisabled,
                                ),
                              ),
                              errorWidget: (_, __, ___) => ColoredBox(
                                color: context.backgroundColor,
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
                                borderRadius:
                                    BorderRadius.circular(AppSpacing.sm),
                                color: context.textPrimary
                                    .withValues(alpha: 0.45),
                              ),
                            ),
                          ),
                        Positioned(
                          left: -AppSpacing.xs,
                          top: -AppSpacing.xs,
                          child: Checkbox(
                            value: selected,
                            onChanged: available
                                ? (_) => onToggleSelect()
                                : null,
                            activeColor: AppColors.primary,
                            materialTapTargetSize:
                                MaterialTapTargetSize.shrinkWrap,
                            visualDensity: VisualDensity.compact,
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
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                          style: AppTypography.titleSmall.copyWith(
                            fontWeight: FontWeight.w600,
                            height: 1.3,
                            color: available
                                ? context.textPrimary
                                : context.textDisabled,
                          ),
                        ),
                        if (store.isNotEmpty) ...[
                          const SizedBox(height: AppSpacing.xs),
                          Text(
                            store,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppTypography.bodySmall.copyWith(
                              color: available
                                  ? context.textSecondary
                                  : context.textDisabled,
                            ),
                          ),
                        ],
                        const SizedBox(height: AppSpacing.sm),
                        Row(
                          children: [
                            Flexible(
                              child: Text(
                                context.formatCurrency(item.price),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: AppTypography.titleMedium.copyWith(
                                  color: available
                                      ? context.textPrimary
                                      : context.textDisabled,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                            if (compare != null && compare > item.price) ...[
                              const SizedBox(width: AppSpacing.sm),
                              Text(
                                context.formatCurrency(compare),
                                style: AppTypography.bodySmall.copyWith(
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
                            fontWeight: item.shippingAvailable &&
                                    item.shippingCost <= 0
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
                        if (item.condition.trim().isNotEmpty ||
                            item.category.trim().isNotEmpty) ...[
                          const SizedBox(height: AppSpacing.xs),
                          Text(
                            [
                              if (item.condition.trim().isNotEmpty)
                                item.condition.trim(),
                              if (item.category.trim().isNotEmpty)
                                item.category.trim(),
                            ].join(context.l10n.reviewsDotSeparator),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppTypography.labelSmall.copyWith(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  QuantityControl(
                    quantity: item.quantity,
                    maxQuantity: item.maxQuantity,
                    enabled: available,
                    onDecrement: onDecrement,
                    onIncrement: onIncrement,
                    onEditQuantity: onEditQuantity,
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Flexible(
                    child: _ActionPill(
                      label: context.l10n.cartRemove,
                      onPressed: onRemove,
                    ),
                  ),
                  if (available) ...[
                    const SizedBox(width: AppSpacing.sm),
                    Flexible(
                      child: _ActionPill(
                        label: context.l10n.cartSaveForLater,
                        onPressed: onSaveForLater,
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ActionPill extends StatelessWidget {
  const _ActionPill({
    required this.label,
    required this.onPressed,
  });

  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: context.surfaceColor,
      shape: StadiumBorder(
        side: BorderSide(color: context.borderColor),
      ),
      child: InkWell(
        onTap: onPressed,
        customBorder: const StadiumBorder(),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.sm,
            vertical: AppSpacing.xs + 2,
          ),
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: AppTypography.labelSmall.copyWith(
              color: context.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}
