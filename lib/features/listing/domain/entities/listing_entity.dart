import 'package:freezed_annotation/freezed_annotation.dart';

part 'listing_entity.freezed.dart';

enum ListingStatus {
  draft,
  pending,
  active,
  paused,
  sold,
  rejected,
}

enum ListingCondition { newItem, likeNew, good, used, forParts }

@freezed
class ListingEntity with _$ListingEntity {
  const factory ListingEntity({
    required String id,
    required String title,
    required String description,
    required double price,
    required ListingStatus status,
    @Default(<String>[]) List<String> imageUrls,
    @Default('') String categoryLabel,
    @Default('') String conditionLabel,
    DateTime? postedAt,
    @Default(0) int viewCount,
    @Default(0) int saveCount,
    @Default(0) int inquiryCount,
    // --- Phase 2 backend integration additions ---
    @Default('') String vendorId,
    // ASSUMPTION: GET responses return flat title/description (English
    // display) alongside the En/Ar write fields — unconfirmed, verify
    // against a live response; if GET only returns titleEn/titleAr,
    // resolve title := titleEn in the model parser.
    @Default('') String titleEn,
    @Default('') String titleAr,
    @Default('') String descriptionEn,
    @Default('') String descriptionAr,
    double? compareAtPrice,
    int? categoryId,
    int? subcategoryId,
    ListingCondition? condition,
    @Default('') String brand,
    @Default(0) int stockQuantity,
    @Default(false) bool shippingAvailable,
    @Default(0.0) double shippingCost,
    @Default('') String location,
    @Default(<String, String>{}) Map<String, String> attributes,
  }) = _ListingEntity;
}
