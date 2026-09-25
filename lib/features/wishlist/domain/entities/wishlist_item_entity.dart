import 'package:freezed_annotation/freezed_annotation.dart';

part 'wishlist_item_entity.freezed.dart';

@freezed
class WishlistItemEntity with _$WishlistItemEntity {
  const WishlistItemEntity._();

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
    double? rating,
    @Default(0) int reviewCount,
    @Default(1) int stockQuantity,
    @Default(true) bool isAvailable,
    @Default(false) bool isInCart,
    @Default(true) bool shippingAvailable,
    @Default(0.0) double shippingCost,
    required DateTime addedAt,
    required DateTime lastPriceCheckAt,
  }) = _WishlistItemEntity;

  /// The percentage the price has dropped SINCE this item was wishlisted —
  /// distinct from [compareAtPrice], a vendor-set markdown unrelated to
  /// when the item was saved.
  ///
  /// Prefers the backend's own [priceDropPercent] when it sends one, but
  /// [previousPrice] alone already proves a drop happened (it's the price
  /// as of [lastPriceCheckAt]) — falling back to computing the percentage
  /// from it means a backend response that sets `previousPrice` but omits
  /// `priceDropPercent` still counts, instead of the "Price Dropped" filter
  /// silently missing items whose card still shows the struck-through price.
  int get effectiveDropPercent {
    final backendPercent = priceDropPercent ?? 0;
    if (backendPercent > 0) return backendPercent;
    final prev = previousPrice;
    if (prev == null || prev <= price) return 0;
    return (((prev - price) / prev) * 100).round();
  }
}
