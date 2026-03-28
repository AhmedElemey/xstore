import 'package:freezed_annotation/freezed_annotation.dart';

import '../../domain/entities/order_entity.dart';
import 'order_item_model.dart';

part 'order_model.freezed.dart';

@freezed
class OrderAddressModel with _$OrderAddressModel {
  const factory OrderAddressModel({
    required String fullName,
    required String phone,
    required String street,
    required String city,
    required String wilaya,
    String? postalCode,
    @Default(false) bool isDefault,
  }) = _OrderAddressModel;
}

@freezed
class OrderModel with _$OrderModel {
  const factory OrderModel({
    required String id,
    required String consumerId,
    required String consumerName,
    required String consumerPhone,
    @Default('') String consumerAvatar,
    required String vendorId,
    required String vendorName,
    required String vendorStoreName,
    @Default('') String vendorAvatar,
    @Default(4.8) double vendorRating,
    required List<OrderItemModel> items,
    required OrderStatus status,
    required PaymentMethod paymentMethod,
    @Default(false) bool isPaid,
    required OrderAddressModel deliveryAddress,
    required double subtotal,
    required double shippingCost,
    required double discount,
    required double total,
    String? trackingNumber,
    String? courierName,
    String? trackingLocation,
    DateTime? estimatedDelivery,
    String? cancelReason,
    String? notes,
    required DateTime createdAt,
    required DateTime updatedAt,
    DateTime? confirmedAt,
    DateTime? shippedAt,
    DateTime? deliveredAt,
    DateTime? cancelledAt,
  }) = _OrderModel;
}

extension OrderAddressModelX on OrderAddressModel {
  OrderAddress toEntity() => OrderAddress(
        fullName: fullName,
        phone: phone,
        street: street,
        city: city,
        wilaya: wilaya,
        postalCode: postalCode,
        isDefault: isDefault,
      );

  static OrderAddressModel fromEntity(OrderAddress e) => OrderAddressModel(
        fullName: e.fullName,
        phone: e.phone,
        street: e.street,
        city: e.city,
        wilaya: e.wilaya,
        postalCode: e.postalCode,
        isDefault: e.isDefault,
      );
}

extension OrderModelX on OrderModel {
  OrderEntity toEntity() => OrderEntity(
        id: id,
        consumerId: consumerId,
        consumerName: consumerName,
        consumerPhone: consumerPhone,
        consumerAvatar: consumerAvatar,
        vendorId: vendorId,
        vendorName: vendorName,
        vendorStoreName: vendorStoreName,
        vendorAvatar: vendorAvatar,
        vendorRating: vendorRating,
        items: items.map((e) => e.toEntity()).toList(),
        status: status,
        paymentMethod: paymentMethod,
        isPaid: isPaid,
        deliveryAddress: deliveryAddress.toEntity(),
        subtotal: subtotal,
        shippingCost: shippingCost,
        discount: discount,
        total: total,
        trackingNumber: trackingNumber,
        courierName: courierName,
        trackingLocation: trackingLocation,
        estimatedDelivery: estimatedDelivery,
        cancelReason: cancelReason,
        notes: notes,
        createdAt: createdAt,
        updatedAt: updatedAt,
        confirmedAt: confirmedAt,
        shippedAt: shippedAt,
        deliveredAt: deliveredAt,
        cancelledAt: cancelledAt,
      );

  static OrderModel fromEntity(OrderEntity e) => OrderModel(
        id: e.id,
        consumerId: e.consumerId,
        consumerName: e.consumerName,
        consumerPhone: e.consumerPhone,
        consumerAvatar: e.consumerAvatar,
        vendorId: e.vendorId,
        vendorName: e.vendorName,
        vendorStoreName: e.vendorStoreName,
        vendorAvatar: e.vendorAvatar,
        vendorRating: e.vendorRating,
        items: e.items.map(OrderItemModelX.fromEntity).toList(),
        status: e.status,
        paymentMethod: e.paymentMethod,
        isPaid: e.isPaid,
        deliveryAddress: OrderAddressModelX.fromEntity(e.deliveryAddress),
        subtotal: e.subtotal,
        shippingCost: e.shippingCost,
        discount: e.discount,
        total: e.total,
        trackingNumber: e.trackingNumber,
        courierName: e.courierName,
        trackingLocation: e.trackingLocation,
        estimatedDelivery: e.estimatedDelivery,
        cancelReason: e.cancelReason,
        notes: e.notes,
        createdAt: e.createdAt,
        updatedAt: e.updatedAt,
        confirmedAt: e.confirmedAt,
        shippedAt: e.shippedAt,
        deliveredAt: e.deliveredAt,
        cancelledAt: e.cancelledAt,
      );
}
