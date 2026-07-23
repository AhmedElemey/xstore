import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../shared/widgets/app_cached_network_image.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../shared/widgets/app_snackbar.dart';
import '../../../../shared/widgets/wish_heart_button.dart';
import '../../domain/entities/wishlist_item_entity.dart';
import '../providers/wishlist_provider.dart';
import 'price_drop_badge.dart';
import '../../../../core/utils/extensions/context_extensions.dart';

class WishlistGridCard extends ConsumerWidget {
  const WishlistGridCard({
    super.key,
    required this.item,
    required this.selectionMode,
    required this.selected,
    required this.onToggleSelect,
  });

  final WishlistItemEntity item;
  final bool selectionMode;
  final bool selected;
  final VoidCallback onToggleSelect;

  void _undoSnack(BuildContext context, WidgetRef ref) {
    AppSnackbar.show(
      context,
      message: context.l10n.wishlistRemovedSnack,
      duration: const Duration(seconds: 5),
      action: SnackBarAction(
        label: context.l10n.cartUndo,
        onPressed: () => ref.read(wishlistProvider.notifier).undoRemove(),
      ),
    );
  }

  void _addedToCartSnack(BuildContext context) {
    AppSnackbar.show(
      context,
      message: context.l10n.wishlistSingleAddedToCart,
      action: SnackBarAction(
        label: context.l10n.wishlistViewCart,
        onPressed: () => context.push(AppRoutes.cart),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final img = item.listingImages.isNotEmpty ? item.listingImages.first : null;
    final drop = item.priceDropPercent ?? 0;
    final strike = item.compareAtPrice != null && item.compareAtPrice! > item.price
        ? item.compareAtPrice
        : (item.previousPrice != null && item.previousPrice! > item.price
            ? item.previousPrice
            : null);

    Widget inner = Material(
      color: context.surfaceColor,
      elevation: 1,
      shadowColor: context.textPrimary.withValues(alpha: 0.06),
      borderRadius: BorderRadius.circular(AppSpacing.lg),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: selectionMode
            ? onToggleSelect
            : () => context.push('${AppRoutes.product}/${item.listingId}'),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(
              height: 160,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  if (img != null)
                    AppCachedNetworkImage(
                      imageUrl: img,
                      fit: BoxFit.cover,
                      placeholder: (_, __) =>
                          ColoredBox(color: context.textDisabled),
                      errorWidget: (_, __, ___) =>
                          ColoredBox(color: context.textDisabled),
                    )
                  else
                    ColoredBox(color: context.textDisabled),
                  if (drop > 0)
                    Positioned(
                      left: AppSpacing.sm,
                      top: AppSpacing.sm,
                      child: PriceDropBadge(percent: drop),
                    ),
                  if (selectionMode)
                    Positioned(
                      left: AppSpacing.sm,
                      bottom: AppSpacing.sm,
                      child: Material(
                        color: context.surfaceColor.withValues(alpha: 0.95),
                        borderRadius: BorderRadius.circular(AppSpacing.xs),
                        child: Checkbox(
                          value: selected,
                          onChanged: (_) => onToggleSelect(),
                          materialTapTargetSize:
                              MaterialTapTargetSize.shrinkWrap,
                        ),
                      ),
                    ),
                  if (!selectionMode)
                    Positioned(
                      right: AppSpacing.sm,
                      top: AppSpacing.sm,
                      child: WishHeartButton(
                        listingId: item.listingId,
                        size: AppSpacing.x2l,
                      ),
                    ),
                  if (!item.isAvailable)
                    ColoredBox(
                      color: context.textPrimary.withValues(alpha: 0.45),
                      child: Center(
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.sm,
                            vertical: AppSpacing.xs,
                          ),
                          decoration: BoxDecoration(
                            color: context.surfaceColor,
                            borderRadius: BorderRadius.circular(AppSpacing.xs),
                          ),
                          child: Text(
                            context.l10n.wishlistOutOfStock,
                            style: AppTypography.labelSmall.copyWith(
                              color: context.textSecondary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ),
                  if (item.isInCart && item.isAvailable)
                    Positioned(
                      left: AppSpacing.sm,
                      bottom: AppSpacing.sm,
                      right: AppSpacing.sm,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          vertical: AppSpacing.xs,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.success.withValues(alpha: 0.92),
                          borderRadius: BorderRadius.circular(AppSpacing.xs),
                        ),
                        child: Text(
                          context.l10n.wishlistInCartBadge,
                          textAlign: TextAlign.center,
                          style: AppTypography.labelSmall.copyWith(
                            color: AppColors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
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
                    item.listingName,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: AppTypography.titleMedium.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Row(
                    children: [
                      Text(
                        context.formatCurrency(item.price),
                        style: AppTypography.labelLarge.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      if (strike != null) ...[
                        const SizedBox(width: AppSpacing.sm),
                        Expanded(
                          child: Text(
                            context.formatCurrency(strike),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppTypography.bodySmall.copyWith(
                              decoration: TextDecoration.lineThrough,
                              color: context.textSecondary,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Row(
                    children: [
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
                  const SizedBox(height: AppSpacing.md),
                  SizedBox(
                    width: double.infinity,
                    child: item.isInCart
                        ? FilledButton(
                            style: FilledButton.styleFrom(
                              backgroundColor: AppColors.success,
                              padding: const EdgeInsets.symmetric(
                                vertical: AppSpacing.sm,
                              ),
                            ),
                            onPressed: () => context.push(AppRoutes.cart),
                            child: Text(context.l10n.wishlistInCartCta),
                          )
                        : FilledButton(
                            style: FilledButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                vertical: AppSpacing.sm,
                              ),
                            ),
                            onPressed: item.isAvailable
                                ? () async {
                                    HapticFeedback.lightImpact();
                                    await ref
                                        .read(wishlistProvider.notifier)
                                        .moveListingToCart(item.listingId);
                                    if (context.mounted) {
                                      _addedToCartSnack(context);
                                    }
                                  }
                                : null,
                            child: Text(
                              item.isAvailable
                                  ? context.l10n.wishlistAddToCart
                                  : context.l10n.wishlistOutOfStock,
                            ),
                          ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );

    if (selectionMode) {
      return inner;
    }

    return Dismissible(
      key: ValueKey<String>('wishlist-grid-${item.id}'),
      direction: DismissDirection.horizontal,
      background: Container(
        color: AppColors.success,
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.only(left: AppSpacing.lg),
        child: const Icon(LucideIcons.shoppingCart, color: AppColors.white),
      ),
      secondaryBackground: Container(
        color: AppColors.error,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: AppSpacing.lg),
        child: const Icon(LucideIcons.trash2, color: AppColors.white),
      ),
      confirmDismiss: (dir) async {
        if (dir == DismissDirection.startToEnd) {
          if (item.isInCart) {
            if (context.mounted) context.push(AppRoutes.cart);
          } else if (item.isAvailable) {
            await ref
                .read(wishlistProvider.notifier)
                .moveListingToCart(item.listingId);
            if (context.mounted) _addedToCartSnack(context);
          }
          return false;
        }
        if (dir == DismissDirection.endToStart) {
          await ref.read(wishlistProvider.notifier).removeFromWishlistByListingId(
                item.listingId,
                showUndo: true,
              );
          if (context.mounted) _undoSnack(context, ref);
          return true;
        }
        return false;
      },
      child: inner,
    );
  }
}
