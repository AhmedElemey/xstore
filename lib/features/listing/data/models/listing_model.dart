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
  return m;
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
      );
}
