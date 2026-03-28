import 'package:freezed_annotation/freezed_annotation.dart';

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
