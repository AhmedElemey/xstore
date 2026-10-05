import 'package:freezed_annotation/freezed_annotation.dart';

import '../../domain/entities/cart_item_entity.dart';

part 'cart_state.freezed.dart';

@freezed
class CartState with _$CartState {
  const factory CartState({
    @Default([]) List<CartItemEntity> items,
    @Default({}) Set<String> selectedItemIds,
    @Default(false) bool isLoading,
    @Default(false) bool isUpdating,
    String? error,
    @Default('') String consumerId,
    @Default(0.0) double subtotal,
    @Default(0.0) double shippingTotal,
    @Default(0.0) double total,
    CartItemEntity? lastRemovedItem,
    int? lastRemovedIndex,
  }) = _CartState;
}
