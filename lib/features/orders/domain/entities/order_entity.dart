import 'package:freezed_annotation/freezed_annotation.dart';

import 'order_item_entity.dart';

part 'order_entity.freezed.dart';

enum OrderStatus {
  pending,
  confirmed,
  processing,
  shipped,
  delivered,
  cancelled,
  refunded,
}

enum PaymentMethod {
  cashOnDelivery,
  cibCard,
  dahabiCard,
  baridimob,
}

@freezed
class OrderAddress with _$OrderAddress {
  const factory OrderAddress({
    required String fullName,
    required String phone,
    required String street,
    required String city,
    required String wilaya,
    String? postalCode,
    @Default(false) bool isDefault,
  }) = _OrderAddress;
}

@freezed
class ShippingInfo with _$ShippingInfo {
  const factory ShippingInfo({
    String? trackingNumber,
    String? courierName,
    DateTime? estimatedDelivery,
  }) = _ShippingInfo;
}

enum OrderSortOption {
  newest,
  oldest,
  highestValue,
  needsAction,
}

@freezed
class OrderStatsEntity with _$OrderStatsEntity {
  const factory OrderStatsEntity({
    @Default(0) int pendingCount,
    @Default(0) int activeCount,
    @Default(0) int monthCount,
    @Default(0) int totalCount,
    @Default(0.0) double totalRevenue,
  }) = _OrderStatsEntity;
}

@freezed
class OrderEntity with _$OrderEntity {
  const factory OrderEntity({
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
    required List<OrderItemEntity> items,
    required OrderStatus status,
    required PaymentMethod paymentMethod,
    @Default(false) bool isPaid,
    required OrderAddress deliveryAddress,
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
  }) = _OrderEntity;
}

extension OrderEntityX on OrderEntity {
  /// Friendly reference e.g. `XS-2024-001` for mocks.
  String get formattedOrderId {
    if (id.startsWith('order_')) {
      final tail = id.replaceFirst('order_', '');
      final padded = tail.padLeft(3, '0');
      return 'XS-2024-$padded';
    }
    return id;
  }
}
