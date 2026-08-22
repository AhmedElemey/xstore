import 'package:freezed_annotation/freezed_annotation.dart';

part 'product_seller_entity.freezed.dart';

@freezed
class ProductSellerEntity with _$ProductSellerEntity {
  const ProductSellerEntity._();

  const factory ProductSellerEntity({
    required String id,
    required String name,
    required String avatarUrl,
    double? rating,
    int? salesCount,
    @Default(false) bool verified,
    String? whatsappNumber,
  }) = _ProductSellerEntity;

  bool get hasPublicStats {
    final r = rating;
    final s = salesCount;
    return (r != null && r > 0) || (s != null && s > 0);
  }
}
