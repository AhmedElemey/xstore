import 'package:freezed_annotation/freezed_annotation.dart';

import '../domain/entities/search_result_entity.dart';

part 'explore_state.freezed.dart';

enum ExploreSortOption {
  relevance,
  priceAsc,
  priceDesc,
  ratingDesc,
}

enum ExploreViewMode {
  grid,
  list,
}

@freezed
class FilterState with _$FilterState {
  const factory FilterState({
    @Default(<String>[]) List<String> categories,
    @Default(<String>[]) List<String> conditions,
    double? minPrice,
    double? maxPrice,
    double? minRating,
    String? location,
    @Default(false) bool shippingOnly,
  }) = _FilterState;
}

@freezed
class ExploreState with _$ExploreState {
  const factory ExploreState({
    @Default('') String query,
    @Default(<SearchResultEntity>[]) List<SearchResultEntity> results,
    @Default(<String>[]) List<String> suggestions,
    @Default(FilterState()) FilterState filters,
    @Default(ExploreSortOption.relevance) ExploreSortOption sortOption,
    @Default(ExploreViewMode.grid) ExploreViewMode viewMode,
    @Default(false) bool isLoadingMore,
    @Default(true) bool hasMore,
    @Default(1) int page,
    @Default(false) bool isSearching,
  }) = _ExploreState;
}
