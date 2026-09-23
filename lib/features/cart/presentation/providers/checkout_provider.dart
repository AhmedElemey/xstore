import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/analytics/analytics_service.dart';
import '../../../../core/analytics/event_names.dart';
import '../../../../core/network/app_error_messages.dart';
import '../../../../core/network/connectivity_provider.dart';
import '../../../addresses/presentation/providers/address_book_provider.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../orders/domain/entities/order_entity.dart';
import '../../domain/entities/place_order_params.dart';
import 'cart_provider.dart';
import 'cart_state.dart';
import 'checkout_state.dart';

part 'checkout_provider.g.dart';

@riverpod
class Checkout extends _$Checkout {
  // Set when this autoDispose notifier is torn down (screen popped) so an
  // in-flight placeOrder (or the async address seed below) doesn't write
  // state to a disposed notifier — that throws an unhandled StateError.
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
    // Saved addresses live in `addressBookProvider` now — shared with the
    // Profile "My Addresses" screen so an edit made from either place is
    // visible from the other. Checkout keeps its own copy in
    // CheckoutState only for the per-order selection (which saved address
    // this specific order ships to); seeding it below preselects the
    // account's main address, same as before this provider existed.
    unawaited(_seedFromAddressBook());
    return const CheckoutState(selectedPayment: PaymentMethod.cashOnDelivery);
  }

  Future<void> _seedFromAddressBook() async {
    await ref.read(addressBookProvider.notifier).ensureLoaded();
    if (_disposed) return;
    final addresses = ref.read(addressBookProvider);
    if (_disposed || addresses.isEmpty) return;
    final mainIndex = ref.read(addressBookProvider.notifier).mainIndex;
    state = state.copyWith(
      savedAddresses: addresses,
      selectedAddressIndex: mainIndex >= 0 ? mainIndex : 0,
    );
  }

  void selectAddress(int index) {
    if (index < 0 || index >= state.savedAddresses.length) return;
    state = state.copyWith(selectedAddressIndex: index);
    ref
        .read(analyticsServiceProvider)
        .track(AnalyticsEvents.checkoutAddressSelected);
  }

  void addAddress(OrderAddress a) {
    final added = ref.read(addressBookProvider.notifier).addAddress(a);
    if (!added) return;
    final list = ref.read(addressBookProvider);
    state = state.copyWith(
      savedAddresses: list,
      selectedAddressIndex: list.length - 1,
    );
    ref
        .read(analyticsServiceProvider)
        .track(AnalyticsEvents.checkoutAddressAdded);
  }

  void updateAddress(int index, OrderAddress a) {
    if (index < 0 || index >= state.savedAddresses.length) return;
    ref.read(addressBookProvider.notifier).updateAddress(index, a);
    state = state.copyWith(savedAddresses: ref.read(addressBookProvider));
  }

  void removeAddress(int index) {
    if (index < 0 || index >= state.savedAddresses.length) return;
    ref.read(addressBookProvider.notifier).removeAddress(index);
    final list = ref.read(addressBookProvider);
    final sel = state.selectedAddressIndex;
    int? nextSelected;
    if (list.isEmpty || sel == null) {
      nextSelected = null;
    } else if (sel > index) {
      nextSelected = sel - 1;
    } else if (sel == index) {
      nextSelected = 0;
    } else {
      nextSelected = sel;
    }
    state = state.copyWith(savedAddresses: list, selectedAddressIndex: nextSelected);
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

  void _trackPlacementFailed(String reason, CartState cart) {
    ref.read(analyticsServiceProvider).track(
      AnalyticsEvents.orderPlacementFailed,
      properties: {
        AnalyticsProps.reason: reason,
        AnalyticsProps.cartValueEgp: cart.total,
        AnalyticsProps.itemCount: cart.selectedAvailableItems.length,
      },
    );
  }

  Future<OrderEntity?> placeOrder() async {
    // A second call while the first is in flight would place every line
    // again (one POST /api/orders per line, no idempotency key).
    if (state.isPlacingOrder) return null;
    final cart = ref.read(cartProvider);
    if (!ref.read(isOnlineProvider)) {
      state = state.copyWith(error: 'offline');
      _trackPlacementFailed('offline', cart);
      return null;
    }
    final cartNotifier = ref.read(cartProvider.notifier);
    final selected = cart.selectedAvailableItems.toList();
    if (selected.isEmpty) {
      state = state.copyWith(error: 'noItems');
      _trackPlacementFailed('noItems', cart);
      return null;
    }
    final idx = state.selectedAddressIndex;
    if (idx == null || idx < 0 || idx >= state.savedAddresses.length) {
      state = state.copyWith(error: 'noAddress');
      _trackPlacementFailed('noAddress', cart);
      return null;
    }
    state = state.copyWith(isPlacingOrder: true, error: null);
    final addr = state.savedAddresses[idx];
    final consumerId = cart.consumerId.isNotEmpty
        ? cart.consumerId
        : ref.read(authProvider).valueOrNull?.id ?? '';
    if (consumerId.isEmpty) {
      state = state.copyWith(isPlacingOrder: false, error: 'noConsumer');
      _trackPlacementFailed('noConsumer', cart);
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
    final failureReason = order == null ? (cartError ?? 'failed') : null;
    state = state.copyWith(
      isPlacingOrder: false,
      placedOrderId: order?.id,
      error: failureReason,
    );
    if (failureReason != null) {
      // Cart's error is the server's free-text message for most failures —
      // only stable codes go to analytics.
      const stableCodes = {
        'failed',
        kOfflineErrorCode,
        phoneNotVerifiedErrorCode,
        rateLimitErrorCode,
      };
      _trackPlacementFailed(
        stableCodes.contains(failureReason) ? failureReason : 'server_error',
        cart,
      );
    }
    return order;
  }
}
