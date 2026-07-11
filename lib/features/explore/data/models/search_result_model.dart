import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../listing/data/models/listing_model.dart'
    show listingConditionLabelFromRaw;
import '../../domain/entities/search_result_entity.dart';

part 'search_result_model.freezed.dart';
part 'search_result_model.g.dart';

@freezed
class SearchResultModel with _$SearchResultModel {
  const factory SearchResultModel({
    required String id,
    required String name,
    required double price,
    double? compareAtPrice,
    String? imageUrl,
    required String condition,
    required String category,
    required double rating,
    required int reviewCount,
    required String sellerName,
    required bool isSellerVerified,
    required String location,
    required bool hasShipping,
  }) = _SearchResultModel;

  factory SearchResultModel.fromJson(Map<String, dynamic> json) =>
      _$SearchResultModelFromJson(json);

  /// Map a listing-shaped API object (same shape as [ListingModel]) into search tiles.
  factory SearchResultModel.fromListingLike(Map<String, dynamic> json) {
    final id = (json['id'] ?? '').toString();
    final title = (json['title'] ?? json['name'] ?? '').toString();
    final price = _readDouble(json['price']);
    final compare = _nullableDouble(json['compareAtPrice'] ?? json['compare_at_price']);
    final images = json['imageUrls'];
    String? imageUrl;
    if (images is List && images.isNotEmpty) {
      imageUrl = images.first?.toString();
    } else {
      imageUrl = json['imageUrl']?.toString();
    }
    final seller = json['seller'] ?? json['vendor'];
    String sellerName = '';
    var verified = false;
    double sellerRating = 0;
    if (seller is Map) {
      final m = Map<String, dynamic>.from(seller);
      sellerName =
          (m['name'] ?? m['displayName'] ?? m['storeName'] ?? '').toString();
      verified = m['verified'] == true || m['isVerified'] == true;
      sellerRating = _readDouble(m['rating'] ?? m['averageRating']);
    }
    final listingRating = _readDouble(json['rating'] ?? json['averageRating']);
    final rating =
        listingRating != 0 ? listingRating : sellerRating;
    return SearchResultModel(
      id: id,
      name: title,
      price: price,
      compareAtPrice: compare,
      imageUrl: imageUrl,
      // Wire codes 1..4 become display tokens ('New', …); '0' (unset) → ''.
      condition: listingConditionLabelFromRaw(
        json['conditionLabel'] ?? json['condition'],
      ),
      category: _readString(json, const [
        'categoryLabel',
        'category',
      ]),
      rating: rating,
      reviewCount: _reviewCount(json),
      sellerName: sellerName,
      isSellerVerified: verified,
      location: _readString(json, const [
        'location',
        'city',
      ]),
      hasShipping: json['shippingAvailable'] != false &&
          json['hasShipping'] != false,
    );
  }
}

double _readDouble(Object? v) =>
    v is num ? v.toDouble() : double.tryParse(v?.toString() ?? '') ?? 0;

double? _nullableDouble(Object? v) {
  if (v == null) return null;
  if (v is num) return v.toDouble();
  final s = v.toString();
  if (s.isEmpty) return null;
  return double.tryParse(s);
}

String _readString(Map<String, dynamic> json, List<String> keys) {
  for (final k in keys) {
    final raw = json[k];
    if (raw is String && raw.isNotEmpty) return raw;
    if (raw is Map && raw['name'] is String) {
      return raw['name'] as String;
    }
  }
  return '';
}

int _reviewCount(Map<String, dynamic> json) {
  final rc = json['reviewCount'];
  if (rc is num) return rc.toInt();
  final rcParsed = int.tryParse(rc?.toString() ?? '');
  if (rcParsed != null) return rcParsed;
  final reviews = json['reviews'];
  if (reviews is List) return reviews.length;
  return 0;
}

extension SearchResultModelX on SearchResultModel {
  SearchResultEntity toEntity() => SearchResultEntity(
        id: id,
        name: name,
        price: price,
        compareAtPrice: compareAtPrice,
        imageUrl: imageUrl,
        condition: condition,
        category: category,
        rating: rating,
        reviewCount: reviewCount,
        sellerName: sellerName,
        isSellerVerified: isSellerVerified,
        location: location,
        hasShipping: hasShipping,
      );
}
