import 'package:freezed_annotation/freezed_annotation.dart';

import '../../domain/entities/listing_entity.dart';

part 'listing_model.freezed.dart';
part 'listing_model.g.dart';

Map<String, dynamic> _normalizeListingJson(Map<String, dynamic> json) {
  final m = Map<String, dynamic>.from(json);
  // CONFIRMED against a live backend response: `id` is a JSON number, not a
  // string — coerce here so the String-typed model field doesn't crash.
  m['id'] = m['id']?.toString() ?? '';
  final rawCat = m['categoryLabel'] ?? m['category'] ?? m['categoryNameEn'];
  if (rawCat is String) {
    m['categoryLabel'] = rawCat;
  } else if (rawCat is Map && rawCat['name'] is String) {
    m['categoryLabel'] = rawCat['name'];
  } else {
    m['categoryLabel'] ??= '';
  }
  // Numeric wire codes (1..4) become canonical display tokens; '0'
  // (backend-unset) becomes '' so the UI shows no condition badge.
  m['conditionLabel'] =
      listingConditionLabelFromRaw(m['conditionLabel'] ?? m['condition']);
  m['postedAt'] = m['postedAt'] ?? m['createdAt'];
  m['viewCount'] = m['viewCount'] ?? m['views'] ?? 0;
  m['saveCount'] = m['saveCount'] ?? m['saves'] ?? 0;
  m['inquiryCount'] = m['inquiryCount'] ?? m['inquiries'] ?? 0;

  // CONFIRMED: live backend sends a flat `userId` (int) for the listing
  // owner, not `vendorId`/`sellerId`/a nested seller object.
  m['vendorId'] = (m['vendorId'] ?? m['sellerId'] ?? m['userId'])?.toString() ?? '';
  m['titleEn'] = m['titleEn'] ?? m['title'] ?? '';
  m['titleAr'] = m['titleAr'] ?? '';
  m['descriptionEn'] = m['descriptionEn'] ?? m['description'] ?? '';
  m['descriptionAr'] = m['descriptionAr'] ?? '';
  // CONFIRMED: GET responses only send titleEn/titleAr, no flat title —
  // fall back to titleEn for the legacy display fields.
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
  // CONFIRMED: `status` is a JSON number (e.g. 2), not a string — coerce
  // before the String-typed model field parses it. See
  // _listingStatusFromDto for the ordinal mapping.
  m['status'] = m['status']?.toString() ?? 'draft';
  return m;
}

// Backend contract (C# enum, 1-based):
//   ListingCondition { New = 1, LikeNew = 2, Good = 3, UsedForParts = 4 }
// `0` on the wire is the C# default for an unset field (seed data was
// created without a condition) — it is NOT a valid member and maps to null.
// POST/PUT send a flat JSON body (no `command` wrapper — that wrapper passes
// validation but EF SaveChanges 500s). `attributes` is a JSON string or null,
// not an object.
ListingCondition? _conditionFromDto(String? value) {
  // Numeric wire codes (authoritative).
  switch (value) {
    case '1':
      return ListingCondition.newItem;
    case '2':
      return ListingCondition.likeNew;
    case '3':
      return ListingCondition.good;
    case '4':
      return ListingCondition.usedForParts;
    case '0':
      return null; // unset on the backend
  }
  // String tokens (canonical labels, legacy drafts, enum names).
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
    case 'forparts':
    case 'for_parts':
    case 'for parts':
    case 'usedforparts':
    case 'used / for parts':
      return ListingCondition.usedForParts;
    default:
      return null;
  }
}

int listingConditionToWire(ListingCondition c) {
  switch (c) {
    case ListingCondition.newItem:
      return 1;
    case ListingCondition.likeNew:
      return 2;
    case ListingCondition.good:
      return 3;
    case ListingCondition.usedForParts:
      return 4;
  }
}

/// Parses any condition representation — wire code ('1'..'4'), canonical
/// display token ('Used / For Parts'), legacy draft token ('Used'), or
/// backend enum name ('UsedForParts'). Null for unknown or backend-unset
/// ('0') values.
ListingCondition? listingConditionFromToken(String value) =>
    _conditionFromDto(value);

/// Canonical English display token per condition — the value stored in
/// filter state, drafts, and `conditionLabel`; localized for display via
/// `listingLocalizedCondition`.
String listingConditionLabel(ListingCondition c) {
  switch (c) {
    case ListingCondition.newItem:
      return 'New';
    case ListingCondition.likeNew:
      return 'Like New';
    case ListingCondition.good:
      return 'Good';
    case ListingCondition.usedForParts:
      return 'Used / For Parts';
  }
}

/// Display token (or raw string for unknown values) from any wire/legacy
/// condition representation; empty string when unset.
String listingConditionLabelFromRaw(Object? raw) {
  final s = raw?.toString();
  if (s == null || s.isEmpty) return '';
  final c = _conditionFromDto(s);
  if (c != null) return listingConditionLabel(c);
  // '0' (backend-unset) parses to null — show nothing rather than "0".
  if (s == '0') return '';
  return s;
}

/// Persisted on [ListingModel.condition] after local/offline writes.
String listingConditionToDto(ListingCondition c) =>
    listingConditionToWire(c).toString();

int listingStatusToWire(ListingStatus status) {
  switch (status) {
    case ListingStatus.draft:
      return 0;
    case ListingStatus.pending:
      return 1;
    case ListingStatus.active:
      return 2;
    case ListingStatus.paused:
      return 3;
    case ListingStatus.sold:
      return 4;
    case ListingStatus.rejected:
      return 5;
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

// CONFIRMED against live listings: `status` is a JSON integer, not a string
// (only code 2 observed, on publicly-searchable listings — high confidence
// that's "Active", matching this enum's declared ordinal position). Values
// 0/1/3/4/5 are inferred by ordinal position matching ListingStatus's
// declaration order (draft/pending/active/paused/sold/rejected) since no
// samples with those codes were available — MODERATE confidence, not
// confirmed. Adjust if a live draft/paused/sold/rejected listing surfaces
// a different code.
ListingStatus _listingStatusFromDto(String value) {
  switch (value) {
    case '0':
      return ListingStatus.draft;
    case '1':
      return ListingStatus.pending;
    case '2':
      return ListingStatus.active;
    case '3':
      return ListingStatus.paused;
    case '4':
      return ListingStatus.sold;
    case '5':
      return ListingStatus.rejected;
  }
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

