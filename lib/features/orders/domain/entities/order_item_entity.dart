import 'package:freezed_annotation/freezed_annotation.dart';

part 'order_item_entity.freezed.dart';

/// Backend `ListingAttribute { key, value }` snapshotted on an order line.
typedef OrderItemAttribute = ({String key, String value});

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
    @Default(<OrderItemAttribute>[]) List<OrderItemAttribute> attributes,
  }) = _OrderItemEntity;
}
