import 'package:freezed_annotation/freezed_annotation.dart';

part 'product_seller_entity.freezed.dart';

@freezed
class ProductSellerEntity with _$ProductSellerEntity {
  const factory ProductSellerEntity({
    required String id,
    required String name,
    required String avatarUrl,
    @Default(4.9) double rating,
    @Default(230) int salesCount,
    @Default(false) bool verified,
  }) = _ProductSellerEntity;
}
