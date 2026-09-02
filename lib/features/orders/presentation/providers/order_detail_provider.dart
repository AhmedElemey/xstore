import 'package:fpdart/fpdart.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/analytics/analytics_service.dart';
import '../../../../core/analytics/event_names.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/utils/location_service.dart';
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
    // Mirrors OrdersNotifier.fetchOrders' guard: initState's postFrameCallback
    // can fire before authProvider has resolved even once (a cold-start deep
    // link straight to order detail, or — in tests — a widget pumped before
    // an async auth override settles). Without this, a still-loading auth
    // state reads as "no user", the use case call comes back
    // Failure.unauthorized(), and the screen flashes a spurious error the
    // real, already-signed-in user never should have seen.
    if (ref.read(authProvider).valueOrNull == null) return;
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
    _finalizeMutation(
      result,
      prev,
      role: _isVendor ? 'vendor' : 'consumer',
      reason: reason,
    );
  }

  Future<void> confirmOrderVendor(DeliveryMethod method) async {
    final prev = state.order;
    if (prev == null) return;
    final now = DateTime.now();
    final optimistic = prev.copyWith(
      status: OrderStatus.confirmed,
      deliveryMethod: method,
      confirmedAt: now,
      updatedAt: now,
    );
    state = state.copyWith(isActioning: true, order: optimistic, error: null);
    final result = await ref
        .read(confirmOrderUseCaseProvider)
        .call(orderId: state.orderId, method: method);
    _finalizeMutation(result, prev, deliveryMethod: method);
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
    _finalizeMutation(result, prev, reason: reason);
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
    _finalizeMutation(result, prev, role: 'consumer');
  }

  void _finalizeMutation(
    Either<Failure, OrderEntity> result,
    OrderEntity prev, {
    String role = 'vendor',
    DeliveryMethod? deliveryMethod,
    String? reason,
  }) {
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
        ref.read(analyticsServiceProvider).track(
          AnalyticsEvents.orderStatusChanged,
          properties: {
            AnalyticsProps.orderId: state.orderId,
            AnalyticsProps.status: o.status.name,
            AnalyticsProps.role: role,
            if (deliveryMethod != null) AnalyticsProps.method: deliveryMethod.name,
            if (reason != null) AnalyticsProps.reason: reason,
          },
        );
      },
    );
  }

  Future<void> reorder() async {
    final order = state.order;
    if (order == null) return;
    await ref.read(cartProvider.notifier).reorderFromOrderItems(order.items);
  }

  /// Detects the device's current GPS location and updates it as this
  /// order's delivery coordinates. Doesn't change any visible order field
  /// ([OrderEntity] has nowhere to display raw lat/lng) — the caller shows
  /// its own success/error feedback based on whether [state.error] is set.
  Future<void> updateDeliveryLocation() async {
    state = state.copyWith(isActioning: true, error: null);
    try {
      final loc = await LocationService().getCurrentLocation();
      if (_disposed) return;
      final result = await ref.read(updateDeliveryLocationUseCaseProvider).call(
            orderId: state.orderId,
            latitude: loc.latitude,
            longitude: loc.longitude,
          );
      if (_disposed) return;
      result.fold(
        (f) => state = state.copyWith(isActioning: false, error: f.toString()),
        (_) => state = state.copyWith(isActioning: false, error: null),
      );
    } on XStoreLocationServiceDisabledException {
      if (_disposed) return;
      state = state.copyWith(
        isActioning: false,
        error: 'locationServiceDisabled',
      );
    } on XStoreLocationPermissionDeniedException {
      if (_disposed) return;
      state = state.copyWith(
        isActioning: false,
        error: 'locationPermissionDenied',
      );
    } on XStoreLocationPermissionPermanentlyDeniedException {
      if (_disposed) return;
      state = state.copyWith(
        isActioning: false,
        error: 'locationPermissionDenied',
      );
    }
  }

  void clearError() {
    state = state.copyWith(error: null);
  }
}
