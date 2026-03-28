// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'wishlist_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$WishlistState {
  List<WishlistItemEntity> get items => throw _privateConstructorUsedError;
  List<WishlistItemEntity> get filteredItems =>
      throw _privateConstructorUsedError;
  Set<String> get wishlistedListingIds => throw _privateConstructorUsedError;
  WishlistFilter get selectedFilter => throw _privateConstructorUsedError;
  WishlistSortOption get sortOption => throw _privateConstructorUsedError;
  WishlistViewMode get viewMode => throw _privateConstructorUsedError;
  Set<String> get selectedItemIds => throw _privateConstructorUsedError;
  bool get isSelectionMode => throw _privateConstructorUsedError;
  bool get isPriceDropBannerVisible => throw _privateConstructorUsedError;
  bool get isLoading => throw _privateConstructorUsedError;
  bool get isUpdating => throw _privateConstructorUsedError;
  String? get error => throw _privateConstructorUsedError;
  WishlistItemEntity? get lastRemoved => throw _privateConstructorUsedError;

  @JsonKey(ignore: true)
  $WishlistStateCopyWith<WishlistState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $WishlistStateCopyWith<$Res> {
  factory $WishlistStateCopyWith(
          WishlistState value, $Res Function(WishlistState) then) =
      _$WishlistStateCopyWithImpl<$Res, WishlistState>;
  @useResult
  $Res call(
      {List<WishlistItemEntity> items,
      List<WishlistItemEntity> filteredItems,
      Set<String> wishlistedListingIds,
      WishlistFilter selectedFilter,
      WishlistSortOption sortOption,
      WishlistViewMode viewMode,
      Set<String> selectedItemIds,
      bool isSelectionMode,
      bool isPriceDropBannerVisible,
      bool isLoading,
      bool isUpdating,
      String? error,
      WishlistItemEntity? lastRemoved});

  $WishlistItemEntityCopyWith<$Res>? get lastRemoved;
}

/// @nodoc
class _$WishlistStateCopyWithImpl<$Res, $Val extends WishlistState>
    implements $WishlistStateCopyWith<$Res> {
  _$WishlistStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? items = null,
    Object? filteredItems = null,
    Object? wishlistedListingIds = null,
    Object? selectedFilter = null,
    Object? sortOption = null,
    Object? viewMode = null,
    Object? selectedItemIds = null,
    Object? isSelectionMode = null,
    Object? isPriceDropBannerVisible = null,
    Object? isLoading = null,
    Object? isUpdating = null,
    Object? error = freezed,
    Object? lastRemoved = freezed,
  }) {
    return _then(_value.copyWith(
      items: null == items
          ? _value.items
          : items // ignore: cast_nullable_to_non_nullable
              as List<WishlistItemEntity>,
      filteredItems: null == filteredItems
          ? _value.filteredItems
          : filteredItems // ignore: cast_nullable_to_non_nullable
              as List<WishlistItemEntity>,
      wishlistedListingIds: null == wishlistedListingIds
          ? _value.wishlistedListingIds
          : wishlistedListingIds // ignore: cast_nullable_to_non_nullable
              as Set<String>,
      selectedFilter: null == selectedFilter
          ? _value.selectedFilter
          : selectedFilter // ignore: cast_nullable_to_non_nullable
              as WishlistFilter,
      sortOption: null == sortOption
          ? _value.sortOption
          : sortOption // ignore: cast_nullable_to_non_nullable
              as WishlistSortOption,
      viewMode: null == viewMode
          ? _value.viewMode
          : viewMode // ignore: cast_nullable_to_non_nullable
              as WishlistViewMode,
      selectedItemIds: null == selectedItemIds
          ? _value.selectedItemIds
          : selectedItemIds // ignore: cast_nullable_to_non_nullable
              as Set<String>,
      isSelectionMode: null == isSelectionMode
          ? _value.isSelectionMode
          : isSelectionMode // ignore: cast_nullable_to_non_nullable
              as bool,
      isPriceDropBannerVisible: null == isPriceDropBannerVisible
          ? _value.isPriceDropBannerVisible
          : isPriceDropBannerVisible // ignore: cast_nullable_to_non_nullable
              as bool,
      isLoading: null == isLoading
          ? _value.isLoading
          : isLoading // ignore: cast_nullable_to_non_nullable
              as bool,
      isUpdating: null == isUpdating
          ? _value.isUpdating
          : isUpdating // ignore: cast_nullable_to_non_nullable
              as bool,
      error: freezed == error
          ? _value.error
          : error // ignore: cast_nullable_to_non_nullable
              as String?,
      lastRemoved: freezed == lastRemoved
          ? _value.lastRemoved
          : lastRemoved // ignore: cast_nullable_to_non_nullable
              as WishlistItemEntity?,
    ) as $Val);
  }

  @override
  @pragma('vm:prefer-inline')
  $WishlistItemEntityCopyWith<$Res>? get lastRemoved {
    if (_value.lastRemoved == null) {
      return null;
    }

    return $WishlistItemEntityCopyWith<$Res>(_value.lastRemoved!, (value) {
      return _then(_value.copyWith(lastRemoved: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$WishlistStateImplCopyWith<$Res>
    implements $WishlistStateCopyWith<$Res> {
  factory _$$WishlistStateImplCopyWith(
          _$WishlistStateImpl value, $Res Function(_$WishlistStateImpl) then) =
      __$$WishlistStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {List<WishlistItemEntity> items,
      List<WishlistItemEntity> filteredItems,
      Set<String> wishlistedListingIds,
      WishlistFilter selectedFilter,
      WishlistSortOption sortOption,
      WishlistViewMode viewMode,
      Set<String> selectedItemIds,
      bool isSelectionMode,
      bool isPriceDropBannerVisible,
      bool isLoading,
      bool isUpdating,
      String? error,
      WishlistItemEntity? lastRemoved});

  @override
  $WishlistItemEntityCopyWith<$Res>? get lastRemoved;
}

/// @nodoc
class __$$WishlistStateImplCopyWithImpl<$Res>
    extends _$WishlistStateCopyWithImpl<$Res, _$WishlistStateImpl>
    implements _$$WishlistStateImplCopyWith<$Res> {
  __$$WishlistStateImplCopyWithImpl(
      _$WishlistStateImpl _value, $Res Function(_$WishlistStateImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? items = null,
    Object? filteredItems = null,
    Object? wishlistedListingIds = null,
    Object? selectedFilter = null,
    Object? sortOption = null,
    Object? viewMode = null,
    Object? selectedItemIds = null,
    Object? isSelectionMode = null,
    Object? isPriceDropBannerVisible = null,
    Object? isLoading = null,
    Object? isUpdating = null,
    Object? error = freezed,
    Object? lastRemoved = freezed,
  }) {
    return _then(_$WishlistStateImpl(
      items: null == items
          ? _value._items
          : items // ignore: cast_nullable_to_non_nullable
              as List<WishlistItemEntity>,
      filteredItems: null == filteredItems
          ? _value._filteredItems
          : filteredItems // ignore: cast_nullable_to_non_nullable
              as List<WishlistItemEntity>,
      wishlistedListingIds: null == wishlistedListingIds
          ? _value._wishlistedListingIds
          : wishlistedListingIds // ignore: cast_nullable_to_non_nullable
              as Set<String>,
      selectedFilter: null == selectedFilter
          ? _value.selectedFilter
          : selectedFilter // ignore: cast_nullable_to_non_nullable
              as WishlistFilter,
      sortOption: null == sortOption
          ? _value.sortOption
          : sortOption // ignore: cast_nullable_to_non_nullable
              as WishlistSortOption,
      viewMode: null == viewMode
          ? _value.viewMode
          : viewMode // ignore: cast_nullable_to_non_nullable
              as WishlistViewMode,
      selectedItemIds: null == selectedItemIds
          ? _value._selectedItemIds
          : selectedItemIds // ignore: cast_nullable_to_non_nullable
              as Set<String>,
      isSelectionMode: null == isSelectionMode
          ? _value.isSelectionMode
          : isSelectionMode // ignore: cast_nullable_to_non_nullable
              as bool,
      isPriceDropBannerVisible: null == isPriceDropBannerVisible
          ? _value.isPriceDropBannerVisible
          : isPriceDropBannerVisible // ignore: cast_nullable_to_non_nullable
              as bool,
      isLoading: null == isLoading
          ? _value.isLoading
          : isLoading // ignore: cast_nullable_to_non_nullable
              as bool,
      isUpdating: null == isUpdating
          ? _value.isUpdating
          : isUpdating // ignore: cast_nullable_to_non_nullable
              as bool,
      error: freezed == error
          ? _value.error
          : error // ignore: cast_nullable_to_non_nullable
              as String?,
      lastRemoved: freezed == lastRemoved
          ? _value.lastRemoved
          : lastRemoved // ignore: cast_nullable_to_non_nullable
              as WishlistItemEntity?,
    ));
  }
}

/// @nodoc

class _$WishlistStateImpl implements _WishlistState {
  const _$WishlistStateImpl(
      {final List<WishlistItemEntity> items = const [],
      final List<WishlistItemEntity> filteredItems = const [],
      final Set<String> wishlistedListingIds = const <String>{},
      this.selectedFilter = WishlistFilter.all,
      this.sortOption = WishlistSortOption.recentlyAdded,
      this.viewMode = WishlistViewMode.list,
      final Set<String> selectedItemIds = const <String>{},
      this.isSelectionMode = false,
      this.isPriceDropBannerVisible = true,
      this.isLoading = false,
      this.isUpdating = false,
      this.error,
      this.lastRemoved})
      : _items = items,
        _filteredItems = filteredItems,
        _wishlistedListingIds = wishlistedListingIds,
        _selectedItemIds = selectedItemIds;

  final List<WishlistItemEntity> _items;
  @override
  @JsonKey()
  List<WishlistItemEntity> get items {
    if (_items is EqualUnmodifiableListView) return _items;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_items);
  }

  final List<WishlistItemEntity> _filteredItems;
  @override
  @JsonKey()
  List<WishlistItemEntity> get filteredItems {
    if (_filteredItems is EqualUnmodifiableListView) return _filteredItems;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_filteredItems);
  }

  final Set<String> _wishlistedListingIds;
  @override
  @JsonKey()
  Set<String> get wishlistedListingIds {
    if (_wishlistedListingIds is EqualUnmodifiableSetView)
      return _wishlistedListingIds;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableSetView(_wishlistedListingIds);
  }

  @override
  @JsonKey()
  final WishlistFilter selectedFilter;
  @override
  @JsonKey()
  final WishlistSortOption sortOption;
  @override
  @JsonKey()
  final WishlistViewMode viewMode;
  final Set<String> _selectedItemIds;
  @override
  @JsonKey()
  Set<String> get selectedItemIds {
    if (_selectedItemIds is EqualUnmodifiableSetView) return _selectedItemIds;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableSetView(_selectedItemIds);
  }

  @override
  @JsonKey()
  final bool isSelectionMode;
  @override
  @JsonKey()
  final bool isPriceDropBannerVisible;
  @override
  @JsonKey()
  final bool isLoading;
  @override
  @JsonKey()
  final bool isUpdating;
  @override
  final String? error;
  @override
  final WishlistItemEntity? lastRemoved;

  @override
  String toString() {
    return 'WishlistState(items: $items, filteredItems: $filteredItems, wishlistedListingIds: $wishlistedListingIds, selectedFilter: $selectedFilter, sortOption: $sortOption, viewMode: $viewMode, selectedItemIds: $selectedItemIds, isSelectionMode: $isSelectionMode, isPriceDropBannerVisible: $isPriceDropBannerVisible, isLoading: $isLoading, isUpdating: $isUpdating, error: $error, lastRemoved: $lastRemoved)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$WishlistStateImpl &&
            const DeepCollectionEquality().equals(other._items, _items) &&
            const DeepCollectionEquality()
                .equals(other._filteredItems, _filteredItems) &&
            const DeepCollectionEquality()
                .equals(other._wishlistedListingIds, _wishlistedListingIds) &&
            (identical(other.selectedFilter, selectedFilter) ||
                other.selectedFilter == selectedFilter) &&
            (identical(other.sortOption, sortOption) ||
                other.sortOption == sortOption) &&
            (identical(other.viewMode, viewMode) ||
                other.viewMode == viewMode) &&
            const DeepCollectionEquality()
                .equals(other._selectedItemIds, _selectedItemIds) &&
            (identical(other.isSelectionMode, isSelectionMode) ||
                other.isSelectionMode == isSelectionMode) &&
            (identical(
                    other.isPriceDropBannerVisible, isPriceDropBannerVisible) ||
                other.isPriceDropBannerVisible == isPriceDropBannerVisible) &&
            (identical(other.isLoading, isLoading) ||
                other.isLoading == isLoading) &&
            (identical(other.isUpdating, isUpdating) ||
                other.isUpdating == isUpdating) &&
            (identical(other.error, error) || other.error == error) &&
            (identical(other.lastRemoved, lastRemoved) ||
                other.lastRemoved == lastRemoved));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      const DeepCollectionEquality().hash(_items),
      const DeepCollectionEquality().hash(_filteredItems),
      const DeepCollectionEquality().hash(_wishlistedListingIds),
      selectedFilter,
      sortOption,
      viewMode,
      const DeepCollectionEquality().hash(_selectedItemIds),
      isSelectionMode,
      isPriceDropBannerVisible,
      isLoading,
      isUpdating,
      error,
      lastRemoved);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$WishlistStateImplCopyWith<_$WishlistStateImpl> get copyWith =>
      __$$WishlistStateImplCopyWithImpl<_$WishlistStateImpl>(this, _$identity);
}

abstract class _WishlistState implements WishlistState {
  const factory _WishlistState(
      {final List<WishlistItemEntity> items,
      final List<WishlistItemEntity> filteredItems,
      final Set<String> wishlistedListingIds,
      final WishlistFilter selectedFilter,
      final WishlistSortOption sortOption,
      final WishlistViewMode viewMode,
      final Set<String> selectedItemIds,
      final bool isSelectionMode,
      final bool isPriceDropBannerVisible,
      final bool isLoading,
      final bool isUpdating,
      final String? error,
      final WishlistItemEntity? lastRemoved}) = _$WishlistStateImpl;

  @override
  List<WishlistItemEntity> get items;
  @override
  List<WishlistItemEntity> get filteredItems;
  @override
  Set<String> get wishlistedListingIds;
  @override
  WishlistFilter get selectedFilter;
  @override
  WishlistSortOption get sortOption;
  @override
  WishlistViewMode get viewMode;
  @override
  Set<String> get selectedItemIds;
  @override
  bool get isSelectionMode;
  @override
  bool get isPriceDropBannerVisible;
  @override
  bool get isLoading;
  @override
  bool get isUpdating;
  @override
  String? get error;
  @override
  WishlistItemEntity? get lastRemoved;
  @override
  @JsonKey(ignore: true)
  _$$WishlistStateImplCopyWith<_$WishlistStateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
