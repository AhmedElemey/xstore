import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/analytics/analytics_service.dart';
import '../../../../core/analytics/event_names.dart';
import '../../../../core/network/connectivity_provider.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../orders/domain/entities/order_entity.dart';
import '../../domain/entities/place_order_params.dart';
import 'cart_provider.dart';
import 'checkout_state.dart';

part 'checkout_provider.g.dart';

@riverpod
class Checkout extends _$Checkout {
  // Set when this autoDispose notifier is torn down (screen popped) so an
  // in-flight placeOrder doesn't write state to a disposed notifier — that
  // throws an unhandled StateError.
  var _disposed = false;

  @override
  CheckoutState build() {
    _disposed = false;
    ref.onDispose(() => _disposed = true);
    final cart = ref.read(cartProvider);
    ref.read(analyticsServiceProvider).track(
      AnalyticsEvents.beginCheckout,
      properties: {
        AnalyticsProps.cartValueEgp: cart.total,
        AnalyticsProps.itemCount: cart.selectedAvailableItems.length,
        AnalyticsProps.vendorCount: cart.vendorGroups.length,
      },
    );
    return CheckoutState(
      savedAddresses: [
        const OrderAddress(
          fullName: 'Ahmed Hassan',
          phone: '01012345678',
          street: '12 Tahrir Street',
          city: 'Cairo',
          wilaya: 'Cairo',
          postalCode: '11511',
          isDefault: true,
        ),
      ],
      selectedAddressIndex: 0,
      selectedPayment: PaymentMethod.cashOnDelivery,
    );
  }

  void selectAddress(int index) {
    if (index < 0 || index >= state.savedAddresses.length) return;
    state = state.copyWith(selectedAddressIndex: index);
  }

  void addAddress(OrderAddress a) {
    final list = [...state.savedAddresses, a];
    state = state.copyWith(
      savedAddresses: list,
      selectedAddressIndex: list.length - 1,
    );
  }

  void updateDeliveryNote(String v) {
    state = state.copyWith(deliveryNote: v);
  }

  String? _validateStep1() {
    if (state.savedAddresses.isEmpty) return 'noAddress';
    if (state.selectedAddressIndex == null) return 'noAddress';
    return null;
  }

  String? _validateStep2() {
    // COD is the only launch method; no card capture.
    return null;
  }

  bool nextStep() {
    state = state.copyWith(error: null);
    switch (state.currentStep) {
      case 1:
        final e = _validateStep1();
        if (e != null) {
          state = state.copyWith(error: e);
          return false;
        }
        state = state.copyWith(currentStep: 2);
        return true;
      case 2:
        final e = _validateStep2();
        if (e != null) {
          state = state.copyWith(error: e);
          return false;
        }
        state = state.copyWith(currentStep: 3);
        return true;
      default:
        return true;
    }
  }

  void previousStep() {
    if (state.currentStep <= 1) return;
    state = state.copyWith(currentStep: state.currentStep - 1, error: null);
  }

  Future<OrderEntity?> placeOrder() async {
    if (!ref.read(isOnlineProvider)) {
      state = state.copyWith(error: 'offline');
      return null;
    }
    final cart = ref.read(cartProvider);
    final cartNotifier = ref.read(cartProvider.notifier);
    final selected = cart.selectedAvailableItems.toList();
    if (selected.isEmpty) {
      state = state.copyWith(error: 'noItems');
      return null;
    }
    final idx = state.selectedAddressIndex;
    if (idx == null || idx < 0 || idx >= state.savedAddresses.length) {
      state = state.copyWith(error: 'noAddress');
      return null;
    }
    state = state.copyWith(isPlacingOrder: true, error: null);
    final addr = state.savedAddresses[idx];
    final consumerId = cart.consumerId.isNotEmpty
        ? cart.consumerId
        : ref.read(authProvider).valueOrNull?.id ?? '';
    if (consumerId.isEmpty) {
      state = state.copyWith(isPlacingOrder: false, error: 'noConsumer');
      return null;
    }
    final params = PlaceOrderParams(
      consumerId: consumerId,
      items: selected,
      deliveryAddress: addr,
      paymentMethod: PaymentMethod.cashOnDelivery,
      deliveryNote: state.deliveryNote.trim().isEmpty
          ? null
          : state.deliveryNote.trim(),
      subtotal: cart.subtotal,
      shippingTotal: cart.shippingTotal,
      discount: cart.discount,
      total: cart.total,
    );
    final order = await cartNotifier.placeOrder(params);
    // The order is placed either way; only skip the state write if the
    // checkout screen (and this notifier) is already gone.
    if (_disposed) return order;
    // Cart's own notifier captures the specific failure (e.g. offline,
    // or a stable code like phoneNotVerifiedErrorCode) in its own state —
    // read it through rather than collapsing every failure to 'failed'.
    final cartError = ref.read(cartProvider).error;
    state = state.copyWith(
      isPlacingOrder: false,
      placedOrderId: order?.id,
      error: order == null ? (cartError ?? 'failed') : null,
    );
    return order;
  }
}
