import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/network/connectivity_provider.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../cart/domain/entities/cart_item_entity.dart';
import '../../../cart/presentation/providers/cart_provider.dart';
import '../../domain/entities/wishlist_item_entity.dart';
import '../../domain/repositories/wishlist_repository.dart';
import 'wishlist_dependencies.dart';
import 'wishlist_state.dart';

part 'wishlist_provider.g.dart';

extension WishlistStateX on WishlistState {
  int get itemCount => items.length;

  int get priceDropCount =>
      items.where((e) => (e.priceDropPercent ?? 0) > 0).length;

  int get availableCount => items.where((e) => e.isAvailable).length;
}

@Riverpod(keepAlive: true)
class Wishlist extends _$Wishlist {
  WishlistRepository get _repo => ref.read(wishlistRepositoryProvider);

  String? get _consumerId {
    final u = ref.read(authProvider).valueOrNull;
    if (u == null || u.isVendor) return null;
    return u.id;
  }

  @override
  WishlistState build() {
    // Cart sync: ref.listen(cartProvider) lives on [WishlistScreen] per app spec.
    ref.listen(authProvider, (prev, next) {
      if (next.isLoading) return;
      final u = next.valueOrNull;
      if (u != null && !u.isVendor) {
        Future.microtask(fetchWishlist);
      } else {
        Future.microtask(
          () => state = const WishlistState(),
        );
      }
    });
    return const WishlistState();
  }

  void _applyFilterSort() {
    var list = List<WishlistItemEntity>.from(state.items);
    switch (state.selectedFilter) {
      case WishlistFilter.all:
        break;
      case WishlistFilter.available:
        list = list.where((e) => e.isAvailable).toList();
        break;
      case WishlistFilter.priceDropped:
        list = list.where((e) => (e.priceDropPercent ?? 0) > 0).toList();
        break;
      case WishlistFilter.inCart:
        list = list.where((e) => e.isInCart).toList();
        break;
    }
    switch (state.sortOption) {
      case WishlistSortOption.recentlyAdded:
        list.sort((a, b) => b.addedAt.compareTo(a.addedAt));
        break;
      case WishlistSortOption.priceLowToHigh:
        list.sort((a, b) => a.price.compareTo(b.price));
        break;
      case WishlistSortOption.priceHighToLow:
        list.sort((a, b) => b.price.compareTo(a.price));
        break;
      case WishlistSortOption.priceDrop:
        list.sort((a, b) {
          final da = a.priceDropPercent ?? 0;
          final db = b.priceDropPercent ?? 0;
          return db.compareTo(da);
        });
        break;
      case WishlistSortOption.biggestDiscount:
        list.sort((a, b) {
          double disc(WishlistItemEntity e) {
            final c = e.compareAtPrice;
            if (c == null || c <= e.price) return 0;
            return (c - e.price) / c;
          }

          return disc(b).compareTo(disc(a));
        });
        break;
      case WishlistSortOption.nameAZ:
        list.sort(
          (a, b) => a.listingName.toLowerCase().compareTo(
                b.listingName.toLowerCase(),
              ),
        );
        break;
    }
    state = state.copyWith(filteredItems: list);
  }

  Set<String> _idsFromItems(List<WishlistItemEntity> items) =>
      items.map((e) => e.listingId).toSet();

  Future<void> fetchWishlist() async {
    final id = _consumerId;
    if (id == null) return;
    state = state.copyWith(isLoading: true, error: null);
    final r = await ref.read(getWishlistUseCaseProvider).call(id);
    r.fold(
      (f) => state = state.copyWith(isLoading: false, error: f.toString()),
      (list) {
        final cart = ref.read(cartProvider).items;
        final inCart = cart.map((e) => e.listingId).toSet();
        final patched = list
            .map((e) => e.copyWith(isInCart: inCart.contains(e.listingId)))
            .toList();
        state = state.copyWith(
          isLoading: false,
          items: patched,
          wishlistedListingIds: _idsFromItems(patched),
        );
        _applyFilterSort();
      },
    );
  }

  void syncWithCart(List<CartItemEntity> cartItems) {
    if (state.items.isEmpty) return;
    final inCart = cartItems.map((e) => e.listingId).toSet();
    final next = state.items
        .map((e) => e.copyWith(isInCart: inCart.contains(e.listingId)))
        .toList();
    state = state.copyWith(
      items: next,
      wishlistedListingIds: _idsFromItems(next),
    );
    _applyFilterSort();
  }

  bool isWishlisted(String listingId) =>
      state.wishlistedListingIds.contains(listingId);

  Future<void> toggleWishlist(String listingId) async {
    final id = _consumerId;
    if (id == null) return;
    if (isWishlisted(listingId)) {
      await removeFromWishlistByListingId(listingId, showUndo: true);
      return;
    }
    final snapshot = state.items;
    final snapIds = Set<String>.from(state.wishlistedListingIds);
    WishlistItemEntity stub;
    try {
      stub = await _repo.stubFromListingId(listingId);
    } catch (_) {
      return;
    }
    state = state.copyWith(
      items: [...state.items, stub],
      wishlistedListingIds: {...state.wishlistedListingIds, listingId},
    );
    _applyFilterSort();
    final r = await ref.read(addToWishlistUseCaseProvider).call(
          consumerId: id,
          listingId: listingId,
        );
    r.fold(
      (f) {
        state = state.copyWith(
          items: snapshot,
          wishlistedListingIds: snapIds,
          error: f.toString(),
        );
        _applyFilterSort();
      },
      (e) {
        final without = state.items.where((x) => x.listingId != listingId).toList();
        state = state.copyWith(
          items: [...without, e],
          wishlistedListingIds: {...state.wishlistedListingIds, listingId},
        );
        _applyFilterSort();
      },
    );
  }

  Future<void> removeFromWishlistByListingId(
    String listingId, {
    bool showUndo = true,
  }) async {
    final id = _consumerId;
    if (id == null) return;
    final snapshot = List<WishlistItemEntity>.from(state.items);
    final snapIds = Set<String>.from(state.wishlistedListingIds);
    final idx = snapshot.indexWhere((e) => e.listingId == listingId);
    if (idx < 0) return;
    final removed = snapshot[idx];
    state = state.copyWith(
      items: snapshot.where((e) => e.listingId != listingId).toList(),
      wishlistedListingIds: {...snapIds}..remove(listingId),
      lastRemoved: showUndo ? removed : null,
    );
    _applyFilterSort();
    final r = await ref.read(removeFromWishlistUseCaseProvider).call(
          consumerId: id,
          listingId: listingId,
        );
    r.fold(
      (f) {
        state = state.copyWith(
          items: snapshot,
          wishlistedListingIds: snapIds,
          error: f.toString(),
          lastRemoved: null,
        );
        _applyFilterSort();
      },
      (_) {},
    );
  }

  Future<void> undoRemove() async {
    final last = state.lastRemoved;
    final id = _consumerId;
    if (last == null || id == null) return;
    state = state.copyWith(lastRemoved: null);
    final r = await ref.read(addToWishlistUseCaseProvider).call(
          consumerId: id,
          listingId: last.listingId,
        );
    r.fold(
      (f) => state = state.copyWith(error: f.toString()),
      (e) {
        final without = state.items.where((x) => x.listingId != e.listingId).toList();
        state = state.copyWith(
          items: [...without, e],
          wishlistedListingIds: {
            ...state.wishlistedListingIds,
            e.listingId,
          },
        );
        _applyFilterSort();
      },
    );
  }

  Future<void> removeByItemId(String wishItemId) async {
    try {
      final item = state.items.firstWhere((e) => e.id == wishItemId);
      await removeFromWishlistByListingId(item.listingId);
    } catch (_) {}
  }

  Future<void> moveListingToCart(String listingId) async {
    final id = _consumerId;
    if (id == null) return;
    if (!ref.read(isOnlineProvider)) {
      state = state.copyWith(error: kOfflineErrorCode);
      return;
    }
    state = state.copyWith(isUpdating: true, error: null);
    final r = await ref.read(moveToCartUseCaseProvider).call(
          consumerId: id,
          listingId: listingId,
        );
    state = state.copyWith(isUpdating: false);
    var ok = false;
    r.fold(
      (f) => state = state.copyWith(error: f.toString()),
      (_) => ok = true,
    );
    if (ok) {
      await ref.read(cartProvider.notifier).fetchCart();
      await fetchWishlist();
    }
  }

  Future<void> moveAllToCart() async {
    final id = _consumerId;
    if (id == null) return;
    if (!ref.read(isOnlineProvider)) {
      state = state.copyWith(error: kOfflineErrorCode);
      return;
    }
    // Every in-stock listing: cart add is idempotent; already-in-cart still OK.
    final targets = state.items.where((e) => e.isAvailable).toList();
    state = state.copyWith(isUpdating: true, error: null);
    for (final e in targets) {
      await ref.read(moveToCartUseCaseProvider).call(
            consumerId: id,
            listingId: e.listingId,
          );
    }
    state = state.copyWith(isUpdating: false);
    await ref.read(cartProvider.notifier).fetchCart();
    await fetchWishlist();
  }

  Future<void> addFromCartItem(CartItemEntity item) async {
    final r = await _repo.upsertFromCartItem(item);
    await r.fold(
      (_) async {},
      (_) async => fetchWishlist(),
    );
  }

  void applyFilter(WishlistFilter f) {
    state = state.copyWith(selectedFilter: f);
    _applyFilterSort();
  }

  void applySort(WishlistSortOption o) {
    state = state.copyWith(sortOption: o);
    _applyFilterSort();
  }

  void toggleViewMode() {
    final next = state.viewMode == WishlistViewMode.list
        ? WishlistViewMode.grid
        : WishlistViewMode.list;
    state = state.copyWith(viewMode: next);
  }

  void dismissPriceDropBanner() {
    state = state.copyWith(isPriceDropBannerVisible: false);
  }

  void showPriceDropsFilter() {
    state = state.copyWith(selectedFilter: WishlistFilter.priceDropped);
    _applyFilterSort();
  }

  void toggleSelectionMode() {
    final on = !state.isSelectionMode;
    state = state.copyWith(
      isSelectionMode: on,
      selectedItemIds: on ? state.selectedItemIds : {},
    );
  }

  void toggleItemSelection(String itemId) {
    final next = Set<String>.from(state.selectedItemIds);
    if (next.contains(itemId)) {
      next.remove(itemId);
    } else {
      next.add(itemId);
    }
    state = state.copyWith(selectedItemIds: next);
  }

  void selectAllVisible() {
    state = state.copyWith(
      selectedItemIds: state.filteredItems.map((e) => e.id).toSet(),
    );
  }

  void deselectAll() {
    state = state.copyWith(selectedItemIds: {});
  }

  Future<void> removeSelected() async {
    final ids = List<String>.from(state.selectedItemIds);
    for (final id in ids) {
      await removeByItemId(id);
    }
    state = state.copyWith(
      isSelectionMode: false,
      selectedItemIds: {},
    );
  }

  Future<void> addSelectedToCart() async {
    final id = _consumerId;
    if (id == null) return;
    final selected = state.filteredItems
        .where((e) => state.selectedItemIds.contains(e.id))
        .where((e) => e.isAvailable)
        .toList();
    state = state.copyWith(isUpdating: true);
    for (final e in selected) {
      await ref.read(moveToCartUseCaseProvider).call(
            consumerId: id,
            listingId: e.listingId,
          );
    }
    state = state.copyWith(
      isUpdating: false,
      isSelectionMode: false,
      selectedItemIds: {},
    );
    await ref.read(cartProvider.notifier).fetchCart();
    await fetchWishlist();
  }

  void clearError() {
    state = state.copyWith(error: null);
  }
}
