import 'package:freezed_annotation/freezed_annotation.dart';

part 'cart_item_entity.freezed.dart';

@freezed
class CartItemEntity with _$CartItemEntity {
  const factory CartItemEntity({
    required String id,
    required String listingId,
    required String listingName,
    required String listingImage,
    @Default('') String listingSlug,
    required String vendorId,
    required String vendorName,
    required String vendorStoreName,
    @Default('') String vendorAvatar,
    @Default(4.8) double vendorRating,
    @Default(true) bool vendorVerified,
    required double price,
    double? compareAtPrice,
    required int quantity,
    required int maxQuantity,
    required String category,
    required String condition,
    @Default(true) bool shippingAvailable,
    @Default(0.0) double shippingCost,
    @Default(true) bool isAvailable,
    required DateTime addedAt,
  }) = _CartItemEntity;
}
