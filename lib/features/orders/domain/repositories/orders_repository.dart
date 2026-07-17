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

  /// Persists a newly placed consumer order (mock checkout).
  Future<Either<Failure, Unit>> registerCheckoutOrder(OrderEntity order);
}
