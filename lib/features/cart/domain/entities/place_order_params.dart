import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../orders/domain/entities/order_entity.dart';
import 'cart_item_entity.dart';

part 'place_order_params.freezed.dart';

@freezed
class PlaceOrderParams with _$PlaceOrderParams {
  const factory PlaceOrderParams({
    required String consumerId,
    required List<CartItemEntity> items,
    required OrderAddress deliveryAddress,
    required PaymentMethod paymentMethod,
    String? deliveryNote,
    required double subtotal,
    required double shippingTotal,
    required double discount,
    required double total,
    String? cardNumber,
    String? cardExpiry,
    String? cardCvv,
  }) = _PlaceOrderParams;
}
