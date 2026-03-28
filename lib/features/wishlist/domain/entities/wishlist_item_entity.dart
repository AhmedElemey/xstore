import 'package:freezed_annotation/freezed_annotation.dart';

part 'wishlist_item_entity.freezed.dart';

@freezed
class WishlistItemEntity with _$WishlistItemEntity {
  const factory WishlistItemEntity({
    required String id,
    required String listingId,
    required String listingName,
    required List<String> listingImages,
    @Default('') String listingSlug,
    required String vendorId,
    required String vendorName,
    required String vendorStoreName,
    @Default('') String vendorAvatar,
    @Default(true) bool isVendorVerified,
    required double price,
    double? compareAtPrice,
    double? previousPrice,
    int? priceDropPercent,
    required String category,
    required String condition,
    @Default(4.7) double rating,
    @Default(0) int reviewCount,
    @Default(1) int stockQuantity,
    @Default(true) bool isAvailable,
    @Default(false) bool isInCart,
    @Default(true) bool shippingAvailable,
    @Default(0.0) double shippingCost,
    required DateTime addedAt,
    required DateTime lastPriceCheckAt,
  }) = _WishlistItemEntity;
}
