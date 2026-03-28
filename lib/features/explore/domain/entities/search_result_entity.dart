import 'package:freezed_annotation/freezed_annotation.dart';

part 'search_result_entity.freezed.dart';

@freezed
class SearchResultEntity with _$SearchResultEntity {
  const factory SearchResultEntity({
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
  }) = _SearchResultEntity;
}
