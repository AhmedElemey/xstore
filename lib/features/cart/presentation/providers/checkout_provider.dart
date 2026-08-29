import 'dart:async';
import 'dart:convert';

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/analytics/analytics_service.dart';
import '../../../../core/analytics/event_names.dart';
import '../../../../core/network/connectivity_provider.dart';
import '../../../../shared/providers/shared_providers.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../orders/domain/entities/order_entity.dart';
import '../../domain/entities/place_order_params.dart';
import 'cart_provider.dart';
import 'checkout_state.dart';

part 'checkout_provider.g.dart';

@riverpod
class Checkout extends _$Checkout {
  // Set when this autoDispose notifier is torn down (screen popped) so an
  // in-flight placeOrder (or the async address load below) doesn't write
  // state to a disposed notifier — that throws an unhandled StateError.
  var _disposed = false;

  static const _addressesKeyPrefix = 'checkout_addresses_v1_';

  String? get _consumerId => ref.read(authProvider).valueOrNull?.id;

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
    // No backend address book exists yet (order placement only ever takes
    // GPS coordinates — see createOrder), so saved addresses are the one
    // piece of checkout state kept locally, per account, instead of being
    // seeded with sample data and thrown away on screen exit.
    unawaited(_loadAddresses());
    return const CheckoutState(selectedPayment: PaymentMethod.cashOnDelivery);
  }

  Future<void> _loadAddresses() async {
    try {
      // authProvider is an AsyncNotifier — reading it synchronously here
      // (as `_consumerId` does elsewhere in this class, safely, since
      // those calls only ever happen after checkout is already showing)
      // would race its still-loading initial state and silently skip the
      // load. Await the resolved value instead; in real usage checkout is
      // unreachable until auth has already resolved, so this returns
      // immediately there.
      final consumerId = (await ref.read(authProvider.future))?.id;
      if (_disposed || consumerId == null || consumerId.isEmpty) return;
      final prefs = await ref.read(sharedPreferencesProvider.future);
      if (_disposed) return;
      final raw = prefs.getString('$_addressesKeyPrefix$consumerId');
      if (raw == null || raw.isEmpty) return;
      final decoded = jsonDecode(raw) as List<dynamic>;
      final addresses = decoded
          .whereType<Map<String, dynamic>>()
          .map(_addressFromJson)
          .toList();
      if (_disposed || addresses.isEmpty) return;
      final defaultIndex = addresses.indexWhere((a) => a.isDefault);
      state = state.copyWith(
        savedAddresses: addresses,
        selectedAddressIndex: defaultIndex >= 0 ? defaultIndex : 0,
      );
    } catch (_) {
      // Corrupt or unreadable local data — fall back to the honest empty
      // state (the address section already prompts to add one) rather
      // than blocking checkout.
    }
  }

  Future<void> _persist() async {
    final consumerId = _consumerId;
    if (consumerId == null || consumerId.isEmpty) return;
    final prefs = await ref.read(sharedPreferencesProvider.future);
    await prefs.setString(
      '$_addressesKeyPrefix$consumerId',
      jsonEncode(state.savedAddresses.map(_addressToJson).toList()),
    );
  }

  void selectAddress(int index) {
    if (index < 0 || index >= state.savedAddresses.length) return;
    state = state.copyWith(selectedAddressIndex: index);
  }

  void addAddress(OrderAddress a) {
    var list = [...state.savedAddresses];
    if (a.isDefault) {
      list = list.map((e) => e.copyWith(isDefault: false)).toList();
    }
    list.add(a);
    state = state.copyWith(
      savedAddresses: list,
      selectedAddressIndex: list.length - 1,
    );
    unawaited(_persist());
  }

  void updateAddress(int index, OrderAddress a) {
    if (index < 0 || index >= state.savedAddresses.length) return;
    var list = [...state.savedAddresses];
    if (a.isDefault) {
      list = list.map((e) => e.copyWith(isDefault: false)).toList();
    }
    list[index] = a;
    state = state.copyWith(savedAddresses: list);
    unawaited(_persist());
  }

  void removeAddress(int index) {
    if (index < 0 || index >= state.savedAddresses.length) return;
    final list = [...state.savedAddresses]..removeAt(index);
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
    unawaited(_persist());
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

/// No `OrderAddress` JSON codec exists (the entity is a plain `@freezed`
/// class, not `@JsonSerializable`) — mapped by hand, matching the manual
/// entity<->wire mapping already used throughout the data layer.
Map<String, dynamic> _addressToJson(OrderAddress a) => {
  'fullName': a.fullName,
  'phone': a.phone,
  'street': a.street,
  'city': a.city,
  'wilaya': a.wilaya,
  'postalCode': a.postalCode,
  'isDefault': a.isDefault,
};

OrderAddress _addressFromJson(Map<String, dynamic> json) => OrderAddress(
  fullName: (json['fullName'] ?? '').toString(),
  phone: (json['phone'] ?? '').toString(),
  street: (json['street'] ?? '').toString(),
  city: (json['city'] ?? '').toString(),
  wilaya: (json['wilaya'] ?? '').toString(),
  postalCode: json['postalCode'] as String?,
  isDefault: json['isDefault'] == true,
);
