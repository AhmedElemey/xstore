import 'package:freezed_annotation/freezed_annotation.dart';

part 'product_seller_entity.freezed.dart';

@freezed
class ProductSellerEntity with _$ProductSellerEntity {
  const factory ProductSellerEntity({
    required String id,
    required String name,
    required String avatarUrl,
    double? rating,
    int? salesCount,
    @Default(false) bool verified,
    String? whatsappNumber,
  }) = _ProductSellerEntity;
}
