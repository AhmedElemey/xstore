import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../auth/domain/entities/user_entity.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../domain/entities/order_entity.dart';
import 'orders_dependencies.dart';

const _vendorPageSize = 10;

enum VendorOrderSortOption {
  newestFirst,
  oldestFirst,
  highestValue,
  needsAction,
  buyerNameAZ,
}

class VendorOrdersState {
  const VendorOrdersState({
    this.orders = const [],
    this.filteredOrders = const [],
    this.selectedFilter,
    this.sortOption = VendorOrderSortOption.needsAction,
    this.searchQuery = '',
    this.pendingCount = 0,
    this.activeCount = 0,
    this.totalCount = 0,
    this.totalRevenue = 0,
    this.isLoading = false,
    this.isLoadingMore = false,
    this.hasMore = true,
    this.page = 1,
    this.error,
  });

  final List<OrderEntity> orders;
  final List<OrderEntity> filteredOrders;
  final OrderStatus? selectedFilter;
  final VendorOrderSortOption sortOption;
  final String searchQuery;
  final int pendingCount;
  final int activeCount;
  final int totalCount;
  final double totalRevenue;
  final bool isLoading;
  final bool isLoadingMore;
  final bool hasMore;
  final int page;
  final String? error;

  VendorOrdersState copyWith({
    List<OrderEntity>? orders,
    List<OrderEntity>? filteredOrders,
    Object? selectedFilter = _sentinel,
    VendorOrderSortOption? sortOption,
    String? searchQuery,
    int? pendingCount,
    int? activeCount,
    int? totalCount,
    double? totalRevenue,
    bool? isLoading,
    bool? isLoadingMore,
    bool? hasMore,
    int? page,
    Object? error = _sentinel,
  }) {
    return VendorOrdersState(
      orders: orders ?? this.orders,
      filteredOrders: filteredOrders ?? this.filteredOrders,
      selectedFilter: selectedFilter == _sentinel
          ? this.selectedFilter
          : selectedFilter as OrderStatus?,
      sortOption: sortOption ?? this.sortOption,
      searchQuery: searchQuery ?? this.searchQuery,
      pendingCount: pendingCount ?? this.pendingCount,
      activeCount: activeCount ?? this.activeCount,
      totalCount: totalCount ?? this.totalCount,
      totalRevenue: totalRevenue ?? this.totalRevenue,
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      hasMore: hasMore ?? this.hasMore,
      page: page ?? this.page,
      error: error == _sentinel ? this.error : error as String?,
    );
  }
}

const _sentinel = Object();

class VendorOrdersNotifier extends StateNotifier<VendorOrdersState> {
  VendorOrdersNotifier(this.ref) : super(const VendorOrdersState());

  final Ref ref;

  UserEntity? get _user => ref.read(authProvider).valueOrNull;
  String? get _vendorId =>
      _user?.role == UserRole.vendor ? _user?.id : null;

  Future<void> fetchOrders() async {
    final vendorId = _vendorId;
    if (vendorId == null) return;
    state = state.copyWith(
      isLoading: true,
      error: null,
      page: 1,
      hasMore: true,
      orders: const [],
      filteredOrders: const [],
    );
    final result = await ref.read(getVendorOrdersUseCaseProvider).call(
          vendorId: vendorId,
          page: 1,
          pageSize: _vendorPageSize,
        );
    result.fold(
      (failure) => state = state.copyWith(
        isLoading: false,
        hasMore: false,
        error: failure.toString(),
      ),
      (orders) {
        state = state.copyWith(
          isLoading: false,
          orders: orders,
          hasMore: orders.length >= _vendorPageSize,
          page: 1,
        );
        _recompute();
      },
    );
  }

  Future<void> refreshOrders() => fetchOrders();

  Future<void> loadMore() async {
    final vendorId = _vendorId;
    if (vendorId == null || state.isLoadingMore || !state.hasMore) return;
    state = state.copyWith(isLoadingMore: true, error: null);
    final nextPage = state.page + 1;
    final result = await ref.read(getVendorOrdersUseCaseProvider).call(
          vendorId: vendorId,
          page: nextPage,
          pageSize: _vendorPageSize,
        );
    result.fold(
      (failure) => state = state.copyWith(
        isLoadingMore: false,
        error: failure.toString(),
      ),
      (orders) {
        state = state.copyWith(
          isLoadingMore: false,
          page: nextPage,
          hasMore: orders.length >= _vendorPageSize,
          orders: [...state.orders, ...orders],
        );
        _recompute();
      },
    );
  }

  void applyFilter(OrderStatus? status) {
    state = state.copyWith(selectedFilter: status);
    _recompute();
  }

  void applySort(VendorOrderSortOption option) {
    state = state.copyWith(sortOption: option);
    _recompute();
  }

  void updateSearch(String query) {
    state = state.copyWith(searchQuery: query.trim());
    _recompute();
  }

  Future<bool> confirmOrder(String orderId) async {
    final snapshot = state.orders;
    _optimisticStatus(orderId, OrderStatus.confirmed);
    final result = await ref.read(confirmOrderUseCaseProvider).call(orderId);
    return result.fold((failure) {
      state = state.copyWith(orders: snapshot, error: failure.toString());
      _recompute();
      return false;
    }, (order) {
      _mergeOrder(order);
      return true;
    });
  }

  Future<int> confirmAllPending() async {
    var ok = 0;
    final pending = state.orders
        .where((o) => o.status == OrderStatus.pending)
        .map((o) => o.id)
        .toList();
    for (final id in pending) {
      if (await confirmOrder(id)) ok++;
    }
    return ok;
  }

  Future<bool> rejectOrder(String orderId, String reason) async {
    final snapshot = state.orders;
    _optimisticStatus(
      orderId,
      OrderStatus.cancelled,
      cancelReason: reason,
      cancelledAt: DateTime.now(),
    );
    final result = await ref.read(rejectOrderUseCaseProvider).call(
          orderId: orderId,
          reason: reason,
        );
    return result.fold((failure) {
      state = state.copyWith(orders: snapshot, error: failure.toString());
      _recompute();
      return false;
    }, (order) {
      _mergeOrder(order);
      return true;
    });
  }

  Future<bool> markProcessing(String orderId) async {
    final snapshot = state.orders;
    _optimisticStatus(orderId, OrderStatus.processing);
    final result = await ref.read(markProcessingUseCaseProvider).call(orderId);
    return result.fold((failure) {
      state = state.copyWith(orders: snapshot, error: failure.toString());
      _recompute();
      return false;
    }, (order) {
      _mergeOrder(order);
      return true;
    });
  }

  Future<bool> markShipped(String orderId, ShippingInfo info) async {
    final snapshot = state.orders;
    final now = DateTime.now();
    final tracking = info.trackingNumber?.trim().isNotEmpty == true
        ? info.trackingNumber
        : 'XS-TRACK-$orderId';
    state = state.copyWith(
      orders: state.orders
          .map(
            (o) => o.id == orderId
                ? o.copyWith(
                    status: OrderStatus.shipped,
                    trackingNumber: tracking,
                    courierName: info.courierName ?? o.courierName,
                    estimatedDelivery: info.estimatedDelivery ?? o.estimatedDelivery,
                    shippedAt: now,
                    updatedAt: now,
                  )
                : o,
          )
          .toList(),
    );
    _recompute();
    final result = await ref.read(markShippedUseCaseProvider).call(
          orderId: orderId,
          shippingInfo: info,
        );
    return result.fold((failure) {
      state = state.copyWith(orders: snapshot, error: failure.toString());
      _recompute();
      return false;
    }, (order) {
      _mergeOrder(order);
      return true;
    });
  }

  int statusCount(OrderStatus status) =>
      state.orders.where((o) => o.status == status).length;

  void clearError() {
    state = state.copyWith(error: null);
  }

  void _optimisticStatus(
    String orderId,
    OrderStatus status, {
    String? cancelReason,
    DateTime? cancelledAt,
  }) {
    final now = DateTime.now();
    state = state.copyWith(
      orders: state.orders
          .map(
            (o) => o.id == orderId
                ? o.copyWith(
                    status: status,
                    cancelReason: cancelReason ?? o.cancelReason,
                    cancelledAt: cancelledAt ?? o.cancelledAt,
                    confirmedAt: status == OrderStatus.confirmed ? now : o.confirmedAt,
                    updatedAt: now,
                  )
                : o,
          )
          .toList(),
    );
    _recompute();
  }

  void _mergeOrder(OrderEntity order) {
    final idx = state.orders.indexWhere((o) => o.id == order.id);
    if (idx < 0) {
      state = state.copyWith(orders: [order, ...state.orders]);
    } else {
      final next = [...state.orders]..[idx] = order;
      state = state.copyWith(orders: next);
    }
    _recompute();
  }

  void _recompute() {
    var list = [...state.orders];
    final q = state.searchQuery.toLowerCase();
    if (q.isNotEmpty) {
      list = list
          .where(
            (o) =>
                o.formattedOrderId.toLowerCase().contains(q) ||
                o.consumerName.toLowerCase().contains(q),
          )
          .toList();
    }
    if (state.selectedFilter != null) {
      list = list.where((o) => o.status == state.selectedFilter).toList();
    }
    list = _sort(list, state.sortOption);
    final pending = state.orders.where((o) => o.status == OrderStatus.pending).length;
    final active = state.orders
        .where(
          (o) =>
              o.status == OrderStatus.confirmed ||
              o.status == OrderStatus.processing ||
              o.status == OrderStatus.shipped,
        )
        .length;
    final revenue = state.orders
        .where((o) => o.status == OrderStatus.delivered)
        .fold<double>(0, (sum, o) => sum + o.total);
    state = state.copyWith(
      filteredOrders: list,
      pendingCount: pending,
      activeCount: active,
      totalCount: state.orders.length,
      totalRevenue: revenue,
    );
  }

  List<OrderEntity> _sort(List<OrderEntity> input, VendorOrderSortOption option) {
    final sorted = [...input];
    int pendingRank(OrderEntity o) => o.status == OrderStatus.pending ? 0 : 1;
    int compareByDate(OrderEntity a, OrderEntity b) =>
        b.createdAt.compareTo(a.createdAt);

    switch (option) {
      case VendorOrderSortOption.newestFirst:
        sorted.sort((a, b) {
          final r = pendingRank(a).compareTo(pendingRank(b));
          if (r != 0) return r;
          return b.createdAt.compareTo(a.createdAt);
        });
      case VendorOrderSortOption.oldestFirst:
        sorted.sort((a, b) {
          final r = pendingRank(a).compareTo(pendingRank(b));
          if (r != 0) return r;
          return a.createdAt.compareTo(b.createdAt);
        });
      case VendorOrderSortOption.highestValue:
        sorted.sort((a, b) {
          final r = pendingRank(a).compareTo(pendingRank(b));
          if (r != 0) return r;
          return b.total.compareTo(a.total);
        });
      case VendorOrderSortOption.needsAction:
        sorted.sort((a, b) {
          int rank(OrderStatus s) => switch (s) {
                OrderStatus.pending => 0,
                OrderStatus.confirmed => 1,
                OrderStatus.processing => 2,
                OrderStatus.shipped => 3,
                _ => 9,
              };
          final r = rank(a.status).compareTo(rank(b.status));
          if (r != 0) return r;
          return compareByDate(a, b);
        });
      case VendorOrderSortOption.buyerNameAZ:
        sorted.sort((a, b) {
          final r = pendingRank(a).compareTo(pendingRank(b));
          if (r != 0) return r;
          return a.consumerName.toLowerCase().compareTo(b.consumerName.toLowerCase());
        });
    }
    return sorted;
  }
}

final vendorOrdersProvider =
    StateNotifierProvider<VendorOrdersNotifier, VendorOrdersState>(
  (ref) => VendorOrdersNotifier(ref),
);
