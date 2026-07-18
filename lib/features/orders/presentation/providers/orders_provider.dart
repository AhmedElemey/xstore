import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../auth/domain/entities/user_entity.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../cart/presentation/providers/cart_provider.dart';
import '../../data/datasources/orders_remote_datasource.dart';
import '../../domain/entities/order_entity.dart';
import 'orders_dependencies.dart';

part 'orders_provider.freezed.dart';
part 'orders_provider.g.dart';

const int _pageSize = 10;

@freezed
class OrdersState with _$OrdersState {
  const factory OrdersState({
    @Default(<OrderEntity>[]) List<OrderEntity> orders,
    @Default(<OrderEntity>[]) List<OrderEntity> filteredOrders,
    OrderStatus? selectedFilter,
    @Default(OrderSortOption.newest) OrderSortOption sortOption,
    @Default('') String searchQuery,
    @Default(false) bool isLoading,
    @Default(false) bool isLoadingMore,
    @Default(true) bool hasMore,
    @Default(1) int page,
    String? error,
    OrderStatsEntity? stats,
    @Default(false) bool isSearching,
  }) = _OrdersState;
}

@Riverpod(keepAlive: true)
class OrdersNotifier extends _$OrdersNotifier {
  @override
  OrdersState build() {
    // keepAlive state must not outlive the session that fetched it: drop the
    // previous user's orders (and the mock fixtures) whenever the signed-in
    // user changes or signs out.
    ref.listen<AsyncValue<UserEntity?>>(authProvider, (prev, next) {
      if (next.isLoading) return;
      if (prev?.valueOrNull?.id == next.valueOrNull?.id) return;
      Future.microtask(() {
        OrdersRemoteDataSourceImpl.clearSessionCache();
        state = const OrdersState();
      });
    });
    return const OrdersState();
  }

  UserEntity? get _user => ref.read(authProvider).valueOrNull;

  bool get _isVendor => _user?.role == UserRole.vendor;

  String? get _consumerId => _isVendor ? null : _user?.id;

  String? get _vendorId => _isVendor ? _user?.id : null;

  List<OrderStatus> get _consumerFilters => const [
        OrderStatus.pending,
        OrderStatus.confirmed,
        OrderStatus.shipped,
        OrderStatus.delivered,
        OrderStatus.cancelled,
      ];

  List<OrderStatus> get _vendorFilters => const [
        OrderStatus.pending,
        OrderStatus.confirmed,
        OrderStatus.processing,
        OrderStatus.shipped,
        OrderStatus.delivered,
        OrderStatus.cancelled,
      ];

  Future<void> fetchOrders() async {
    state = state.copyWith(
      isLoading: true,
      error: null,
      page: 1,
      orders: [],
      hasMore: true,
    );
    if (_user == null) {
      state = state.copyWith(isLoading: false);
      return;
    }

    OrderStatsEntity? stats;
    if (_isVendor) {
      final statsResult = await ref
          .read(getVendorOrderStatsUseCaseProvider)
          .call(_vendorId!);
      stats = statsResult.fold((_) => null, (s) => s);
    }

    final result = _isVendor
        ? await ref.read(getVendorOrdersUseCaseProvider).call(
              vendorId: _vendorId!,
              page: 1,
              pageSize: _pageSize,
            )
        : await ref.read(getConsumerOrdersUseCaseProvider).call(
              consumerId: _consumerId!,
              page: 1,
              pageSize: _pageSize,
            );

    result.fold(
      (f) => state = state.copyWith(
        isLoading: false,
        error: f.toString(),
      ),
      (list) {
        state = state.copyWith(
          isLoading: false,
          orders: list,
          page: 1,
          hasMore: list.length >= _pageSize,
          stats: stats ?? state.stats,
        );
        _recomputeDerived();
      },
    );
  }

  Future<void> loadMore() async {
    if (!state.hasMore || state.isLoadingMore || _user == null) return;
    state = state.copyWith(isLoadingMore: true, error: null);
    final next = state.page + 1;
    final result = _isVendor
        ? await ref.read(getVendorOrdersUseCaseProvider).call(
              vendorId: _vendorId!,
              page: next,
              pageSize: _pageSize,
            )
        : await ref.read(getConsumerOrdersUseCaseProvider).call(
              consumerId: _consumerId!,
              page: next,
              pageSize: _pageSize,
            );

    result.fold(
      (f) => state = state.copyWith(
        isLoadingMore: false,
        error: f.toString(),
      ),
      (list) {
        final merged = [...state.orders, ...list];
        state = state.copyWith(
          isLoadingMore: false,
          orders: merged,
          page: next,
          hasMore: list.length >= _pageSize,
        );
        _recomputeDerived();
      },
    );
  }

  Future<void> refreshOrders() async {
    await fetchOrders();
  }

  void applyFilter(OrderStatus? status) {
    state = state.copyWith(selectedFilter: status);
    _recomputeDerived();
  }

  void applySort(OrderSortOption option) {
    state = state.copyWith(sortOption: option);
    _recomputeDerived();
  }

  void updateSearch(String q) {
    state = state.copyWith(searchQuery: q.trim());
    _recomputeDerived();
  }

  void setSearching(bool v) {
    state = state.copyWith(isSearching: v);
  }

  void _recomputeDerived() {
    var list = List<OrderEntity>.from(state.orders);

    final q = state.searchQuery.toLowerCase();
    if (q.isNotEmpty) {
      list = list.where((o) {
        if (o.id.toLowerCase().contains(q)) return true;
        if (o.formattedOrderId.toLowerCase().contains(q)) return true;
        return o.items.any((i) => i.listingName.toLowerCase().contains(q));
      }).toList();
    }

    final f = state.selectedFilter;
    if (f != null) {
      list = list.where((o) => o.status == f).toList();
    }

    list = _sorted(list, state.sortOption);

    state = state.copyWith(filteredOrders: list);
  }

  List<OrderEntity> _sorted(List<OrderEntity> input, OrderSortOption sort) {
    final copy = List<OrderEntity>.from(input);
    switch (sort) {
      case OrderSortOption.newest:
        copy.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      case OrderSortOption.oldest:
        copy.sort((a, b) => a.createdAt.compareTo(b.createdAt));
      case OrderSortOption.highestValue:
        copy.sort((a, b) => b.total.compareTo(a.total));
      case OrderSortOption.needsAction:
        copy.sort((a, b) {
          int rank(OrderStatus s) => switch (s) {
                OrderStatus.pending => 0,
                OrderStatus.processing => 1,
                OrderStatus.confirmed => 2,
                OrderStatus.shipped => 3,
                _ => 9,
              };
          final c = rank(a.status).compareTo(rank(b.status));
          if (c != 0) return c;
          return b.createdAt.compareTo(a.createdAt);
        });
    }
    return copy;
  }

  int tabCount(OrderStatus? status) {
    if (status == null) return state.orders.length;
    return state.orders.where((e) => e.status == status).length;
  }

  List<OrderStatus> filtersForRole(bool vendor) =>
      vendor ? _vendorFilters : _consumerFilters;

  Future<void> cancelOrder(String orderId, String reason) async {
    final snapshot = state.orders;
    final updated = snapshot
        .map(
          (o) => o.id == orderId
              ? o.copyWith(
                  status: OrderStatus.cancelled,
                  cancelReason: reason,
                  cancelledAt: DateTime.now(),
                  updatedAt: DateTime.now(),
                )
              : o,
        )
        .toList();
    state = state.copyWith(orders: updated);
    _recomputeDerived();
    final result = await ref.read(cancelOrderUseCaseProvider).call(
          orderId: orderId,
          reason: reason,
          isVendorSession: _isVendor,
        );
    result.fold(
      (failure) {
        state = state.copyWith(orders: snapshot);
        _recomputeDerived();
        state = state.copyWith(error: failure.toString());
      },
      (o) => _mergeOrder(o),
    );
  }

  Future<void> confirmReceipt(String orderId) async {
    await markDelivered(orderId);
  }

  Future<void> reorder(String orderId) async {
    OrderEntity? order;
    for (final o in state.orders) {
      if (o.id == orderId) order = o;
    }
    order ??= () {
      for (final o in state.filteredOrders) {
        if (o.id == orderId) return o;
      }
      return null;
    }();
    if (order == null) return;
    await ref.read(cartProvider.notifier).reorderFromOrderItems(order.items);
  }

  Future<void> confirmOrderVendor(String orderId) async {
    final snapshot = state.orders;
    _optimisticStatus(orderId, OrderStatus.confirmed,
        confirmedAt: DateTime.now(),);
    final result =
        await ref.read(confirmOrderUseCaseProvider).call(orderId);
    result.fold(
      (failure) {
        state = state.copyWith(orders: snapshot, error: failure.toString());
        _recomputeDerived();
      },
      _mergeOrder,
    );
  }

  Future<void> rejectOrder(String orderId, String reason) async {
    final snapshot = state.orders;
    _optimisticStatus(orderId, OrderStatus.cancelled,
        cancelReason: reason,
        cancelledAt: DateTime.now(),);
    final result = await ref.read(rejectOrderUseCaseProvider).call(
          orderId: orderId,
          reason: reason,
        );
    result.fold(
      (failure) {
        state = state.copyWith(orders: snapshot, error: failure.toString());
        _recomputeDerived();
      },
      _mergeOrder,
    );
  }

  Future<void> markProcessing(String orderId) async {
    final snapshot = state.orders;
    _optimisticStatus(orderId, OrderStatus.processing);
    final result =
        await ref.read(markProcessingUseCaseProvider).call(orderId);
    result.fold(
      (failure) {
        state = state.copyWith(orders: snapshot, error: failure.toString());
        _recomputeDerived();
      },
      _mergeOrder,
    );
  }

  Future<void> markShipped(String orderId, ShippingInfo info) async {
    final snapshot = state.orders;
    final now = DateTime.now();
    final tn = info.trackingNumber ?? 'XS-TRACK-$orderId';
    state = state.copyWith(
      orders: state.orders
          .map(
            (o) => o.id == orderId
                ? o.copyWith(
                    status: OrderStatus.shipped,
                    trackingNumber: tn,
                    courierName: info.courierName ?? o.courierName,
                    estimatedDelivery:
                        info.estimatedDelivery ?? o.estimatedDelivery,
                    trackingLocation: AppStrings.ordersCurrentLocationMock,
                    shippedAt: now,
                    updatedAt: now,
                  )
                : o,
          )
          .toList(),
    );
    _recomputeDerived();
    final result = await ref.read(markShippedUseCaseProvider).call(
          orderId: orderId,
          shippingInfo: info,
        );
    result.fold(
      (failure) {
        state = state.copyWith(orders: snapshot, error: failure.toString());
        _recomputeDerived();
      },
      _mergeOrder,
    );
  }

  Future<void> markDelivered(String orderId) async {
    final snapshot = state.orders;
    final now = DateTime.now();
    state = state.copyWith(
      orders: state.orders
          .map(
            (o) => o.id == orderId
                ? o.copyWith(
                    status: OrderStatus.delivered,
                    deliveredAt: now,
                    updatedAt: now,
                  )
                : o,
          )
          .toList(),
    );
    _recomputeDerived();
    final result =
        await ref.read(markDeliveredUseCaseProvider).call(orderId);
    result.fold(
      (failure) {
        state = state.copyWith(orders: snapshot, error: failure.toString());
        _recomputeDerived();
      },
      _mergeOrder,
    );
  }

  void _optimisticStatus(
    String orderId,
    OrderStatus status, {
    DateTime? confirmedAt,
    DateTime? cancelledAt,
    String? cancelReason,
  }) {
    final now = DateTime.now();
    state = state.copyWith(
      orders: state.orders
          .map(
            (o) => o.id == orderId
                ? o.copyWith(
                    status: status,
                    updatedAt: now,
                    confirmedAt: confirmedAt ?? o.confirmedAt,
                    cancelledAt: cancelledAt ?? o.cancelledAt,
                    cancelReason: cancelReason ?? o.cancelReason,
                  )
                : o,
          )
          .toList(),
    );
    _recomputeDerived();
  }

  void _mergeOrder(OrderEntity o) {
    final idx = state.orders.indexWhere((e) => e.id == o.id);
    if (idx < 0) {
      state = state.copyWith(orders: [...state.orders, o]);
    } else {
      final next = [...state.orders]..[idx] = o;
      state = state.copyWith(orders: next);
    }
    _recomputeDerived();
    if (_isVendor) {
      ref
          .read(getVendorOrderStatsUseCaseProvider)
          .call(_vendorId!)
          .then((r) => r.fold((_) => null, (s) {
                state = state.copyWith(stats: s);
              }),);
    }
  }

  void clearError() {
    state = state.copyWith(error: null);
  }
}
