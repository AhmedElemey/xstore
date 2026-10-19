import 'package:freezed_annotation/freezed_annotation.dart';

import 'cart_item_entity.dart';

part 'cart_entity.freezed.dart';

@freezed
class CartVendorGroup with _$CartVendorGroup {
  const factory CartVendorGroup({
    required String vendorId,
    required String vendorName,
    required String vendorStoreName,
    required String vendorAvatar,
    double? vendorRating,
    @Default(true) bool vendorVerified,
    required List<CartItemEntity> items,
    @Default(0.0) double groupSubtotal,
  }) = _CartVendorGroup;
}

@freezed
class CartEntity with _$CartEntity {
  const factory CartEntity({
    required String id,
    required String consumerId,
    required List<CartItemEntity> items,
    @Default(<String>{}) Set<String> selectedItemIds,
    @Default(0.0) double subtotal,
    @Default(0.0) double shippingTotal,
    @Default(0.0) double total,
    @Default(0) int itemCount,
  }) = _CartEntity;
}
