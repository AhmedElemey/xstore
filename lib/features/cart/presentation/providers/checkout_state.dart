import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../orders/domain/entities/order_entity.dart';

part 'checkout_state.freezed.dart';

@freezed
class CheckoutState with _$CheckoutState {
  const factory CheckoutState({
    @Default(1) int currentStep,
    @Default(<OrderAddress>[]) List<OrderAddress> savedAddresses,
    int? selectedAddressIndex,
    PaymentMethod? selectedPayment,
    @Default('') String deliveryNote,
    @Default('') String cardNumber,
    @Default('') String cardExpiry,
    @Default('') String cardCvv,
    @Default(false) bool isPlacingOrder,
    String? placedOrderId,
    String? error,
  }) = _CheckoutState;
}
