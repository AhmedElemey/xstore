import 'package:freezed_annotation/freezed_annotation.dart';

import '../../domain/entities/listing_entity.dart';

part 'listing_model.freezed.dart';
part 'listing_model.g.dart';

Map<String, dynamic> _normalizeListingJson(Map<String, dynamic> json) {
  final m = Map<String, dynamic>.from(json);
  final rawCat = m['categoryLabel'] ?? m['category'];
  if (rawCat is String) {
    m['categoryLabel'] = rawCat;
  } else if (rawCat is Map && rawCat['name'] is String) {
    m['categoryLabel'] = rawCat['name'];
  } else {
    m['categoryLabel'] ??= '';
  }
  final rawCond = m['conditionLabel'] ?? m['condition'];
  m['conditionLabel'] =
      rawCond is String ? rawCond : (rawCond?.toString() ?? '');
  m['postedAt'] = m['postedAt'] ?? m['createdAt'];
  m['viewCount'] = m['viewCount'] ?? m['views'] ?? 0;
  m['saveCount'] = m['saveCount'] ?? m['saves'] ?? 0;
  m['inquiryCount'] = m['inquiryCount'] ?? m['inquiries'] ?? 0;

  m['vendorId'] = m['vendorId'] ?? m['sellerId'] ?? '';
  m['titleEn'] = m['titleEn'] ?? m['title'] ?? '';
  m['titleAr'] = m['titleAr'] ?? '';
  m['descriptionEn'] = m['descriptionEn'] ?? m['description'] ?? '';
  m['descriptionAr'] = m['descriptionAr'] ?? '';
  // ASSUMPTION: flat title/description alongside En/Ar — see ListingEntity.
  m['title'] = m['title'] ?? m['titleEn'] ?? '';
  m['description'] = m['description'] ?? m['descriptionEn'] ?? '';
  m['compareAtPrice'] = m['compareAtPrice'] ?? m['compare_at_price'];
  m['categoryId'] = m['categoryId'];
  m['subcategoryId'] = m['subcategoryId'];
  m['condition'] = (m['condition'])?.toString();
  m['brand'] = m['brand'] ?? '';
  m['stockQuantity'] = m['stockQuantity'] ?? m['stock'] ?? m['quantity'] ?? 0;
  m['shippingAvailable'] = m['shippingAvailable'] ?? false;
  m['shippingCost'] = m['shippingCost'] ?? 0.0;
  m['location'] = m['location'] ?? '';
  m['attributes'] = m['attributes'] is Map
      ? (m['attributes'] as Map)
          .map((k, v) => MapEntry(k.toString(), v?.toString() ?? ''))
      : <String, String>{};
  return m;
}

// ASSUMPTION: tokens not enumerated in the API spec, adjust once confirmed.
ListingCondition? _conditionFromDto(String? value) {
  switch (value?.toLowerCase()) {
    case 'new':
      return ListingCondition.newItem;
    case 'likenew':
    case 'like_new':
    case 'like new':
      return ListingCondition.likeNew;
    case 'good':
      return ListingCondition.good;
    case 'used':
      return ListingCondition.used;
    case 'forparts':
    case 'for_parts':
    case 'for parts':
      return ListingCondition.forParts;
    default:
      return null;
  }
}

String _conditionToDto(ListingCondition c) {
  switch (c) {
    case ListingCondition.newItem:
      return 'New';
    case ListingCondition.likeNew:
      return 'LikeNew';
    case ListingCondition.good:
      return 'Good';
    case ListingCondition.used:
      return 'Used';
    case ListingCondition.forParts:
      return 'ForParts';
  }
}

@freezed
class ListingModel with _$ListingModel {
  const factory ListingModel({
    required String id,
    required String title,
    required String description,
    required double price,
    @Default('draft') String status,
    @Default(<String>[]) List<String> imageUrls,
    @Default('') String categoryLabel,
    @Default('') String conditionLabel,
    DateTime? postedAt,
    @Default(0) int viewCount,
    @Default(0) int saveCount,
    @Default(0) int inquiryCount,
    @Default('') String vendorId,
    @Default('') String titleEn,
    @Default('') String titleAr,
    @Default('') String descriptionEn,
    @Default('') String descriptionAr,
    double? compareAtPrice,
    int? categoryId,
    int? subcategoryId,
    String? condition,
    @Default('') String brand,
    @Default(0) int stockQuantity,
    @Default(false) bool shippingAvailable,
    @Default(0.0) double shippingCost,
    @Default('') String location,
    @Default(<String, String>{}) Map<String, String> attributes,
  }) = _ListingModel;

  factory ListingModel.fromJson(Map<String, dynamic> json) =>
      _$ListingModelFromJson(_normalizeListingJson(json));
}

ListingStatus _listingStatusFromDto(String value) {
  switch (value.toLowerCase()) {
    case 'pending':
      return ListingStatus.pending;
    case 'active':
      return ListingStatus.active;
    case 'paused':
      return ListingStatus.paused;
    case 'sold':
      return ListingStatus.sold;
    case 'rejected':
      return ListingStatus.rejected;
    case 'draft':
    default:
      return ListingStatus.draft;
  }
}

extension ListingModelX on ListingModel {
  ListingEntity toEntity() => ListingEntity(
        id: id,
        title: title,
        description: description,
        price: price,
        status: _listingStatusFromDto(status),
        imageUrls: imageUrls,
        categoryLabel: categoryLabel,
        conditionLabel: conditionLabel,
        postedAt: postedAt,
        viewCount: viewCount,
        saveCount: saveCount,
        inquiryCount: inquiryCount,
        vendorId: vendorId,
        titleEn: titleEn,
        titleAr: titleAr,
        descriptionEn: descriptionEn,
        descriptionAr: descriptionAr,
        compareAtPrice: compareAtPrice,
        categoryId: categoryId,
        subcategoryId: subcategoryId,
        condition: _conditionFromDto(condition),
        brand: brand,
        stockQuantity: stockQuantity,
        shippingAvailable: shippingAvailable,
        shippingCost: shippingCost,
        location: location,
        attributes: attributes,
      );
}

/// Wire token for [ListingCondition] — used by the datasource when sending
/// create/update payloads.
String listingConditionToDto(ListingCondition c) => _conditionToDto(c);
