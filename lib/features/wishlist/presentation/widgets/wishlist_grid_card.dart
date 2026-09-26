import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/utils/extensions/context_extensions.dart';
import '../../../../shared/widgets/app_cached_network_image.dart';
import '../../../../shared/widgets/app_snackbar.dart';
import '../../../../shared/widgets/orbit_widgets.dart';
import '../../domain/entities/wishlist_item_entity.dart';
import '../providers/wishlist_provider.dart';
import 'price_drop_badge.dart';

/// Orbit wishlist tile: photo, name, amber price (or out of stock) and the
/// heart that removes it. The small cart disc is app-only (the design has
/// no per-item add).
class WishlistGridCard extends ConsumerWidget {
  const WishlistGridCard({
    super.key,
    required this.item,
    required this.index,
    required this.selectionMode,
    required this.selected,
    required this.onToggleSelect,
  });

  /// Grid row height: 130 photo + name + price row + padding.
  static const double extent = 224;

  final WishlistItemEntity item;

  /// Picks the placeholder orb colour.
  final int index;
  final bool selectionMode;
  final bool selected;
  final VoidCallback onToggleSelect;

  Future<void> _remove(BuildContext context, WidgetRef ref) async {
    await ref
        .read(wishlistProvider.notifier)
        .removeFromWishlistByListingId(item.listingId, showUndo: true);
    if (!context.mounted) return;
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

  Future<void> _addToCart(BuildContext context, WidgetRef ref) async {
    HapticFeedback.lightImpact();
    await ref.read(wishlistProvider.notifier).moveListingToCart(item.listingId);
    if (!context.mounted) return;
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
    final drop = item.effectiveDropPercent;
    final dpr = MediaQuery.devicePixelRatioOf(context);

    return Opacity(
      opacity: item.isAvailable ? 1 : 0.7,
      child: GlassCard(
        radius: 22,
        padding: const EdgeInsets.all(AppSpacing.sm + 2),
        borderColor: selected ? context.primaryColor : null,
        onTap: selectionMode
            ? onToggleSelect
            : () => context.push('${AppRoutes.product}/${item.listingId}'),
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: SizedBox(
                    height: 130,
                    child: img == null
                        ? DecoratedBox(
                            decoration: BoxDecoration(
                              gradient: orbitOrbGradient(index),
                            ),
                          )
                        : LayoutBuilder(
                            builder: (context, c) => AppCachedNetworkImage(
                              imageUrl: img,
                              fit: BoxFit.cover,
                              memCacheWidth: (c.maxWidth * dpr).round(),
                            ),
                          ),
                  ),
                ),
                const Gap(AppSpacing.sm - 2),
                Text(
                  item.listingName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.bodyMedium.copyWith(
                    fontWeight: FontWeight.w700,
                    color: context.textPrimary,
                  ),
                ),
                const Spacer(),
                Row(
                  children: [
                    Expanded(
                      child: item.isAvailable
                          ? Text(
                              context.formatCurrency(item.price),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: AppTypography.bodyMedium.copyWith(
                                fontWeight: FontWeight.w700,
                                color: context.cashColor,
                                fontFeatures: const [
                                  FontFeature.tabularFigures(),
                                ],
                              ),
                            )
                          : Text(
                              context.l10n.wishlistOutOfStock,
                              style: AppTypography.bodySmall.copyWith(
                                fontWeight: FontWeight.w700,
                                color: AppColors.errorLight,
                              ),
                            ),
                    ),
                    if (!selectionMode && item.isAvailable)
                      _CartDisc(
                        inCart: item.isInCart,
                        onTap: item.isInCart
                            ? () => context.push(AppRoutes.cart)
                            : () => _addToCart(context, ref),
                      ),
                  ],
                ),
              ],
            ),
            if (drop > 0)
              PositionedDirectional(
                top: AppSpacing.sm,
                start: AppSpacing.sm,
                child: PriceDropBadge(percent: drop),
              ),
            PositionedDirectional(
              top: AppSpacing.xs,
              end: AppSpacing.xs,
              child: selectionMode
                  ? Checkbox(
                      value: selected,
                      onChanged: (_) => onToggleSelect(),
                    )
                  : _HeartDisc(onTap: () => _remove(context, ref)),
            ),
          ],
        ),
      ),
    );
  }
}

class _HeartDisc extends StatelessWidget {
  const _HeartDisc({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: context.backgroundColor.withValues(alpha: 0.6),
      shape: const CircleBorder(),
      clipBehavior: Clip.antiAlias,
      child: IconButton(
        tooltip: context.l10n.wishlistRemove,
        onPressed: onTap,
        constraints: const BoxConstraints.tightFor(width: 44, height: 44),
        icon: const Icon(
          Icons.favorite_rounded,
          size: 20,
          color: AppColors.errorLight,
        ),
      ),
    );
  }
}

class _CartDisc extends StatelessWidget {
  const _CartDisc({required this.inCart, required this.onTap});

  final bool inCart;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      tooltip: inCart
          ? context.l10n.wishlistInCartCta
          : context.l10n.wishlistAddToCart,
      onPressed: onTap,
      constraints: const BoxConstraints.tightFor(width: 40, height: 40),
      padding: EdgeInsets.zero,
      icon: Icon(
        LucideIcons.shoppingCart,
        size: 18,
        color: inCart ? AppColors.success : context.primaryColor,
      ),
    );
  }
}
