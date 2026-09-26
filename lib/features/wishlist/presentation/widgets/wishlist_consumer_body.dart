import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_typography.dart';
import '../../domain/entities/wishlist_item_entity.dart';
import '../../../../core/network/app_error_messages.dart';
import '../providers/wishlist_provider.dart';
import '../providers/wishlist_state.dart';
import 'move_all_to_cart_bar.dart';
import 'wishlist_empty_state.dart';
// Select + list/grid + sort toolbar lives in wishlist_header_bar.dart —
// uncomment the WishlistHeaderBar line below (and this import) to restore.
// import 'wishlist_header_bar.dart';
import 'wishlist_grid_card.dart';
import 'wishlist_price_drop_banner.dart';
import 'wishlist_selection_bar.dart';
import 'wishlist_sort_row.dart';
import '../../../../core/utils/extensions/context_extensions.dart';
import '../../../../shared/widgets/app_snackbar.dart';
import '../../../../shared/widgets/skeletons/wishlist_skeleton.dart';

String _filterEmptyTitle(BuildContext context, WishlistFilter f) {
  switch (f) {
    case WishlistFilter.all:
      return '';
    case WishlistFilter.available:
      return context.l10n.wishlistNoAvailableItems;
    case WishlistFilter.priceDropped:
      return context.l10n.wishlistNoPriceDroppedItems;
    case WishlistFilter.inCart:
      return context.l10n.wishlistNoInCartItems;
  }
}

class WishlistConsumerBody extends ConsumerStatefulWidget {
  const WishlistConsumerBody({super.key});

  @override
  ConsumerState<WishlistConsumerBody> createState() =>
      _WishlistConsumerBodyState();
}

class _WishlistConsumerBodyState extends ConsumerState<WishlistConsumerBody> {
  @override
  void initState() {
    super.initState();
    // keepAlive + IndexedStack: first mount is the only initState for the
    // whole session. RouteReentryRefresh covers later tab switches, not
    // this first open.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      unawaited(ref.read(wishlistProvider.notifier).fetchWishlist());
    });
  }

  @override
  Widget build(BuildContext context) {
    final notifier = ref.read(wishlistProvider.notifier);
    final state = ref.watch(
      wishlistProvider.select(
        (s) => (
          items: s.items,
          filteredItems: s.filteredItems,
          isLoading: s.isLoading,
          isSelectionMode: s.isSelectionMode,
          selectedItemIds: s.selectedItemIds,
          selectedFilter: s.selectedFilter,
          error: s.error,
        ),
      ),
    );

    ref.listen<String?>(
      wishlistProvider.select((s) => s.error),
      (prev, next) {
      final err = next;
      if (err != null && err != prev && context.mounted) {
        AppSnackbar.error(context, resolveAppError(context, err));
        notifier.clearError();
      }
    });

    final items = state.items;
    final loading = state.isLoading && items.isEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (items.isNotEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            child: Text(
              context.l10n.wishlistItemCount(items.length),
              style: AppTypography.bodySmall.copyWith(
                color: context.textSecondary,
              ),
            ),
          ),
        // App-only: price-drop banner and filter chips.
        const WishlistPriceDropBanner(),
        const WishlistSortRow(),
        // Select + list/grid + sort toolbar — kept in code, hidden for now.
        // const WishlistHeaderBar(),
        Expanded(
          child: loading
              ? const WishlistSkeleton()
              : RefreshIndicator(
                  color: AppColors.primary,
                  onRefresh: () => notifier.fetchWishlist(),
                  child: _buildScrollable(context, state, notifier),
                ),
        ),
        if (state.isSelectionMode && items.isNotEmpty)
          const WishlistSelectionBar()
        else if (!state.isSelectionMode && items.isNotEmpty)
          const MoveAllToCartBar(),
      ],
    );
  }

  Widget _buildScrollable(
    BuildContext context,
    ({
      List<WishlistItemEntity> items,
      List<WishlistItemEntity> filteredItems,
      bool isLoading,
      bool isSelectionMode,
      Set<String> selectedItemIds,
      WishlistFilter selectedFilter,
      String? error,
    }) state,
    Wishlist notifier,
  ) {
    final items = state.items;
    final filtered = state.filteredItems;

    if (items.isEmpty) {
      return const WishlistEmptyState();
    }

    if (filtered.isEmpty) {
      return WishlistEmptyState(
        filterEmptyTitle: _filterEmptyTitle(context, state.selectedFilter),
        onShowAll: () => notifier.applyFilter(WishlistFilter.all),
      );
    }

    return GridView.builder(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.md,
        AppSpacing.lg,
        AppSpacing.x4l,
      ),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: AppSpacing.md,
        crossAxisSpacing: AppSpacing.md,
        mainAxisExtent: WishlistGridCard.extent,
      ),
      itemCount: filtered.length,
      itemBuilder: (context, i) {
        final item = filtered[i];
        return RepaintBoundary(
          child: WishlistGridCard(
            key: ValueKey<String>('wishlist-grid-item-${item.id}'),
            item: item,
            index: i,
            selectionMode: state.isSelectionMode,
            selected: state.selectedItemIds.contains(item.id),
            onToggleSelect: () => notifier.toggleItemSelection(item.id),
          ),
        );
      },
    );
  }
}
