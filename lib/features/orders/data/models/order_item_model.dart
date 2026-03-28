import 'package:freezed_annotation/freezed_annotation.dart';

import '../../domain/entities/order_item_entity.dart';

part 'order_item_model.freezed.dart';

@freezed
class OrderItemModel with _$OrderItemModel {
  const factory OrderItemModel({
    required String id,
    required String listingId,
    required String listingName,
    required String listingImage,
    required String category,
    required String condition,
    required double price,
    required int quantity,
    required double total,
  }) = _OrderItemModel;
}

extension OrderItemModelX on OrderItemModel {
  OrderItemEntity toEntity() => OrderItemEntity(
        id: id,
        listingId: listingId,
        listingName: listingName,
        listingImage: listingImage,
        category: category,
        condition: condition,
        price: price,
        quantity: quantity,
        total: total,
      );

  static OrderItemModel fromEntity(OrderItemEntity e) => OrderItemModel(
        id: e.id,
        listingId: e.listingId,
        listingName: e.listingName,
        listingImage: e.listingImage,
        category: e.category,
        condition: e.condition,
        price: e.price,
        quantity: e.quantity,
        total: e.total,
      );
}
