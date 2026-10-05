import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/analytics/analytics_service.dart';
import '../../../../core/analytics/event_names.dart';
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
    @Default(false) bool isSearching,
  }) = _OrdersState;
}

/// The consumer's My Orders list. Vendors never reach /orders (they use
/// VendorOrdersScreen and `vendorOrdersProvider`).
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
        _fetchEpoch++;
        state = const OrdersState();
      });
    });
    return const OrdersState();
  }

  UserEntity? get _user => ref.read(authProvider).valueOrNull;

  var _fetchEpoch = 0;

  Future<void> fetchOrders() async {
    final epoch = ++_fetchEpoch;
    // Keep the current list on screen while refetching so tab revisits
    // and pull-to-refresh do not flash an empty skeleton.
    state = state.copyWith(
      isLoading: true,
      error: null,
      page: 1,
      hasMore: true,
    );
    final consumerId = _user?.id;
    if (consumerId == null) {
      if (epoch != _fetchEpoch) return;
      state = state.copyWith(isLoading: false);
      return;
    }

    final result = await ref.read(getConsumerOrdersUseCaseProvider).call(
          consumerId: consumerId,
          page: 1,
          pageSize: _pageSize,
        );

    if (epoch != _fetchEpoch) return;
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
        );
        _recomputeDerived();
      },
    );
  }

  Future<void> loadMore() async {
    final consumerId = _user?.id;
    if (!state.hasMore || state.isLoadingMore || consumerId == null) return;
    final epoch = _fetchEpoch;
    state = state.copyWith(isLoadingMore: true, error: null);
    final next = state.page + 1;
    final result = await ref.read(getConsumerOrdersUseCaseProvider).call(
          consumerId: consumerId,
          page: next,
          pageSize: _pageSize,
        );

    if (epoch != _fetchEpoch) return;
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

  void _trackOrderStatus(String orderId, OrderStatus status) {
    // No cancel/reject `reason`: it is localized or free text typed by the
    // user — the order API already stores it, joinable by order_id.
    ref.read(analyticsServiceProvider).track(
      AnalyticsEvents.orderStatusChanged,
      properties: {
        AnalyticsProps.orderId: orderId,
        AnalyticsProps.status: status.name,
        AnalyticsProps.role: 'consumer',
      },
    );
  }

  Future<void> cancelOrder(String orderId, String reason) async {
    final original = _orderById(orderId);
    if (original == null) return;
    final updated = state.orders
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
    final epoch = _fetchEpoch;
    final result = await ref.read(cancelOrderUseCaseProvider).call(
          orderId: orderId,
          reason: reason,
          isVendorSession: false,
        );
    if (epoch != _fetchEpoch) return;
    result.fold(
      (failure) {
        _restoreOrder(original);
        state = state.copyWith(error: failure.toString());
      },
      (o) {
        _mergeOrder(o);
        _trackOrderStatus(orderId, OrderStatus.cancelled);
      },
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

  Future<void> markDelivered(String orderId) async {
    final original = _orderById(orderId);
    if (original == null) return;
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
    final epoch = _fetchEpoch;
    final result =
        await ref.read(markDeliveredUseCaseProvider).call(orderId);
    if (epoch != _fetchEpoch) return;
    result.fold(
      (failure) {
        _restoreOrder(original);
        state = state.copyWith(error: failure.toString());
      },
      (o) {
        _mergeOrder(o);
        _trackOrderStatus(orderId, OrderStatus.delivered);
      },
    );
  }

  OrderEntity? _orderById(String orderId) {
    for (final o in state.orders) {
      if (o.id == orderId) return o;
    }
    return null;
  }

  /// Rolls back a single order to [original] by id, in the CURRENT
  /// `state.orders` — not by restoring a whole-list snapshot captured
  /// before this mutator's optimistic update. Two mutators can legitimately
  /// run concurrently (e.g. cancel order A, then confirm order B before A's
  /// request resolves); a whole-list snapshot restore on A's failure would
  /// silently wipe out B's already-applied optimistic/merged change. This
  /// only touches the one order this call owns.
  void _restoreOrder(OrderEntity original) {
    final idx = state.orders.indexWhere((e) => e.id == original.id);
    if (idx < 0) return;
    final next = [...state.orders]..[idx] = original;
    state = state.copyWith(orders: next);
    _recomputeDerived();
  }

  void _mergeOrder(OrderEntity o) {
    if (o.id.isEmpty) return;
    final idx = state.orders.indexWhere((e) => e.id == o.id);
    if (idx < 0) {
      state = state.copyWith(orders: [...state.orders, o]);
    } else {
      final next = [...state.orders]
        ..[idx] = state.orders[idx].takingStatusFrom(o);
      state = state.copyWith(orders: next);
    }
    _recomputeDerived();
  }

  void clearError() {
    state = state.copyWith(error: null);
  }
}
