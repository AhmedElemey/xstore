import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../shared/widgets/app_cached_network_image.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_typography.dart';
import '../../domain/entities/cart_item_entity.dart';
import 'quantity_control.dart';
import '../../../../core/utils/extensions/context_extensions.dart';

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

  @override
  Widget build(BuildContext context) {
    final available = item.isAvailable;
    final compare = item.compareAtPrice;

    return Material(
      color: context.surfaceColor,
      borderRadius: BorderRadius.circular(AppSpacing.lg),
      elevation: 1,
      shadowColor: context.textPrimary.withValues(alpha: 0.06),
      child: InkWell(
        onTap: available ? onOpenProduct : null,
        borderRadius: BorderRadius.circular(AppSpacing.lg),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Checkbox(
                    value: selected,
                    onChanged: available ? (_) => onToggleSelect() : null,
                    activeColor: AppColors.primary,
                  ),
                  Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(AppSpacing.md),
                        child: SizedBox(
                          width: AppSpacing.x4l + AppSpacing.x2l,
                          height: AppSpacing.x4l + AppSpacing.x2l,
                          child: AppCachedNetworkImage(
                            imageUrl: item.listingImage,
                            fit: BoxFit.cover,
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
                                  BorderRadius.circular(AppSpacing.md),
                              color: context.textPrimary.withValues(alpha: 0.45),
                            ),
                          ),
                        ),
                      if (!available)
                        Positioned(
                          left: AppSpacing.xs,
                          top: AppSpacing.xs,
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              color: AppColors.error,
                              borderRadius:
                                  BorderRadius.circular(AppSpacing.xs),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: AppSpacing.sm,
                                vertical: AppSpacing.xs,
                              ),
                              child: Text(
                                context.l10n.cartUnavailableBadge,
                                style: AppTypography.titleSmall.copyWith(
                                  color: AppColors.white,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        ),
                    ],
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
                            fontWeight: FontWeight.w700,
                            color: available
                                ? context.textPrimary
                                : context.textDisabled,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        Wrap(
                          spacing: AppSpacing.xs,
                          runSpacing: AppSpacing.xs,
                          children: [
                            _chip(context, item.condition),
                            _chip(context, item.category),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        Text(
                          context.formatCurrency(item.price),
                          style: AppTypography.titleSmall.copyWith(
                            color: available
                                ? AppColors.primary
                                : context.textDisabled,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        if (compare != null && compare > item.price)
                          Text(
                            context.formatCurrency(compare),
                            style: AppTypography.bodySmall.copyWith(
                              color: context.textSecondary,
                              decoration: TextDecoration.lineThrough,
                              
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              Align(
                alignment: Alignment.centerRight,
                child: QuantityControl(
                  quantity: item.quantity,
                  maxQuantity: item.maxQuantity,
                  enabled: available,
                  onDecrement: onDecrement,
                  onIncrement: onIncrement,
                  onEditQuantity: onEditQuantity,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                item.shippingAvailable
                    ? (item.shippingCost <= 0
                        ? context.l10n.cartShippingFree
                        : context.l10n.cartShippingPaid(item.shippingCost.round()))
                    : context.l10n.cartPickupOnly,
                style: AppTypography.labelSmall.copyWith(
                  color: item.shippingAvailable
                      ? (item.shippingCost <= 0
                          ? AppColors.success
                          : context.textSecondary)
                      : AppColors.error,
                ),
              ),
              if (!available) ...[
                const SizedBox(height: AppSpacing.sm),
                Text(
                  context.l10n.cartUnavailableHint,
                  style: AppTypography.labelSmall.copyWith(
                    color: AppColors.error,
                  ),
                ),
              ],
              const SizedBox(height: AppSpacing.md),
              Row(
                children: [
                  TextButton(
                    onPressed: onRemove,
                    child: Text(
                      context.l10n.cartRemove,
                      style: AppTypography.labelLarge.copyWith(
                        color: AppColors.error,
                      ),
                    ),
                  ),
                  const Spacer(),
                  if (available)
                    TextButton(
                      onPressed: onSaveForLater,
                      child: Text(
                        context.l10n.cartSaveForLater,
                        style: AppTypography.labelLarge.copyWith(
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _chip(BuildContext context, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: context.backgroundColor,
        borderRadius: BorderRadius.circular(AppSpacing.xs),
      ),
      child: Text(
        label,
        style: AppTypography.labelSmall.copyWith(
          color: context.textSecondary,
        ),
      ),
    );
  }
}
