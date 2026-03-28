import 'package:freezed_annotation/freezed_annotation.dart';

import 'cart_item_entity.dart';

part 'cart_entity.freezed.dart';

enum DiscountType {
  percentage,
  fixed,
}

@freezed
class CouponEntity with _$CouponEntity {
  const factory CouponEntity({
    required String code,
    required DiscountType discountType,
    required double discountValue,
    double? minOrderAmount,
    double? maxDiscount,
    @Default(true) bool isValid,
    @Default('') String message,
  }) = _CouponEntity;
}

@freezed
class CartVendorGroup with _$CartVendorGroup {
  const factory CartVendorGroup({
    required String vendorId,
    required String vendorName,
    required String vendorStoreName,
    required String vendorAvatar,
    @Default(4.8) double vendorRating,
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
    String? couponCode,
    CouponEntity? coupon,
    @Default(0.0) double subtotal,
    @Default(0.0) double shippingTotal,
    @Default(0.0) double discount,
    @Default(0.0) double total,
    @Default(0) int itemCount,
  }) = _CartEntity;
}

class CouponException implements Exception {
  CouponException(this.message);
  final String message;
}
