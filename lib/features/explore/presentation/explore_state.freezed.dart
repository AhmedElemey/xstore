// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'explore_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$FilterState {
  List<String> get categories => throw _privateConstructorUsedError;
  List<String> get conditions => throw _privateConstructorUsedError;
  double? get minPrice => throw _privateConstructorUsedError;
  double? get maxPrice => throw _privateConstructorUsedError;
  double? get minRating => throw _privateConstructorUsedError;
  String? get location => throw _privateConstructorUsedError;
  bool get shippingOnly => throw _privateConstructorUsedError;

  @JsonKey(ignore: true)
  $FilterStateCopyWith<FilterState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $FilterStateCopyWith<$Res> {
  factory $FilterStateCopyWith(
          FilterState value, $Res Function(FilterState) then) =
      _$FilterStateCopyWithImpl<$Res, FilterState>;
  @useResult
  $Res call(
      {List<String> categories,
      List<String> conditions,
      double? minPrice,
      double? maxPrice,
      double? minRating,
      String? location,
      bool shippingOnly});
}

/// @nodoc
class _$FilterStateCopyWithImpl<$Res, $Val extends FilterState>
    implements $FilterStateCopyWith<$Res> {
  _$FilterStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? categories = null,
    Object? conditions = null,
    Object? minPrice = freezed,
    Object? maxPrice = freezed,
    Object? minRating = freezed,
    Object? location = freezed,
    Object? shippingOnly = null,
  }) {
    return _then(_value.copyWith(
      categories: null == categories
          ? _value.categories
          : categories // ignore: cast_nullable_to_non_nullable
              as List<String>,
      conditions: null == conditions
          ? _value.conditions
          : conditions // ignore: cast_nullable_to_non_nullable
              as List<String>,
      minPrice: freezed == minPrice
          ? _value.minPrice
          : minPrice // ignore: cast_nullable_to_non_nullable
              as double?,
      maxPrice: freezed == maxPrice
          ? _value.maxPrice
          : maxPrice // ignore: cast_nullable_to_non_nullable
              as double?,
      minRating: freezed == minRating
          ? _value.minRating
          : minRating // ignore: cast_nullable_to_non_nullable
              as double?,
      location: freezed == location
          ? _value.location
          : location // ignore: cast_nullable_to_non_nullable
              as String?,
      shippingOnly: null == shippingOnly
          ? _value.shippingOnly
          : shippingOnly // ignore: cast_nullable_to_non_nullable
              as bool,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$FilterStateImplCopyWith<$Res>
    implements $FilterStateCopyWith<$Res> {
  factory _$$FilterStateImplCopyWith(
          _$FilterStateImpl value, $Res Function(_$FilterStateImpl) then) =
      __$$FilterStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {List<String> categories,
      List<String> conditions,
      double? minPrice,
      double? maxPrice,
      double? minRating,
      String? location,
      bool shippingOnly});
}

/// @nodoc
class __$$FilterStateImplCopyWithImpl<$Res>
    extends _$FilterStateCopyWithImpl<$Res, _$FilterStateImpl>
    implements _$$FilterStateImplCopyWith<$Res> {
  __$$FilterStateImplCopyWithImpl(
      _$FilterStateImpl _value, $Res Function(_$FilterStateImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? categories = null,
    Object? conditions = null,
    Object? minPrice = freezed,
    Object? maxPrice = freezed,
    Object? minRating = freezed,
    Object? location = freezed,
    Object? shippingOnly = null,
  }) {
    return _then(_$FilterStateImpl(
      categories: null == categories
          ? _value._categories
          : categories // ignore: cast_nullable_to_non_nullable
              as List<String>,
      conditions: null == conditions
          ? _value._conditions
          : conditions // ignore: cast_nullable_to_non_nullable
              as List<String>,
      minPrice: freezed == minPrice
          ? _value.minPrice
          : minPrice // ignore: cast_nullable_to_non_nullable
              as double?,
      maxPrice: freezed == maxPrice
          ? _value.maxPrice
          : maxPrice // ignore: cast_nullable_to_non_nullable
              as double?,
      minRating: freezed == minRating
          ? _value.minRating
          : minRating // ignore: cast_nullable_to_non_nullable
              as double?,
      location: freezed == location
          ? _value.location
          : location // ignore: cast_nullable_to_non_nullable
              as String?,
      shippingOnly: null == shippingOnly
          ? _value.shippingOnly
          : shippingOnly // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

/// @nodoc

class _$FilterStateImpl implements _FilterState {
  const _$FilterStateImpl(
      {final List<String> categories = const <String>[],
      final List<String> conditions = const <String>[],
      this.minPrice,
      this.maxPrice,
      this.minRating,
      this.location,
      this.shippingOnly = false})
      : _categories = categories,
        _conditions = conditions;

  final List<String> _categories;
  @override
  @JsonKey()
  List<String> get categories {
    if (_categories is EqualUnmodifiableListView) return _categories;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_categories);
  }

  final List<String> _conditions;
  @override
  @JsonKey()
  List<String> get conditions {
    if (_conditions is EqualUnmodifiableListView) return _conditions;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_conditions);
  }

  @override
  final double? minPrice;
  @override
  final double? maxPrice;
  @override
  final double? minRating;
  @override
  final String? location;
  @override
  @JsonKey()
  final bool shippingOnly;

  @override
  String toString() {
    return 'FilterState(categories: $categories, conditions: $conditions, minPrice: $minPrice, maxPrice: $maxPrice, minRating: $minRating, location: $location, shippingOnly: $shippingOnly)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$FilterStateImpl &&
            const DeepCollectionEquality()
                .equals(other._categories, _categories) &&
            const DeepCollectionEquality()
                .equals(other._conditions, _conditions) &&
            (identical(other.minPrice, minPrice) ||
                other.minPrice == minPrice) &&
            (identical(other.maxPrice, maxPrice) ||
                other.maxPrice == maxPrice) &&
            (identical(other.minRating, minRating) ||
                other.minRating == minRating) &&
            (identical(other.location, location) ||
                other.location == location) &&
            (identical(other.shippingOnly, shippingOnly) ||
                other.shippingOnly == shippingOnly));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      const DeepCollectionEquality().hash(_categories),
      const DeepCollectionEquality().hash(_conditions),
      minPrice,
      maxPrice,
      minRating,
      location,
      shippingOnly);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$FilterStateImplCopyWith<_$FilterStateImpl> get copyWith =>
      __$$FilterStateImplCopyWithImpl<_$FilterStateImpl>(this, _$identity);
}

abstract class _FilterState implements FilterState {
  const factory _FilterState(
      {final List<String> categories,
      final List<String> conditions,
      final double? minPrice,
      final double? maxPrice,
      final double? minRating,
      final String? location,
      final bool shippingOnly}) = _$FilterStateImpl;

  @override
  List<String> get categories;
  @override
  List<String> get conditions;
  @override
  double? get minPrice;
  @override
  double? get maxPrice;
  @override
  double? get minRating;
  @override
  String? get location;
  @override
  bool get shippingOnly;
  @override
  @JsonKey(ignore: true)
  _$$FilterStateImplCopyWith<_$FilterStateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
mixin _$ExploreState {
  String get query => throw _privateConstructorUsedError;
  List<SearchResultEntity> get results => throw _privateConstructorUsedError;
  List<String> get suggestions => throw _privateConstructorUsedError;
  FilterState get filters => throw _privateConstructorUsedError;
  ExploreSortOption get sortOption => throw _privateConstructorUsedError;
  ExploreViewMode get viewMode => throw _privateConstructorUsedError;
  bool get isLoadingMore => throw _privateConstructorUsedError;
  bool get hasMore => throw _privateConstructorUsedError;
  int get page => throw _privateConstructorUsedError;
  bool get isSearching => throw _privateConstructorUsedError;
  Set<String> get favoriteIds => throw _privateConstructorUsedError;

  @JsonKey(ignore: true)
  $ExploreStateCopyWith<ExploreState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ExploreStateCopyWith<$Res> {
  factory $ExploreStateCopyWith(
          ExploreState value, $Res Function(ExploreState) then) =
      _$ExploreStateCopyWithImpl<$Res, ExploreState>;
  @useResult
  $Res call(
      {String query,
      List<SearchResultEntity> results,
      List<String> suggestions,
      FilterState filters,
      ExploreSortOption sortOption,
      ExploreViewMode viewMode,
      bool isLoadingMore,
      bool hasMore,
      int page,
      bool isSearching,
      Set<String> favoriteIds});

  $FilterStateCopyWith<$Res> get filters;
}

/// @nodoc
class _$ExploreStateCopyWithImpl<$Res, $Val extends ExploreState>
    implements $ExploreStateCopyWith<$Res> {
  _$ExploreStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? query = null,
    Object? results = null,
    Object? suggestions = null,
    Object? filters = null,
    Object? sortOption = null,
    Object? viewMode = null,
    Object? isLoadingMore = null,
    Object? hasMore = null,
    Object? page = null,
    Object? isSearching = null,
    Object? favoriteIds = null,
  }) {
    return _then(_value.copyWith(
      query: null == query
          ? _value.query
          : query // ignore: cast_nullable_to_non_nullable
              as String,
      results: null == results
          ? _value.results
          : results // ignore: cast_nullable_to_non_nullable
              as List<SearchResultEntity>,
      suggestions: null == suggestions
          ? _value.suggestions
          : suggestions // ignore: cast_nullable_to_non_nullable
              as List<String>,
      filters: null == filters
          ? _value.filters
          : filters // ignore: cast_nullable_to_non_nullable
              as FilterState,
      sortOption: null == sortOption
          ? _value.sortOption
          : sortOption // ignore: cast_nullable_to_non_nullable
              as ExploreSortOption,
      viewMode: null == viewMode
          ? _value.viewMode
          : viewMode // ignore: cast_nullable_to_non_nullable
              as ExploreViewMode,
      isLoadingMore: null == isLoadingMore
          ? _value.isLoadingMore
          : isLoadingMore // ignore: cast_nullable_to_non_nullable
              as bool,
      hasMore: null == hasMore
          ? _value.hasMore
          : hasMore // ignore: cast_nullable_to_non_nullable
              as bool,
      page: null == page
          ? _value.page
          : page // ignore: cast_nullable_to_non_nullable
              as int,
      isSearching: null == isSearching
          ? _value.isSearching
          : isSearching // ignore: cast_nullable_to_non_nullable
              as bool,
      favoriteIds: null == favoriteIds
          ? _value.favoriteIds
          : favoriteIds // ignore: cast_nullable_to_non_nullable
              as Set<String>,
    ) as $Val);
  }

  @override
  @pragma('vm:prefer-inline')
  $FilterStateCopyWith<$Res> get filters {
    return $FilterStateCopyWith<$Res>(_value.filters, (value) {
      return _then(_value.copyWith(filters: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$ExploreStateImplCopyWith<$Res>
    implements $ExploreStateCopyWith<$Res> {
  factory _$$ExploreStateImplCopyWith(
          _$ExploreStateImpl value, $Res Function(_$ExploreStateImpl) then) =
      __$$ExploreStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String query,
      List<SearchResultEntity> results,
      List<String> suggestions,
      FilterState filters,
      ExploreSortOption sortOption,
      ExploreViewMode viewMode,
      bool isLoadingMore,
      bool hasMore,
      int page,
      bool isSearching,
      Set<String> favoriteIds});

  @override
  $FilterStateCopyWith<$Res> get filters;
}

/// @nodoc
class __$$ExploreStateImplCopyWithImpl<$Res>
    extends _$ExploreStateCopyWithImpl<$Res, _$ExploreStateImpl>
    implements _$$ExploreStateImplCopyWith<$Res> {
  __$$ExploreStateImplCopyWithImpl(
      _$ExploreStateImpl _value, $Res Function(_$ExploreStateImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? query = null,
    Object? results = null,
    Object? suggestions = null,
    Object? filters = null,
    Object? sortOption = null,
    Object? viewMode = null,
    Object? isLoadingMore = null,
    Object? hasMore = null,
    Object? page = null,
    Object? isSearching = null,
    Object? favoriteIds = null,
  }) {
    return _then(_$ExploreStateImpl(
      query: null == query
          ? _value.query
          : query // ignore: cast_nullable_to_non_nullable
              as String,
      results: null == results
          ? _value._results
          : results // ignore: cast_nullable_to_non_nullable
              as List<SearchResultEntity>,
      suggestions: null == suggestions
          ? _value._suggestions
          : suggestions // ignore: cast_nullable_to_non_nullable
              as List<String>,
      filters: null == filters
          ? _value.filters
          : filters // ignore: cast_nullable_to_non_nullable
              as FilterState,
      sortOption: null == sortOption
          ? _value.sortOption
          : sortOption // ignore: cast_nullable_to_non_nullable
              as ExploreSortOption,
      viewMode: null == viewMode
          ? _value.viewMode
          : viewMode // ignore: cast_nullable_to_non_nullable
              as ExploreViewMode,
      isLoadingMore: null == isLoadingMore
          ? _value.isLoadingMore
          : isLoadingMore // ignore: cast_nullable_to_non_nullable
              as bool,
      hasMore: null == hasMore
          ? _value.hasMore
          : hasMore // ignore: cast_nullable_to_non_nullable
              as bool,
      page: null == page
          ? _value.page
          : page // ignore: cast_nullable_to_non_nullable
              as int,
      isSearching: null == isSearching
          ? _value.isSearching
          : isSearching // ignore: cast_nullable_to_non_nullable
              as bool,
      favoriteIds: null == favoriteIds
          ? _value._favoriteIds
          : favoriteIds // ignore: cast_nullable_to_non_nullable
              as Set<String>,
    ));
  }
}

/// @nodoc

class _$ExploreStateImpl implements _ExploreState {
  const _$ExploreStateImpl(
      {this.query = '',
      final List<SearchResultEntity> results = const <SearchResultEntity>[],
      final List<String> suggestions = const <String>[],
      this.filters = const FilterState(),
      this.sortOption = ExploreSortOption.relevance,
      this.viewMode = ExploreViewMode.grid,
      this.isLoadingMore = false,
      this.hasMore = true,
      this.page = 1,
      this.isSearching = false,
      final Set<String> favoriteIds = const <String>{}})
      : _results = results,
        _suggestions = suggestions,
        _favoriteIds = favoriteIds;

  @override
  @JsonKey()
  final String query;
  final List<SearchResultEntity> _results;
  @override
  @JsonKey()
  List<SearchResultEntity> get results {
    if (_results is EqualUnmodifiableListView) return _results;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_results);
  }

  final List<String> _suggestions;
  @override
  @JsonKey()
  List<String> get suggestions {
    if (_suggestions is EqualUnmodifiableListView) return _suggestions;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_suggestions);
  }

  @override
  @JsonKey()
  final FilterState filters;
  @override
  @JsonKey()
  final ExploreSortOption sortOption;
  @override
  @JsonKey()
  final ExploreViewMode viewMode;
  @override
  @JsonKey()
  final bool isLoadingMore;
  @override
  @JsonKey()
  final bool hasMore;
  @override
  @JsonKey()
  final int page;
  @override
  @JsonKey()
  final bool isSearching;
  final Set<String> _favoriteIds;
  @override
  @JsonKey()
  Set<String> get favoriteIds {
    if (_favoriteIds is EqualUnmodifiableSetView) return _favoriteIds;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableSetView(_favoriteIds);
  }

  @override
  String toString() {
    return 'ExploreState(query: $query, results: $results, suggestions: $suggestions, filters: $filters, sortOption: $sortOption, viewMode: $viewMode, isLoadingMore: $isLoadingMore, hasMore: $hasMore, page: $page, isSearching: $isSearching, favoriteIds: $favoriteIds)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ExploreStateImpl &&
            (identical(other.query, query) || other.query == query) &&
            const DeepCollectionEquality().equals(other._results, _results) &&
            const DeepCollectionEquality()
                .equals(other._suggestions, _suggestions) &&
            (identical(other.filters, filters) || other.filters == filters) &&
            (identical(other.sortOption, sortOption) ||
                other.sortOption == sortOption) &&
            (identical(other.viewMode, viewMode) ||
                other.viewMode == viewMode) &&
            (identical(other.isLoadingMore, isLoadingMore) ||
                other.isLoadingMore == isLoadingMore) &&
            (identical(other.hasMore, hasMore) || other.hasMore == hasMore) &&
            (identical(other.page, page) || other.page == page) &&
            (identical(other.isSearching, isSearching) ||
                other.isSearching == isSearching) &&
            const DeepCollectionEquality()
                .equals(other._favoriteIds, _favoriteIds));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      query,
      const DeepCollectionEquality().hash(_results),
      const DeepCollectionEquality().hash(_suggestions),
      filters,
      sortOption,
      viewMode,
      isLoadingMore,
      hasMore,
      page,
      isSearching,
      const DeepCollectionEquality().hash(_favoriteIds));

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$ExploreStateImplCopyWith<_$ExploreStateImpl> get copyWith =>
      __$$ExploreStateImplCopyWithImpl<_$ExploreStateImpl>(this, _$identity);
}

abstract class _ExploreState implements ExploreState {
  const factory _ExploreState(
      {final String query,
      final List<SearchResultEntity> results,
      final List<String> suggestions,
      final FilterState filters,
      final ExploreSortOption sortOption,
      final ExploreViewMode viewMode,
      final bool isLoadingMore,
      final bool hasMore,
      final int page,
      final bool isSearching,
      final Set<String> favoriteIds}) = _$ExploreStateImpl;

  @override
  String get query;
  @override
  List<SearchResultEntity> get results;
  @override
  List<String> get suggestions;
  @override
  FilterState get filters;
  @override
  ExploreSortOption get sortOption;
  @override
  ExploreViewMode get viewMode;
  @override
  bool get isLoadingMore;
  @override
  bool get hasMore;
  @override
  int get page;
  @override
  bool get isSearching;
  @override
  Set<String> get favoriteIds;
  @override
  @JsonKey(ignore: true)
  _$$ExploreStateImplCopyWith<_$ExploreStateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
