import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../auth/domain/entities/user_entity.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../domain/entities/order_entity.dart';
import 'orders_dependencies.dart';
import 'vendor_orders_provider.dart';

class VendorOrderDetailState {
  const VendorOrderDetailState({
    this.order,
    this.isLoading = false,
    this.error,
  });

  final OrderEntity? order;
  final bool isLoading;
  final String? error;

  VendorOrderDetailState copyWith({
    OrderEntity? order,
    bool? isLoading,
    Object? error = _detailSentinel,
  }) {
    return VendorOrderDetailState(
      order: order ?? this.order,
      isLoading: isLoading ?? this.isLoading,
      error: error == _detailSentinel ? this.error : error as String?,
    );
  }
}

const _detailSentinel = Object();

class VendorOrderDetailNotifier extends StateNotifier<VendorOrderDetailState> {
  VendorOrderDetailNotifier(this.ref, this.orderId)
      : super(const VendorOrderDetailState());

  final Ref ref;
  final String orderId;

  String? get _vendorId {
    final user = ref.read(authProvider).valueOrNull;
    if (user?.role != UserRole.vendor) return null;
    return user?.id;
  }

  Future<void> fetchOrder() async {
    final vendorId = _vendorId;
    if (vendorId == null) return;
    state = state.copyWith(isLoading: true, error: null);
    final result = await ref.read(getOrderDetailUseCaseProvider).call(
          orderId: orderId,
          consumerId: null,
          vendorId: vendorId,
          isVendorSession: true,
        );
    if (!mounted) return;
    result.fold(
      (failure) => state = state.copyWith(
        isLoading: false,
        error: failure.toString(),
      ),
      (order) {
        final prev = state.order;
        var next = order;
        if (prev != null &&
            (next.trackingNumber == null ||
                next.trackingNumber!.trim().isEmpty) &&
            prev.trackingNumber != null &&
            prev.trackingNumber!.trim().isNotEmpty) {
          next = next.copyWith(
            trackingNumber: prev.trackingNumber,
            courierName: next.courierName ?? prev.courierName,
            estimatedDelivery: next.estimatedDelivery ?? prev.estimatedDelivery,
          );
        }
        state = state.copyWith(isLoading: false, order: next);
      },
    );
  }

  Future<bool> confirmOrder(DeliveryMethod method) async {
    final ok = await ref
        .read(vendorOrdersProvider.notifier)
        .confirmOrder(orderId, method);
    if (!mounted) return ok;
    if (ok) {
      await fetchOrder();
    }
    return ok;
  }

  Future<bool> rejectOrder(String reason) async {
    final ok = await ref.read(vendorOrdersProvider.notifier).rejectOrder(orderId, reason);
    if (!mounted) return ok;
    if (ok) {
      await fetchOrder();
    }
    return ok;
  }

  Future<bool> markProcessing() async {
    final ok = await ref.read(vendorOrdersProvider.notifier).markProcessing(orderId);
    if (!mounted) return ok;
    if (ok) {
      await fetchOrder();
    }
    return ok;
  }

  Future<bool> markShipped(ShippingInfo info) async {
    final previous = state.order;
    final ok = await ref.read(vendorOrdersProvider.notifier).markShipped(orderId, info);
    if (!mounted) return ok;
    if (ok) {
      final tn = info.trackingNumber?.trim();
      final base = state.order ?? previous;
      if (base != null) {
        state = state.copyWith(
          isLoading: false,
          order: base.copyWith(
            status: OrderStatus.shipped,
            trackingNumber: (tn != null && tn.isNotEmpty)
                ? tn
                : (base.trackingNumber ?? 'XS-TRACK-$orderId'),
            courierName: info.courierName ?? base.courierName,
            estimatedDelivery:
                info.estimatedDelivery ?? base.estimatedDelivery,
            shippedAt: base.shippedAt ?? DateTime.now(),
          ),
        );
      } else {
        await fetchOrder();
      }
    }
    return ok;
  }

  void clearError() {
    state = state.copyWith(error: null);
  }
}

// autoDispose: screen-scoped — without it every visited order detail keeps
// its notifier (and fetched order) alive for the rest of the app session.
final vendorOrderDetailProvider = StateNotifierProvider.autoDispose.family<
    VendorOrderDetailNotifier, VendorOrderDetailState, String>(
  (ref, orderId) => VendorOrderDetailNotifier(ref, orderId),
);
