import 'package:freezed_annotation/freezed_annotation.dart';

part 'order_item_entity.freezed.dart';

@freezed
class OrderItemEntity with _$OrderItemEntity {
  const factory OrderItemEntity({
    required String id,
    required String listingId,
    required String listingName,
    required String listingImage,
    required String category,
    required String condition,
    required double price,
    required int quantity,
    required double total,
  }) = _OrderItemEntity;
}
