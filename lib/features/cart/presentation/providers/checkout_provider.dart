import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../orders/domain/entities/order_entity.dart';
import '../../domain/entities/place_order_params.dart';
import 'cart_provider.dart';
import 'checkout_state.dart';

part 'checkout_provider.g.dart';

@riverpod
class Checkout extends _$Checkout {
  @override
  CheckoutState build() {
    return CheckoutState(
      savedAddresses: [
        const OrderAddress(
          fullName: 'Sara Khelifi',
          phone: '+213 555 987 654',
          street: '12 Rue Didouche Mourad',
          city: 'Oran',
          wilaya: 'Oran',
          postalCode: '31000',
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

  void selectPayment(PaymentMethod m) {
    state = state.copyWith(selectedPayment: m);
  }

  void updateDeliveryNote(String v) {
    state = state.copyWith(deliveryNote: v);
  }

  void updateCard(String number, String expiry, String cvv) {
    state = state.copyWith(
      cardNumber: number,
      cardExpiry: expiry,
      cardCvv: cvv,
    );
  }

  String? _validateStep1() {
    if (state.savedAddresses.isEmpty) return 'noAddress';
    if (state.selectedAddressIndex == null) return 'noAddress';
    return null;
  }

  String? _validateStep2() {
    final p = state.selectedPayment;
    if (p == null) return 'noPayment';
    if (p == PaymentMethod.cibCard) {
      final n = state.cardNumber.replaceAll(RegExp(r'\s'), '');
      if (n.length < 12) return 'invalidCard';
    }
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
    final pay = state.selectedPayment;
    if (pay == null) {
      state = state.copyWith(error: 'noPayment');
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
      paymentMethod: pay,
      deliveryNote: state.deliveryNote.trim().isEmpty
          ? null
          : state.deliveryNote.trim(),
      subtotal: cart.subtotal,
      shippingTotal: cart.shippingTotal,
      discount: cart.discount,
      total: cart.total,
      cardNumber: pay == PaymentMethod.cibCard ? state.cardNumber : null,
      cardExpiry: pay == PaymentMethod.cibCard ? state.cardExpiry : null,
      cardCvv: pay == PaymentMethod.cibCard ? state.cardCvv : null,
    );
    final order = await cartNotifier.placeOrder(params);
    state = state.copyWith(
      isPlacingOrder: false,
      placedOrderId: order?.id,
    );
    return order;
  }
}
