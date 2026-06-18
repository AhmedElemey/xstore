import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/network/image_cache_manager.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../shared/widgets/app_snackbar.dart';
import '../../domain/entities/wishlist_item_entity.dart';
import '../providers/wishlist_provider.dart';
import 'price_drop_badge.dart';
import '../../../../core/utils/extensions/context_extensions.dart';

class WishlistItemCard extends ConsumerWidget {
  const WishlistItemCard({
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

  String _shippingLine(BuildContext context, WishlistItemEntity e) {
    if (!e.shippingAvailable) return context.l10n.cartPickupOnly;
    if (e.shippingCost <= 0) return context.l10n.cartShippingFree;
    return context.l10n.cartShippingPaid(e.shippingCost.round());
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

    Widget card = Material(
      color: context.surfaceColor,
      elevation: 1,
      shadowColor: context.textPrimary.withValues(alpha: 0.06),
      borderRadius: BorderRadius.circular(AppSpacing.lg),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: selectionMode
            ? onToggleSelect
            : () => context.push('${AppRoutes.product}/${item.listingId}'),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (selectionMode) ...[
                    Padding(
                      padding: const EdgeInsets.only(right: AppSpacing.sm),
                      child: Checkbox(
                        value: selected,
                        onChanged: (_) => onToggleSelect(),
                        activeColor: AppColors.primary,
                      ),
                    ),
                  ],
                  Stack(
                    clipBehavior: Clip.none,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(AppSpacing.md),
                        child: SizedBox(
                          width: 90,
                          height: 90,
                          child: img != null
                              ? CachedNetworkImage(
                                  imageUrl: img,
                                  cacheManager: AppImageCacheManager.instance,
                                  fit: BoxFit.cover,
                                  placeholder: (_, __) => ColoredBox(
                                    color: context.textDisabled,
                                  ),
                                  errorWidget: (_, __, ___) => ColoredBox(
                                    color: context.textDisabled,
                                  ),
                                )
                              : ColoredBox(color: context.textDisabled),
                        ),
                      ),
                      if (drop > 0)
                        Positioned(
                          left: AppSpacing.xs,
                          top: AppSpacing.xs,
                          child: PriceDropBadge(percent: drop),
                        ),
                      if (!item.isAvailable)
                        Positioned.fill(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(AppSpacing.md),
                            child: ColoredBox(
                              color: context.textPrimary.withValues(
                                alpha: 0.45,
                              ),
                              child: Center(
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: AppSpacing.sm,
                                    vertical: AppSpacing.xs,
                                  ),
                                  decoration: BoxDecoration(
                                    color: context.surfaceColor,
                                    borderRadius: BorderRadius.circular(
                                      AppSpacing.xs,
                                    ),
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
                          ),
                        ),
                      if (item.isInCart && item.isAvailable)
                        Positioned.fill(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(AppSpacing.md),
                            child: Align(
                              alignment: Alignment.bottomCenter,
                              child: Container(
                                width: double.infinity,
                                padding: const EdgeInsets.symmetric(
                                  vertical: AppSpacing.xs,
                                ),
                                color: AppColors.success.withValues(alpha: 0.92),
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
                          ),
                        ),
                    ],
                  ),
                  const Gap(AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.listingName,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: AppTypography.bodyLarge.copyWith(
                            fontWeight: FontWeight.w700,
                            color: context.textPrimary,
                          ),
                        ),
                        const Gap(AppSpacing.xs),
                        Wrap(
                          spacing: AppSpacing.xs,
                          runSpacing: AppSpacing.xs,
                          children: [
                            _chip(context, item.condition),
                            _chip(context, item.category),
                          ],
                        ),
                        if (drop > 0) ...[
                          const Gap(AppSpacing.xs),
                          Text(
                            '↓ ${context.l10n.wishlistPriceDropBadge} $drop%',
                            style: AppTypography.labelSmall.copyWith(
                              color: AppColors.success,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                        const Gap(AppSpacing.sm),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              context.formatCurrency(item.price),
                              style: AppTypography.bodyLarge.copyWith(
                                color: AppColors.primary,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            if (strike != null) ...[
                              const Gap(AppSpacing.sm),
                              Text(
                                context.formatCurrency(strike),
                                style: AppTypography.bodySmall.copyWith(
                                  color: context.textSecondary,
                                  decoration: TextDecoration.lineThrough,
                                ),
                              ),
                            ],
                          ],
                        ),
                        const Gap(AppSpacing.xs),
                        Row(
                          children: [
                            Icon(
                              LucideIcons.star,
                              size: AppSpacing.md,
                              color: AppColors.warning,
                            ),
                            Text(
                              ' ${item.rating.toStringAsFixed(1)} · ${item.reviewCount} ${context.l10n.wishlistReviewsWord}',
                              style: AppTypography.bodySmall.copyWith(
                                color: context.textSecondary,
                              ),
                            ),
                          ],
                        ),
                        const Gap(AppSpacing.xs),
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                item.vendorStoreName,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: AppTypography.bodySmall.copyWith(
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                            if (item.isVendorVerified)
                              Icon(
                                LucideIcons.badgeCheck,
                                size: AppSpacing.lg,
                                color: AppColors.primary,
                              ),
                          ],
                        ),
                        const Gap(AppSpacing.xs),
                        Text(
                          _shippingLine(context, item),
                          style: AppTypography.bodySmall.copyWith(
                            color: context.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              if (!selectionMode) ...[
                const Gap(AppSpacing.md),
                Divider(height: 1),
                const Gap(AppSpacing.sm),
                Row(
                  children: [
                    TextButton(
                      onPressed: () async {
                        await ref
                            .read(wishlistProvider.notifier)
                            .removeFromWishlistByListingId(
                              item.listingId,
                              showUndo: true,
                            );
                        if (context.mounted) _undoSnack(context, ref);
                      },
                      child: Text(
                        context.l10n.wishlistRemove,
                        style: AppTypography.labelLarge.copyWith(
                          color: AppColors.error,
                        ),
                      ),
                    ),
                    const Spacer(),
                    if (item.isInCart)
                      FilledButton(
                        style: FilledButton.styleFrom(
                          backgroundColor: AppColors.success,
                        ),
                        onPressed: () => context.push(AppRoutes.cart),
                        child: Text(context.l10n.wishlistInCartCta),
                      )
                    else
                      FilledButton(
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
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );

    if (selectionMode) {
      return card;
    }

    return Dismissible(
      key: ValueKey<String>('wishlist-list-${item.id}'),
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
      child: card,
    );
  }
}

Widget _chip(BuildContext context, String text) {
  return Container(
    padding: const EdgeInsets.symmetric(
      horizontal: AppSpacing.sm,
      vertical: AppSpacing.xs,
    ),
    decoration: BoxDecoration(
      color: context.textDisabled.withValues(alpha: 0.35),
      borderRadius: BorderRadius.circular(AppSpacing.xs),
    ),
    child: Text(
      text,
      style: AppTypography.labelSmall.copyWith(
        color: context.textSecondary,
      ),
    ),
  );
}
