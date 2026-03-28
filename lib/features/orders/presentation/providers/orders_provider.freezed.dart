// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'orders_provider.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$OrdersState {
  List<OrderEntity> get orders => throw _privateConstructorUsedError;
  List<OrderEntity> get filteredOrders => throw _privateConstructorUsedError;
  OrderStatus? get selectedFilter => throw _privateConstructorUsedError;
  OrderSortOption get sortOption => throw _privateConstructorUsedError;
  String get searchQuery => throw _privateConstructorUsedError;
  bool get isLoading => throw _privateConstructorUsedError;
  bool get isLoadingMore => throw _privateConstructorUsedError;
  bool get hasMore => throw _privateConstructorUsedError;
  int get page => throw _privateConstructorUsedError;
  String? get error => throw _privateConstructorUsedError;
  OrderStatsEntity? get stats => throw _privateConstructorUsedError;
  bool get isSearching => throw _privateConstructorUsedError;

  @JsonKey(ignore: true)
  $OrdersStateCopyWith<OrdersState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $OrdersStateCopyWith<$Res> {
  factory $OrdersStateCopyWith(
          OrdersState value, $Res Function(OrdersState) then) =
      _$OrdersStateCopyWithImpl<$Res, OrdersState>;
  @useResult
  $Res call(
      {List<OrderEntity> orders,
      List<OrderEntity> filteredOrders,
      OrderStatus? selectedFilter,
      OrderSortOption sortOption,
      String searchQuery,
      bool isLoading,
      bool isLoadingMore,
      bool hasMore,
      int page,
      String? error,
      OrderStatsEntity? stats,
      bool isSearching});

  $OrderStatsEntityCopyWith<$Res>? get stats;
}

/// @nodoc
class _$OrdersStateCopyWithImpl<$Res, $Val extends OrdersState>
    implements $OrdersStateCopyWith<$Res> {
  _$OrdersStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? orders = null,
    Object? filteredOrders = null,
    Object? selectedFilter = freezed,
    Object? sortOption = null,
    Object? searchQuery = null,
    Object? isLoading = null,
    Object? isLoadingMore = null,
    Object? hasMore = null,
    Object? page = null,
    Object? error = freezed,
    Object? stats = freezed,
    Object? isSearching = null,
  }) {
    return _then(_value.copyWith(
      orders: null == orders
          ? _value.orders
          : orders // ignore: cast_nullable_to_non_nullable
              as List<OrderEntity>,
      filteredOrders: null == filteredOrders
          ? _value.filteredOrders
          : filteredOrders // ignore: cast_nullable_to_non_nullable
              as List<OrderEntity>,
      selectedFilter: freezed == selectedFilter
          ? _value.selectedFilter
          : selectedFilter // ignore: cast_nullable_to_non_nullable
              as OrderStatus?,
      sortOption: null == sortOption
          ? _value.sortOption
          : sortOption // ignore: cast_nullable_to_non_nullable
              as OrderSortOption,
      searchQuery: null == searchQuery
          ? _value.searchQuery
          : searchQuery // ignore: cast_nullable_to_non_nullable
              as String,
      isLoading: null == isLoading
          ? _value.isLoading
          : isLoading // ignore: cast_nullable_to_non_nullable
              as bool,
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
      error: freezed == error
          ? _value.error
          : error // ignore: cast_nullable_to_non_nullable
              as String?,
      stats: freezed == stats
          ? _value.stats
          : stats // ignore: cast_nullable_to_non_nullable
              as OrderStatsEntity?,
      isSearching: null == isSearching
          ? _value.isSearching
          : isSearching // ignore: cast_nullable_to_non_nullable
              as bool,
    ) as $Val);
  }

  @override
  @pragma('vm:prefer-inline')
  $OrderStatsEntityCopyWith<$Res>? get stats {
    if (_value.stats == null) {
      return null;
    }

    return $OrderStatsEntityCopyWith<$Res>(_value.stats!, (value) {
      return _then(_value.copyWith(stats: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$OrdersStateImplCopyWith<$Res>
    implements $OrdersStateCopyWith<$Res> {
  factory _$$OrdersStateImplCopyWith(
          _$OrdersStateImpl value, $Res Function(_$OrdersStateImpl) then) =
      __$$OrdersStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {List<OrderEntity> orders,
      List<OrderEntity> filteredOrders,
      OrderStatus? selectedFilter,
      OrderSortOption sortOption,
      String searchQuery,
      bool isLoading,
      bool isLoadingMore,
      bool hasMore,
      int page,
      String? error,
      OrderStatsEntity? stats,
      bool isSearching});

  @override
  $OrderStatsEntityCopyWith<$Res>? get stats;
}

/// @nodoc
class __$$OrdersStateImplCopyWithImpl<$Res>
    extends _$OrdersStateCopyWithImpl<$Res, _$OrdersStateImpl>
    implements _$$OrdersStateImplCopyWith<$Res> {
  __$$OrdersStateImplCopyWithImpl(
      _$OrdersStateImpl _value, $Res Function(_$OrdersStateImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? orders = null,
    Object? filteredOrders = null,
    Object? selectedFilter = freezed,
    Object? sortOption = null,
    Object? searchQuery = null,
    Object? isLoading = null,
    Object? isLoadingMore = null,
    Object? hasMore = null,
    Object? page = null,
    Object? error = freezed,
    Object? stats = freezed,
    Object? isSearching = null,
  }) {
    return _then(_$OrdersStateImpl(
      orders: null == orders
          ? _value._orders
          : orders // ignore: cast_nullable_to_non_nullable
              as List<OrderEntity>,
      filteredOrders: null == filteredOrders
          ? _value._filteredOrders
          : filteredOrders // ignore: cast_nullable_to_non_nullable
              as List<OrderEntity>,
      selectedFilter: freezed == selectedFilter
          ? _value.selectedFilter
          : selectedFilter // ignore: cast_nullable_to_non_nullable
              as OrderStatus?,
      sortOption: null == sortOption
          ? _value.sortOption
          : sortOption // ignore: cast_nullable_to_non_nullable
              as OrderSortOption,
      searchQuery: null == searchQuery
          ? _value.searchQuery
          : searchQuery // ignore: cast_nullable_to_non_nullable
              as String,
      isLoading: null == isLoading
          ? _value.isLoading
          : isLoading // ignore: cast_nullable_to_non_nullable
              as bool,
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
      error: freezed == error
          ? _value.error
          : error // ignore: cast_nullable_to_non_nullable
              as String?,
      stats: freezed == stats
          ? _value.stats
          : stats // ignore: cast_nullable_to_non_nullable
              as OrderStatsEntity?,
      isSearching: null == isSearching
          ? _value.isSearching
          : isSearching // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

/// @nodoc

class _$OrdersStateImpl implements _OrdersState {
  const _$OrdersStateImpl(
      {final List<OrderEntity> orders = const <OrderEntity>[],
      final List<OrderEntity> filteredOrders = const <OrderEntity>[],
      this.selectedFilter,
      this.sortOption = OrderSortOption.newest,
      this.searchQuery = '',
      this.isLoading = false,
      this.isLoadingMore = false,
      this.hasMore = true,
      this.page = 1,
      this.error,
      this.stats,
      this.isSearching = false})
      : _orders = orders,
        _filteredOrders = filteredOrders;

  final List<OrderEntity> _orders;
  @override
  @JsonKey()
  List<OrderEntity> get orders {
    if (_orders is EqualUnmodifiableListView) return _orders;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_orders);
  }

  final List<OrderEntity> _filteredOrders;
  @override
  @JsonKey()
  List<OrderEntity> get filteredOrders {
    if (_filteredOrders is EqualUnmodifiableListView) return _filteredOrders;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_filteredOrders);
  }

  @override
  final OrderStatus? selectedFilter;
  @override
  @JsonKey()
  final OrderSortOption sortOption;
  @override
  @JsonKey()
  final String searchQuery;
  @override
  @JsonKey()
  final bool isLoading;
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
  final String? error;
  @override
  final OrderStatsEntity? stats;
  @override
  @JsonKey()
  final bool isSearching;

  @override
  String toString() {
    return 'OrdersState(orders: $orders, filteredOrders: $filteredOrders, selectedFilter: $selectedFilter, sortOption: $sortOption, searchQuery: $searchQuery, isLoading: $isLoading, isLoadingMore: $isLoadingMore, hasMore: $hasMore, page: $page, error: $error, stats: $stats, isSearching: $isSearching)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$OrdersStateImpl &&
            const DeepCollectionEquality().equals(other._orders, _orders) &&
            const DeepCollectionEquality()
                .equals(other._filteredOrders, _filteredOrders) &&
            (identical(other.selectedFilter, selectedFilter) ||
                other.selectedFilter == selectedFilter) &&
            (identical(other.sortOption, sortOption) ||
                other.sortOption == sortOption) &&
            (identical(other.searchQuery, searchQuery) ||
                other.searchQuery == searchQuery) &&
            (identical(other.isLoading, isLoading) ||
                other.isLoading == isLoading) &&
            (identical(other.isLoadingMore, isLoadingMore) ||
                other.isLoadingMore == isLoadingMore) &&
            (identical(other.hasMore, hasMore) || other.hasMore == hasMore) &&
            (identical(other.page, page) || other.page == page) &&
            (identical(other.error, error) || other.error == error) &&
            (identical(other.stats, stats) || other.stats == stats) &&
            (identical(other.isSearching, isSearching) ||
                other.isSearching == isSearching));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      const DeepCollectionEquality().hash(_orders),
      const DeepCollectionEquality().hash(_filteredOrders),
      selectedFilter,
      sortOption,
      searchQuery,
      isLoading,
      isLoadingMore,
      hasMore,
      page,
      error,
      stats,
      isSearching);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$OrdersStateImplCopyWith<_$OrdersStateImpl> get copyWith =>
      __$$OrdersStateImplCopyWithImpl<_$OrdersStateImpl>(this, _$identity);
}

abstract class _OrdersState implements OrdersState {
  const factory _OrdersState(
      {final List<OrderEntity> orders,
      final List<OrderEntity> filteredOrders,
      final OrderStatus? selectedFilter,
      final OrderSortOption sortOption,
      final String searchQuery,
      final bool isLoading,
      final bool isLoadingMore,
      final bool hasMore,
      final int page,
      final String? error,
      final OrderStatsEntity? stats,
      final bool isSearching}) = _$OrdersStateImpl;

  @override
  List<OrderEntity> get orders;
  @override
  List<OrderEntity> get filteredOrders;
  @override
  OrderStatus? get selectedFilter;
  @override
  OrderSortOption get sortOption;
  @override
  String get searchQuery;
  @override
  bool get isLoading;
  @override
  bool get isLoadingMore;
  @override
  bool get hasMore;
  @override
  int get page;
  @override
  String? get error;
  @override
  OrderStatsEntity? get stats;
  @override
  bool get isSearching;
  @override
  @JsonKey(ignore: true)
  _$$OrdersStateImplCopyWith<_$OrdersStateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
