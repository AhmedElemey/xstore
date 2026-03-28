import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../home/domain/entities/deal_entity.dart';
import '../../../listing/domain/entities/listing_entity.dart';
import 'product_review_entity.dart';
import 'product_seller_entity.dart';

part 'product_detail_entity.freezed.dart';

@freezed
class ProductDetailEntity with _$ProductDetailEntity {
  const factory ProductDetailEntity({
    required ListingEntity listing,
    double? compareAtPrice,
    @Default(99) int stockQuantity,
    @Default('') String locationLine,
    ProductSellerEntity? seller,
    @Default({}) Map<String, String> specifications,
    ReviewSummaryEntity? reviewSummary,
    @Default(<ProductReviewEntity>[]) List<ProductReviewEntity> reviews,
    @Default(<DealEntity>[]) List<DealEntity> similarProducts,
  }) = _ProductDetailEntity;
}
