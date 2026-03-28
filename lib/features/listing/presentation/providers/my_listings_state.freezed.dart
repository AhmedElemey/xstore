// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'my_listings_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$MyListingsState {
  List<ListingEntity> get listings => throw _privateConstructorUsedError;
  List<ListingEntity> get filteredListings =>
      throw _privateConstructorUsedError;

  /// `null` means “All”.
  ListingStatus? get selectedFilter => throw _privateConstructorUsedError;
  SortOption get selectedSort => throw _privateConstructorUsedError;
  ViewMode get viewMode => throw _privateConstructorUsedError;
  bool get isLoading => throw _privateConstructorUsedError;
  String? get error => throw _privateConstructorUsedError;
  String get searchQuery => throw _privateConstructorUsedError;

  @JsonKey(ignore: true)
  $MyListingsStateCopyWith<MyListingsState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $MyListingsStateCopyWith<$Res> {
  factory $MyListingsStateCopyWith(
          MyListingsState value, $Res Function(MyListingsState) then) =
      _$MyListingsStateCopyWithImpl<$Res, MyListingsState>;
  @useResult
  $Res call(
      {List<ListingEntity> listings,
      List<ListingEntity> filteredListings,
      ListingStatus? selectedFilter,
      SortOption selectedSort,
      ViewMode viewMode,
      bool isLoading,
      String? error,
      String searchQuery});
}

/// @nodoc
class _$MyListingsStateCopyWithImpl<$Res, $Val extends MyListingsState>
    implements $MyListingsStateCopyWith<$Res> {
  _$MyListingsStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? listings = null,
    Object? filteredListings = null,
    Object? selectedFilter = freezed,
    Object? selectedSort = null,
    Object? viewMode = null,
    Object? isLoading = null,
    Object? error = freezed,
    Object? searchQuery = null,
  }) {
    return _then(_value.copyWith(
      listings: null == listings
          ? _value.listings
          : listings // ignore: cast_nullable_to_non_nullable
              as List<ListingEntity>,
      filteredListings: null == filteredListings
          ? _value.filteredListings
          : filteredListings // ignore: cast_nullable_to_non_nullable
              as List<ListingEntity>,
      selectedFilter: freezed == selectedFilter
          ? _value.selectedFilter
          : selectedFilter // ignore: cast_nullable_to_non_nullable
              as ListingStatus?,
      selectedSort: null == selectedSort
          ? _value.selectedSort
          : selectedSort // ignore: cast_nullable_to_non_nullable
              as SortOption,
      viewMode: null == viewMode
          ? _value.viewMode
          : viewMode // ignore: cast_nullable_to_non_nullable
              as ViewMode,
      isLoading: null == isLoading
          ? _value.isLoading
          : isLoading // ignore: cast_nullable_to_non_nullable
              as bool,
      error: freezed == error
          ? _value.error
          : error // ignore: cast_nullable_to_non_nullable
              as String?,
      searchQuery: null == searchQuery
          ? _value.searchQuery
          : searchQuery // ignore: cast_nullable_to_non_nullable
              as String,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$MyListingsStateImplCopyWith<$Res>
    implements $MyListingsStateCopyWith<$Res> {
  factory _$$MyListingsStateImplCopyWith(_$MyListingsStateImpl value,
          $Res Function(_$MyListingsStateImpl) then) =
      __$$MyListingsStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {List<ListingEntity> listings,
      List<ListingEntity> filteredListings,
      ListingStatus? selectedFilter,
      SortOption selectedSort,
      ViewMode viewMode,
      bool isLoading,
      String? error,
      String searchQuery});
}

/// @nodoc
class __$$MyListingsStateImplCopyWithImpl<$Res>
    extends _$MyListingsStateCopyWithImpl<$Res, _$MyListingsStateImpl>
    implements _$$MyListingsStateImplCopyWith<$Res> {
  __$$MyListingsStateImplCopyWithImpl(
      _$MyListingsStateImpl _value, $Res Function(_$MyListingsStateImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? listings = null,
    Object? filteredListings = null,
    Object? selectedFilter = freezed,
    Object? selectedSort = null,
    Object? viewMode = null,
    Object? isLoading = null,
    Object? error = freezed,
    Object? searchQuery = null,
  }) {
    return _then(_$MyListingsStateImpl(
      listings: null == listings
          ? _value._listings
          : listings // ignore: cast_nullable_to_non_nullable
              as List<ListingEntity>,
      filteredListings: null == filteredListings
          ? _value._filteredListings
          : filteredListings // ignore: cast_nullable_to_non_nullable
              as List<ListingEntity>,
      selectedFilter: freezed == selectedFilter
          ? _value.selectedFilter
          : selectedFilter // ignore: cast_nullable_to_non_nullable
              as ListingStatus?,
      selectedSort: null == selectedSort
          ? _value.selectedSort
          : selectedSort // ignore: cast_nullable_to_non_nullable
              as SortOption,
      viewMode: null == viewMode
          ? _value.viewMode
          : viewMode // ignore: cast_nullable_to_non_nullable
              as ViewMode,
      isLoading: null == isLoading
          ? _value.isLoading
          : isLoading // ignore: cast_nullable_to_non_nullable
              as bool,
      error: freezed == error
          ? _value.error
          : error // ignore: cast_nullable_to_non_nullable
              as String?,
      searchQuery: null == searchQuery
          ? _value.searchQuery
          : searchQuery // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc

class _$MyListingsStateImpl implements _MyListingsState {
  const _$MyListingsStateImpl(
      {final List<ListingEntity> listings = const [],
      final List<ListingEntity> filteredListings = const [],
      this.selectedFilter,
      this.selectedSort = SortOption.newest,
      this.viewMode = ViewMode.list,
      this.isLoading = false,
      this.error,
      this.searchQuery = ''})
      : _listings = listings,
        _filteredListings = filteredListings;

  final List<ListingEntity> _listings;
  @override
  @JsonKey()
  List<ListingEntity> get listings {
    if (_listings is EqualUnmodifiableListView) return _listings;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_listings);
  }

  final List<ListingEntity> _filteredListings;
  @override
  @JsonKey()
  List<ListingEntity> get filteredListings {
    if (_filteredListings is EqualUnmodifiableListView)
      return _filteredListings;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_filteredListings);
  }

  /// `null` means “All”.
  @override
  final ListingStatus? selectedFilter;
  @override
  @JsonKey()
  final SortOption selectedSort;
  @override
  @JsonKey()
  final ViewMode viewMode;
  @override
  @JsonKey()
  final bool isLoading;
  @override
  final String? error;
  @override
  @JsonKey()
  final String searchQuery;

  @override
  String toString() {
    return 'MyListingsState(listings: $listings, filteredListings: $filteredListings, selectedFilter: $selectedFilter, selectedSort: $selectedSort, viewMode: $viewMode, isLoading: $isLoading, error: $error, searchQuery: $searchQuery)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$MyListingsStateImpl &&
            const DeepCollectionEquality().equals(other._listings, _listings) &&
            const DeepCollectionEquality()
                .equals(other._filteredListings, _filteredListings) &&
            (identical(other.selectedFilter, selectedFilter) ||
                other.selectedFilter == selectedFilter) &&
            (identical(other.selectedSort, selectedSort) ||
                other.selectedSort == selectedSort) &&
            (identical(other.viewMode, viewMode) ||
                other.viewMode == viewMode) &&
            (identical(other.isLoading, isLoading) ||
                other.isLoading == isLoading) &&
            (identical(other.error, error) || other.error == error) &&
            (identical(other.searchQuery, searchQuery) ||
                other.searchQuery == searchQuery));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      const DeepCollectionEquality().hash(_listings),
      const DeepCollectionEquality().hash(_filteredListings),
      selectedFilter,
      selectedSort,
      viewMode,
      isLoading,
      error,
      searchQuery);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$MyListingsStateImplCopyWith<_$MyListingsStateImpl> get copyWith =>
      __$$MyListingsStateImplCopyWithImpl<_$MyListingsStateImpl>(
          this, _$identity);
}

abstract class _MyListingsState implements MyListingsState {
  const factory _MyListingsState(
      {final List<ListingEntity> listings,
      final List<ListingEntity> filteredListings,
      final ListingStatus? selectedFilter,
      final SortOption selectedSort,
      final ViewMode viewMode,
      final bool isLoading,
      final String? error,
      final String searchQuery}) = _$MyListingsStateImpl;

  @override
  List<ListingEntity> get listings;
  @override
  List<ListingEntity> get filteredListings;
  @override

  /// `null` means “All”.
  ListingStatus? get selectedFilter;
  @override
  SortOption get selectedSort;
  @override
  ViewMode get viewMode;
  @override
  bool get isLoading;
  @override
  String? get error;
  @override
  String get searchQuery;
  @override
  @JsonKey(ignore: true)
  _$$MyListingsStateImplCopyWith<_$MyListingsStateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
