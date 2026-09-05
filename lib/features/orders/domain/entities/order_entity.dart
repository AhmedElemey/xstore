import 'package:freezed_annotation/freezed_annotation.dart';

import 'order_item_entity.dart';

part 'order_entity.freezed.dart';

/// C# `OrderStatus { Pending=0, Confirmed=1, Processing=2, Shipped=3,
/// Delivered=4, Cancelled=5 }`. Unlike listing condition, **0 is a real
/// member** (Pending), not "unset".
enum OrderStatus {
  pending,
  confirmed,
  processing,
  shipped,
  delivered,
  cancelled,
}

int orderStatusToWire(OrderStatus status) => switch (status) {
      OrderStatus.pending => 0,
      OrderStatus.confirmed => 1,
      OrderStatus.processing => 2,
      OrderStatus.shipped => 3,
      OrderStatus.delivered => 4,
      OrderStatus.cancelled => 5,
    };

/// Parses the C# numeric code, a numeric string, or a name (`pending`,
/// `Pending`). `rejected` is treated as cancelled. Unknown values are null.
OrderStatus? orderStatusFromWire(Object? raw) {
  if (raw == null) return null;
  if (raw is num) return _orderStatusFromCode(raw.toInt());
  final s = raw.toString().trim();
  if (s.isEmpty) return null;
  final asInt = int.tryParse(s);
  if (asInt != null) return _orderStatusFromCode(asInt);
  return switch (s.toLowerCase()) {
    'pending' => OrderStatus.pending,
    'confirmed' => OrderStatus.confirmed,
    'processing' => OrderStatus.processing,
    'shipped' => OrderStatus.shipped,
    'delivered' => OrderStatus.delivered,
    'cancelled' || 'rejected' => OrderStatus.cancelled,
    _ => null,
  };
}

OrderStatus? _orderStatusFromCode(int code) => switch (code) {
      0 => OrderStatus.pending,
      1 => OrderStatus.confirmed,
      2 => OrderStatus.processing,
      3 => OrderStatus.shipped,
      4 => OrderStatus.delivered,
      5 => OrderStatus.cancelled,
      _ => null,
    };

enum PaymentMethod {
  cashOnDelivery,
  cibCard,
  dahabiCard,
  baridimob,
}

/// How the vendor chose to fulfil an accepted order. Null while `pending`.
/// Self = vendor delivers and keeps the shipping fee as their own
/// compensation; platform = queued for admin to assign a courier, who
/// collects the fee as part of the COD total on the platform's behalf. The
/// fee itself is fixed at checkout ([OrderEntity.shippingCost]) — this only
/// decides who ends up collecting it.
enum DeliveryMethod {
  self,
  platform,
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
    // Platform commission config + wallet-alert flags, echoed on the
    // GET /vendor/orders envelope (CONFIRMED against backend source
    // 2026-08-15 — the admin-only /api/admin/system-settings endpoint that
    // owns these values has no vendor-accessible equivalent). Null in mock
    // mode / on fetch failure — callers fall back to the starter constants
    // in commission_config_provider.dart.
    double? commissionValueOnOrder,
    double? warnThresholdEgp,
    double? pauseThresholdEgp,
    @Default(false) bool exceedsWarnThreshold,
    @Default(false) bool exceedsPauseThreshold,
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
    double? vendorRating,
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
    /// Set when the vendor accepts (pending → confirmed). See [DeliveryMethod].
    DeliveryMethod? deliveryMethod,
    /// Platform courier assigned to deliver this order ("Delivered by
    /// xStore"). Null = vendor self-delivery (default flow).
    String? courierId,
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

  /// Mutation responses (cancel 2xx with no order body) omit line items.
  /// Keep the snapshot the UI already has and only take status fields.
  OrderEntity takingStatusFrom(OrderEntity incoming) {
    if (incoming.items.isNotEmpty || items.isEmpty) return incoming;
    return copyWith(
      status: incoming.status,
      cancelReason: incoming.cancelReason ?? cancelReason,
      cancelledAt: incoming.cancelledAt ?? cancelledAt,
      updatedAt: incoming.updatedAt,
      confirmedAt: incoming.confirmedAt ?? confirmedAt,
      shippedAt: incoming.shippedAt ?? shippedAt,
      deliveredAt: incoming.deliveredAt ?? deliveredAt,
      deliveryMethod: incoming.deliveryMethod ?? deliveryMethod,
      trackingNumber: incoming.trackingNumber ?? trackingNumber,
      courierName: incoming.courierName ?? courierName,
      estimatedDelivery: incoming.estimatedDelivery ?? estimatedDelivery,
    );
  }
}
