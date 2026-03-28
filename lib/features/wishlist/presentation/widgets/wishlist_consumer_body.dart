import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_strings.dart';
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
    final state = ref.watch(wishlistProvider);
    final notifier = ref.read(wishlistProvider.notifier);

    ref.listen(wishlistProvider, (prev, next) {
      final err = next.error;
      if (err != null && err != prev?.error && context.mounted) {
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
    WishlistState state,
    Wishlist notifier,
  ) {
    final items = state.items;
    final filtered = state.filteredItems;

    if (items.isEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: const [
          WishlistEmptyState(),
        ],
      );
    }

    if (filtered.isEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          WishlistEmptyState(
            filterEmptyTitle: _filterEmptyTitle(state.selectedFilter),
            onShowAll: () => notifier.applyFilter(WishlistFilter.all),
          ),
        ],
      );
    }

    if (state.viewMode == WishlistViewMode.list) {
      return ListView.separated(
        physics: const AlwaysScrollableScrollPhysics(),
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
          return WishlistItemCard(
            item: item,
            selectionMode: state.isSelectionMode,
            selected: state.selectedItemIds.contains(item.id),
            onToggleSelect: () => notifier.toggleItemSelection(item.id),
          );
        },
      );
    }

    return GridView.builder(
      physics: const AlwaysScrollableScrollPhysics(),
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
        return WishlistGridCard(
          item: item,
          selectionMode: state.isSelectionMode,
          selected: state.selectedItemIds.contains(item.id),
          onToggleSelect: () => notifier.toggleItemSelection(item.id),
        );
      },
    );
  }
}
