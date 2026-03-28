import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/constants/app_strings.dart';
import '../../../core/constants/prefs_keys.dart';
import '../../../shared/providers/shared_providers.dart';
import '../domain/entities/search_result_entity.dart';
import 'explore_dependencies.dart';
import 'explore_state.dart';

part 'explore_provider.g.dart';

@riverpod
class Explore extends _$Explore {
  Timer? _debounce;

  @override
  ExploreState build() {
    ref.onDispose(() => _debounce?.cancel());
    return const ExploreState();
  }

  void bootstrapFromRouteCategory(String? categoryKey) {
    final prefix = switch (categoryKey) {
      AppStrings.categoryQueryMens => 'men ',
      AppStrings.categoryQueryWomens => 'women ',
      _ => '',
    };
    if (prefix.isNotEmpty) {
      onQueryChanged(prefix);
    }
  }

  void onQueryChanged(String q) {
    state = state.copyWith(query: q);
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), () {
      unawaited(search(q));
    });
    unawaited(_loadSuggestions(q));
  }

  Future<void> _loadSuggestions(String q) async {
    if (q.isEmpty) {
      state = state.copyWith(suggestions: []);
      return;
    }
    final result = await ref.read(getSuggestionsUseCaseProvider).call(q);
    result.fold(
      (_) {},
      (s) => state = state.copyWith(suggestions: s),
    );
  }

  Future<void> search(String q) async {
    state = state.copyWith(isSearching: true, page: 1);
    await _persistRecent(q);
    final result = await ref.read(searchListingsUseCaseProvider).call(
          query: q,
          page: 1,
        );
    result.fold(
      (_) {
        state = state.copyWith(isSearching: false, results: []);
      },
      (list) {
        final filtered = _clientFilter(list);
        final sorted = _sort(filtered);
        state = state.copyWith(
          isSearching: false,
          results: sorted,
          hasMore: list.length >= 6,
          page: 1,
        );
      },
    );
  }

  Future<void> loadMore() async {
    if (state.isLoadingMore || !state.hasMore) return;
    state = state.copyWith(isLoadingMore: true);
    final next = state.page + 1;
    final result = await ref.read(searchListingsUseCaseProvider).call(
          query: state.query,
          page: next,
        );
    result.fold(
      (_) => state = state.copyWith(isLoadingMore: false),
      (list) {
        final filtered = _clientFilter(list);
        final merged = [...state.results, ...filtered];
        state = state.copyWith(
          isLoadingMore: false,
          results: _sort(merged),
          page: next,
          hasMore: list.length >= 6,
        );
      },
    );
  }

  void applyFilters(FilterState f) {
    state = state.copyWith(filters: f);
    unawaited(search(state.query));
  }

  void resetFilters() {
    state = state.copyWith(filters: const FilterState());
    unawaited(search(state.query));
  }

  void setSort(ExploreSortOption o) {
    state = state.copyWith(sortOption: o);
    state = state.copyWith(results: _sort(state.results));
  }

  void toggleViewMode() {
    final next = state.viewMode == ExploreViewMode.grid
        ? ExploreViewMode.list
        : ExploreViewMode.grid;
    state = state.copyWith(viewMode: next);
  }

  void clearQueryField() {
    state = state.copyWith(query: '', suggestions: []);
    unawaited(search(''));
  }

  List<SearchResultEntity> _clientFilter(List<SearchResultEntity> raw) {
    final f = state.filters;
    return raw.where((e) {
      if (f.categories.isNotEmpty && !f.categories.contains(e.category)) {
        return false;
      }
      if (f.conditions.isNotEmpty && !f.conditions.contains(e.condition)) {
        return false;
      }
      if (f.minPrice != null && e.price < f.minPrice!) return false;
      if (f.maxPrice != null && e.price > f.maxPrice!) return false;
      if (f.minRating != null && e.rating < f.minRating!) return false;
      if (f.location != null &&
          f.location!.isNotEmpty &&
          !e.location.toLowerCase().contains(f.location!.toLowerCase())) {
        return false;
      }
      if (f.shippingOnly && !e.hasShipping) return false;
      return true;
    }).toList();
  }

  List<SearchResultEntity> _sort(List<SearchResultEntity> list) {
    final l = List<SearchResultEntity>.from(list);
    switch (state.sortOption) {
      case ExploreSortOption.relevance:
        break;
      case ExploreSortOption.priceAsc:
        l.sort((a, b) => a.price.compareTo(b.price));
        break;
      case ExploreSortOption.priceDesc:
        l.sort((a, b) => b.price.compareTo(a.price));
        break;
      case ExploreSortOption.ratingDesc:
        l.sort((a, b) => b.rating.compareTo(a.rating));
        break;
    }
    return l;
  }

  Future<void> _persistRecent(String q) async {
    final t = q.trim();
    if (t.isEmpty) return;
    final prefs = await ref.read(sharedPreferencesProvider.future);
    final existing = prefs.getStringList(PrefsKeys.exploreRecentSearches) ?? [];
    final next = [t, ...existing.where((e) => e != t)].take(8).toList();
    await prefs.setStringList(PrefsKeys.exploreRecentSearches, next);
  }
}
