import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_strings.dart';
import '../../domain/entities/wishlist_item_entity.dart';
import '../providers/wishlist_provider.dart';
import '../providers/wishlist_state.dart';
import 'move_all_to_cart_bar.dart';
import 'wishlist_empty_state.dart';
import 'wishlist_grid_card.dart';
import 'wishlist_header_bar.dart';
import 'wishlist_item_card.dart';
import 'wishlist_price_drop_banner.dart';
import 'wishlist_selection_bar.dart';
import 'wishlist_sort_row.dart';

String _filterEmptyTitle(WishlistFilter f) {
  switch (f) {
    case WishlistFilter.all:
      return '';
    case WishlistFilter.available:
      return AppStrings.wishlistNoAvailableItems;
    case WishlistFilter.priceDropped:
      return AppStrings.wishlistNoPriceDroppedItems;
    case WishlistFilter.inCart:
      return AppStrings.wishlistNoInCartItems;
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
          viewMode: s.viewMode,
          error: s.error,
        ),
      ),
    );

    ref.listen<String?>(
      wishlistProvider.select((s) => s.error),
      (prev, next) {
      final err = next;
      if (err != null && err != prev && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(err)),
        );
        notifier.clearError();
      }
    });

    final items = state.items;
    final loading = state.isLoading && items.isEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const WishlistHeaderBar(),
        const WishlistPriceDropBanner(),
        const WishlistSortRow(),
        Expanded(
          child: loading
              ? const Center(child: CircularProgressIndicator.adaptive())
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
      WishlistViewMode viewMode,
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
        filterEmptyTitle: _filterEmptyTitle(state.selectedFilter),
        onShowAll: () => notifier.applyFilter(WishlistFilter.all),
      );
    }

    if (state.viewMode == WishlistViewMode.list) {
      return ListView.separated(
        physics: const AlwaysScrollableScrollPhysics(),
        cacheExtent: 1000,
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.md,
          AppSpacing.md,
          AppSpacing.md,
          AppSpacing.x4l,
        ),
        itemCount: filtered.length,
        separatorBuilder: (_, __) => const Gap(AppSpacing.md),
        itemBuilder: (context, i) {
          final item = filtered[i];
          return RepaintBoundary(
            child: WishlistItemCard(
              key: ValueKey<String>('wishlist-list-item-${item.id}'),
              item: item,
              selectionMode: state.isSelectionMode,
              selected: state.selectedItemIds.contains(item.id),
              onToggleSelect: () => notifier.toggleItemSelection(item.id),
            ),
          );
        },
      );
    }

    return GridView.builder(
      physics: const AlwaysScrollableScrollPhysics(),
      cacheExtent: 1000,
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.md,
        AppSpacing.md,
        AppSpacing.md,
        AppSpacing.x4l,
      ),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: AppSpacing.md,
        crossAxisSpacing: AppSpacing.md,
        childAspectRatio: 0.58,
      ),
      itemCount: filtered.length,
      itemBuilder: (context, i) {
        final item = filtered[i];
        return RepaintBoundary(
          child: WishlistGridCard(
            key: ValueKey<String>('wishlist-grid-item-${item.id}'),
            item: item,
            selectionMode: state.isSelectionMode,
            selected: state.selectedItemIds.contains(item.id),
            onToggleSelect: () => notifier.toggleItemSelection(item.id),
          ),
        );
      },
    );
  }
}
