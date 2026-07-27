import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failures.dart';
import '../entities/order_entity.dart';

abstract interface class OrdersRepository {
  Future<Either<Failure, List<OrderEntity>>> getConsumerOrders({
    required String consumerId,
    required int page,
    required int pageSize,
  });

  Future<Either<Failure, List<OrderEntity>>> getVendorOrders({
    required String vendorId,
    required int page,
    required int pageSize,
  });

  /// Orders assigned to a platform courier ("Delivered by xStore").
  Future<Either<Failure, List<OrderEntity>>> getCourierOrders({
    required String courierId,
    required int page,
    required int pageSize,
  });

  Future<Either<Failure, OrderEntity>> getOrderDetail({
    required String orderId,
    required String? consumerId,
    required String? vendorId,
    required bool isVendorSession,
  });

  Future<Either<Failure, OrderStatsEntity>> getVendorOrderStats({
    required String vendorId,
  });

  Future<Either<Failure, OrderEntity>> cancelOrder({
    required String orderId,
    required String reason,
    required bool isVendorSession,
  });

  Future<Either<Failure, OrderEntity>> confirmOrder(String orderId);

  Future<Either<Failure, OrderEntity>> rejectOrder({
    required String orderId,
    required String reason,
  });

  Future<Either<Failure, OrderEntity>> markProcessing(String orderId);

  Future<Either<Failure, OrderEntity>> markShipped({
    required String orderId,
    required ShippingInfo shippingInfo,
  });

  Future<Either<Failure, OrderEntity>> markDelivered(String orderId);

  // ---- Courier COD run ----

  /// Courier collected the parcel from the vendor (→ shipped).
  Future<Either<Failure, OrderEntity>> courierPickupOrder(String orderId);

  /// Courier delivered and collected COD (→ delivered).
  Future<Either<Failure, OrderEntity>> courierDeliverOrder(String orderId);

  /// Buyer refused / unreachable (→ cancelled with reason).
  Future<Either<Failure, OrderEntity>> courierFailOrder({
    required String orderId,
    required String reason,
  });

  /// The delivered COD orders the courier still holds cash for (complete set,
  /// not paginated).
  Future<Either<Failure, List<OrderEntity>>> getCourierCashInHandOrders();

  /// Persists a newly placed consumer order (mock checkout).
  Future<Either<Failure, Unit>> registerCheckoutOrder(OrderEntity order);
}
