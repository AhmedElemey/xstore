import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../home/domain/entities/deal_entity.dart';
import '../../../listing/domain/entities/listing_entity.dart';
import '../../domain/entities/product_review_entity.dart';
import '../../domain/entities/product_seller_entity.dart';

part 'product_detail_state.freezed.dart';

@freezed
class ProductDetailState with _$ProductDetailState {
  const factory ProductDetailState({
    ListingEntity? listing,
    @Default(1) int quantity,
    @Default(false) bool isFavorite,
    @Default(0) int selectedImageIndex,
    @Default(false) bool isDescriptionExpanded,
    @Default(false) bool isAddingToCart,
    double? compareAtPrice,
    @Default(99) int stockQuantity,
    @Default('') String locationLine,
    ProductSellerEntity? seller,
    @Default({}) Map<String, String> specifications,
    ReviewSummaryEntity? reviewSummary,
    @Default(<ProductReviewEntity>[]) List<ProductReviewEntity> reviews,
    @Default(<DealEntity>[]) List<DealEntity> similarProducts,
  }) = _ProductDetailState;
}
