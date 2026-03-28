import 'package:freezed_annotation/freezed_annotation.dart';

import '../../domain/entities/cart_entity.dart';
import '../../domain/entities/cart_item_entity.dart';

part 'cart_state.freezed.dart';

@freezed
class CartState with _$CartState {
  const factory CartState({
    @Default([]) List<CartItemEntity> items,
    @Default({}) Set<String> selectedItemIds,
    CouponEntity? coupon,
    @Default('') String couponInput,
    @Default(false) bool isCouponLoading,
    @Default(false) bool isLoading,
    @Default(false) bool isUpdating,
    String? error,
    String? couponErrorKey,
    @Default('') String consumerId,
    @Default(0.0) double subtotal,
    @Default(0.0) double shippingTotal,
    @Default(0.0) double discount,
    @Default(0.0) double total,
    CartItemEntity? lastRemovedItem,
    int? lastRemovedIndex,
  }) = _CartState;
}
