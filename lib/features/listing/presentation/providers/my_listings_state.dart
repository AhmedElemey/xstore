import 'package:freezed_annotation/freezed_annotation.dart';

import '../../domain/entities/listing_entity.dart';

part 'my_listings_state.freezed.dart';

enum SortOption {
  newest,
  oldest,
  priceAsc,
  priceDesc,
  mostViewed,
}

enum ViewMode {
  list,
  grid,
}

@freezed
class MyListingsState with _$MyListingsState {
  const factory MyListingsState({
    @Default([]) List<ListingEntity> listings,
    @Default([]) List<ListingEntity> filteredListings,
    /// `null` means “All”.
    ListingStatus? selectedFilter,
    @Default(SortOption.newest) SortOption selectedSort,
    @Default(ViewMode.list) ViewMode viewMode,
    @Default(false) bool isLoading,
    String? error,
    @Default('') String searchQuery,
  }) = _MyListingsState;
}
