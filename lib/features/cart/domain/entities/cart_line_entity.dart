import 'package:freezed_annotation/freezed_annotation.dart';

part 'cart_line_entity.freezed.dart';

@freezed
class CartLineEntity with _$CartLineEntity {
  const factory CartLineEntity({
    required String listingId,
    required String title,
    required double unitPrice,
    String? imageUrl,
    @Default(1) int quantity,
  }) = _CartLineEntity;
}
