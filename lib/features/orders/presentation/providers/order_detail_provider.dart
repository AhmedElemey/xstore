import 'package:fpdart/fpdart.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/error/failures.dart';
import '../../../auth/domain/entities/user_entity.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../cart/presentation/providers/cart_provider.dart';
import '../../domain/entities/order_entity.dart';
import 'orders_dependencies.dart';
import 'orders_provider.dart';

part 'order_detail_provider.freezed.dart';
part 'order_detail_provider.g.dart';

@freezed
class OrderDetailState with _$OrderDetailState {
  const factory OrderDetailState({
    required String orderId,
    OrderEntity? order,
    @Default(false) bool isLoading,
    @Default(false) bool isActioning,
    String? error,
  }) = _OrderDetailState;
}

@riverpod
class OrderDetailNotifier extends _$OrderDetailNotifier {
  // Set when this autoDispose notifier is torn down (screen popped) so
  // in-flight requests don't write state to a disposed notifier — that
  // throws an unhandled StateError.
  var _disposed = false;

  @override
  OrderDetailState build(String orderId) {
    _disposed = false;
    ref.onDispose(() => _disposed = true);
    return OrderDetailState(orderId: orderId);
  }

  bool get _isVendor =>
      ref.read(authProvider).valueOrNull?.role == UserRole.vendor;

  String? get _consumerId =>
      _isVendor ? null : ref.read(authProvider).valueOrNull?.id;

  String? get _vendorId =>
      _isVendor ? ref.read(authProvider).valueOrNull?.id : null;

  Future<void> fetchOrder() async {
    state = state.copyWith(isLoading: true, error: null);
    final result = await ref.read(getOrderDetailUseCaseProvider).call(
          orderId: state.orderId,
          consumerId: _consumerId,
          vendorId: _vendorId,
          isVendorSession: _isVendor,
        );
    if (_disposed) return;
    result.fold(
      (f) => state = state.copyWith(isLoading: false, error: f.toString()),
      (o) => state = state.copyWith(isLoading: false, order: o),
    );
  }

  Future<void> cancelOrder(String reason) async {
    final prev = state.order;
    if (prev == null) return;
    final optimistic = prev.copyWith(
      status: OrderStatus.cancelled,
      cancelReason: reason,
      cancelledAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    state = state.copyWith(isActioning: true, order: optimistic, error: null);
    final result = await ref.read(cancelOrderUseCaseProvider).call(
          orderId: state.orderId,
          reason: reason,
          isVendorSession: _isVendor,
        );
    _finalizeMutation(result, prev);
  }

  Future<void> confirmOrderVendor() async {
    final prev = state.order;
    if (prev == null) return;
    final now = DateTime.now();
    final optimistic = prev.copyWith(
      status: OrderStatus.confirmed,
      confirmedAt: now,
      updatedAt: now,
    );
    state = state.copyWith(isActioning: true, order: optimistic, error: null);
    final result =
        await ref.read(confirmOrderUseCaseProvider).call(state.orderId);
    _finalizeMutation(result, prev);
  }

  Future<void> rejectOrder(String reason) async {
    final prev = state.order;
    if (prev == null) return;
    final optimistic = prev.copyWith(
      status: OrderStatus.cancelled,
      cancelReason: reason,
      cancelledAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    state = state.copyWith(isActioning: true, order: optimistic, error: null);
    final result = await ref.read(rejectOrderUseCaseProvider).call(
          orderId: state.orderId,
          reason: reason,
        );
    _finalizeMutation(result, prev);
  }

  Future<void> markProcessing() async {
    final prev = state.order;
    if (prev == null) return;
    final optimistic = prev.copyWith(
      status: OrderStatus.processing,
      updatedAt: DateTime.now(),
    );
    state = state.copyWith(isActioning: true, order: optimistic, error: null);
    final result =
        await ref.read(markProcessingUseCaseProvider).call(state.orderId);
    _finalizeMutation(result, prev);
  }

  Future<void> markShipped(ShippingInfo info) async {
    final prev = state.order;
    if (prev == null) return;
    final now = DateTime.now();
    final tn = info.trackingNumber?.trim().isNotEmpty == true
        ? info.trackingNumber
        : 'XS-TRACK-${state.orderId}';
    final optimistic = prev.copyWith(
      status: OrderStatus.shipped,
      trackingNumber: tn,
      courierName: info.courierName ?? prev.courierName,
      estimatedDelivery: info.estimatedDelivery ?? prev.estimatedDelivery,
      shippedAt: now,
      updatedAt: now,
    );
    state = state.copyWith(isActioning: true, order: optimistic, error: null);
    final result = await ref.read(markShippedUseCaseProvider).call(
          orderId: state.orderId,
          shippingInfo: info,
        );
    _finalizeMutation(result, prev);
  }

  Future<void> confirmReceipt() async {
    final prev = state.order;
    if (prev == null) return;
    final now = DateTime.now();
    final optimistic = prev.copyWith(
      status: OrderStatus.delivered,
      deliveredAt: now,
      updatedAt: now,
    );
    state = state.copyWith(isActioning: true, order: optimistic, error: null);
    final result =
        await ref.read(markDeliveredUseCaseProvider).call(state.orderId);
    _finalizeMutation(result, prev);
  }

  void _finalizeMutation(Either<Failure, OrderEntity> result, OrderEntity prev) {
    // Every mutation awaits its use case before calling this; if the screen
    // was popped mid-request the notifier is disposed — skip the state write
    // (the orders list refetches on mount, so the missed invalidate is fine).
    if (_disposed) return;
    result.fold(
      (f) => state = state.copyWith(
        isActioning: false,
        order: prev,
        error: f.toString(),
      ),
      (o) {
        state = state.copyWith(isActioning: false, order: o);
        ref.invalidate(ordersNotifierProvider);
      },
    );
  }

  Future<void> reorder() async {
    final order = state.order;
    if (order == null) return;
    await ref.read(cartProvider.notifier).reorderFromOrderItems(order.items);
  }

  void clearError() {
    state = state.copyWith(error: null);
  }
}
