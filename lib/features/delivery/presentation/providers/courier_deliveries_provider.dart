import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../auth/domain/entities/user_entity.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../orders/domain/entities/order_entity.dart';
import '../../../orders/presentation/providers/orders_dependencies.dart';
import '../../domain/courier_order_flow.dart';
import 'courier_cash_wallet_provider.dart';

const _courierPageSize = 10;

class CourierDeliveriesState {
  const CourierDeliveriesState({
    this.orders = const [],
    this.isLoading = false,
    this.isLoadingMore = false,
    this.hasMore = true,
    this.page = 1,
    this.error,
  });

  final List<OrderEntity> orders;
  final bool isLoading;
  final bool isLoadingMore;
  final bool hasMore;
  final int page;
  final String? error;

  /// Needs pick-up or drop-off, hardest-to-stall work first.
  List<OrderEntity> get activeOrders {
    final active = orders.where(isActiveCourierOrder).toList();
    int rank(OrderStatus s) =>
        courierNextAction(s) == CourierOrderAction.deliver ? 0 : 1;
    active.sort((a, b) {
      final r = rank(a.status).compareTo(rank(b.status));
      if (r != 0) return r;
      return b.createdAt.compareTo(a.createdAt);
    });
    return active;
  }

  List<OrderEntity> get finishedOrders => orders
      .where((o) => !isActiveCourierOrder(o))
      .toList()
    ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));

  CourierDeliveriesState copyWith({
    List<OrderEntity>? orders,
    bool? isLoading,
    bool? isLoadingMore,
    bool? hasMore,
    int? page,
    Object? error = _sentinel,
  }) {
    return CourierDeliveriesState(
      orders: orders ?? this.orders,
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      hasMore: hasMore ?? this.hasMore,
      page: page ?? this.page,
      error: error == _sentinel ? this.error : error as String?,
    );
  }
}

const _sentinel = Object();

class CourierDeliveriesNotifier extends StateNotifier<CourierDeliveriesState> {
  CourierDeliveriesNotifier(this.ref) : super(const CourierDeliveriesState());

  final Ref ref;

  UserEntity? get _user => ref.read(authProvider).valueOrNull;
  String? get _courierId =>
      _user?.role == UserRole.courier ? _user?.id : null;

  Future<void> fetchOrders() async {
    final courierId = _courierId;
    if (courierId == null) return;
    state = state.copyWith(
      isLoading: true,
      error: null,
      page: 1,
      hasMore: true,
      orders: const [],
    );
    final result = await ref.read(getCourierOrdersUseCaseProvider).call(
          courierId: courierId,
          page: 1,
          pageSize: _courierPageSize,
        );
    if (!mounted) return;
    result.fold(
      (failure) => state = state.copyWith(
        isLoading: false,
        hasMore: false,
        error: failure.toString(),
      ),
      (orders) => state = state.copyWith(
        isLoading: false,
        orders: orders,
        hasMore: orders.length >= _courierPageSize,
        page: 1,
      ),
    );
  }

  Future<void> refreshOrders() => fetchOrders();

  Future<void> loadMore() async {
    final courierId = _courierId;
    if (courierId == null || state.isLoadingMore || !state.hasMore) return;
    state = state.copyWith(isLoadingMore: true, error: null);
    final nextPage = state.page + 1;
    final result = await ref.read(getCourierOrdersUseCaseProvider).call(
          courierId: courierId,
          page: nextPage,
          pageSize: _courierPageSize,
        );
    if (!mounted) return;
    result.fold(
      (failure) => state = state.copyWith(
        isLoadingMore: false,
        error: failure.toString(),
      ),
      (orders) => state = state.copyWith(
        isLoadingMore: false,
        page: nextPage,
        hasMore: orders.length >= _courierPageSize,
        orders: [...state.orders, ...orders],
      ),
    );
  }

  /// Parcel collected from the vendor → order becomes `shipped`.
  Future<bool> markPickedUp(String orderId) async {
    final snapshot = state.orders;
    final now = DateTime.now();
    _patchOrder(
      orderId,
      (o) => o.copyWith(
        status: OrderStatus.shipped,
        shippedAt: now,
        updatedAt: now,
      ),
    );
    final result = await ref.read(markShippedUseCaseProvider).call(
          orderId: orderId,
          shippingInfo: ShippingInfo(courierName: _user?.name),
        );
    if (!mounted) return false;
    return result.fold((failure) {
      state = state.copyWith(orders: snapshot, error: failure.toString());
      return false;
    }, (order) {
      _mergeOrder(order);
      return true;
    });
  }

  /// Handed to the buyer, COD collected → order becomes `delivered` and the
  /// cash lands in the courier's wallet.
  Future<bool> markDelivered(String orderId) async {
    final snapshot = state.orders;
    final now = DateTime.now();
    _patchOrder(
      orderId,
      (o) => o.copyWith(
        status: OrderStatus.delivered,
        deliveredAt: now,
        updatedAt: now,
      ),
    );
    final result =
        await ref.read(markDeliveredUseCaseProvider).call(orderId);
    if (!mounted) return false;
    return result.fold((failure) {
      state = state.copyWith(orders: snapshot, error: failure.toString());
      return false;
    }, (order) {
      _mergeOrder(order);
      // Delivered COD changes cash-in-hand.
      ref.invalidate(courierCashWalletProvider);
      return true;
    });
  }

  /// Buyer refused / unreachable → order is cancelled with the reason.
  Future<bool> markFailed(String orderId, String reason) async {
    final snapshot = state.orders;
    final now = DateTime.now();
    _patchOrder(
      orderId,
      (o) => o.copyWith(
        status: OrderStatus.cancelled,
        cancelReason: reason,
        cancelledAt: now,
        updatedAt: now,
      ),
    );
    final result = await ref.read(cancelOrderUseCaseProvider).call(
          orderId: orderId,
          reason: reason,
          isVendorSession: false,
        );
    if (!mounted) return false;
    return result.fold((failure) {
      state = state.copyWith(orders: snapshot, error: failure.toString());
      return false;
    }, (order) {
      _mergeOrder(order);
      return true;
    });
  }

  void clearError() {
    state = state.copyWith(error: null);
  }

  void _patchOrder(String orderId, OrderEntity Function(OrderEntity) patch) {
    state = state.copyWith(
      orders: state.orders
          .map((o) => o.id == orderId ? patch(o) : o)
          .toList(),
    );
  }

  void _mergeOrder(OrderEntity order) {
    final idx = state.orders.indexWhere((o) => o.id == order.id);
    if (idx < 0) {
      state = state.copyWith(orders: [order, ...state.orders]);
    } else {
      final next = [...state.orders]..[idx] = order;
      state = state.copyWith(orders: next);
    }
  }
}

final courierDeliveriesProvider =
    StateNotifierProvider<CourierDeliveriesNotifier, CourierDeliveriesState>(
  (ref) => CourierDeliveriesNotifier(ref),
);
