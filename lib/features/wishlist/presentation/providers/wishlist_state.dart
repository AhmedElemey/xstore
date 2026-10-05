import 'package:freezed_annotation/freezed_annotation.dart';

import '../../domain/entities/wishlist_item_entity.dart';

part 'wishlist_state.freezed.dart';

enum WishlistFilter {
  all,
  available,
  priceDropped,
  inCart,
}

enum WishlistSortOption {
  priceLowToHigh,
  priceHighToLow,
  nameAZ,
}

@freezed
class WishlistState with _$WishlistState {
  const factory WishlistState({
    @Default([]) List<WishlistItemEntity> items,
    @Default([]) List<WishlistItemEntity> filteredItems,
    @Default(<String>{}) Set<String> wishlistedListingIds,
    @Default(WishlistFilter.all) WishlistFilter selectedFilter,
    @Default(WishlistSortOption.priceLowToHigh) WishlistSortOption sortOption,
    @Default(true) bool isPriceDropBannerVisible,
    @Default(false) bool isLoading,
    @Default(false) bool isUpdating,
    String? error,
    WishlistItemEntity? lastRemoved,
  }) = _WishlistState;
}
