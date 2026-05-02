import 'package:fpdart/fpdart.dart';
import 'package:xstore/core/error/failures.dart';
import 'package:xstore/features/orders/domain/entities/order_entity.dart';
import 'package:xstore/features/orders/domain/repositories/orders_repository.dart';

class StubOrdersRepository implements OrdersRepository {
  StubOrdersRepository({
    FutureOrEitherConsumerOrders? getConsumerOrdersResult,
    FutureOrEitherVendorOrders? getVendorOrdersResult,
    FutureOrEitherOrderStats? getVendorStatsResult,
    Either<Failure, OrderEntity> Function(String orderId)? confirmOrderResult,
  })  : _getConsumer =
            getConsumerOrdersResult ??
                (({required consumerId, required page, required pageSize}) =>
                    Left(Failure.network('stub consumer orders'))),
        _getVendor =
            getVendorOrdersResult ??
                (({required vendorId, required page, required pageSize}) =>
                    Left(Failure.network('stub vendor orders'))),
        _getStats =
            getVendorStatsResult ??
                (({required vendorId}) => Left(Failure.network('stub stats'))),
        _confirm =
            confirmOrderResult ??
                ((_) => Left(Failure.server('stub confirm')));

  final FutureOrEitherConsumerOrders _getConsumer;
  final FutureOrEitherVendorOrders _getVendor;
  final FutureOrEitherOrderStats _getStats;
  final Either<Failure, OrderEntity> Function(String orderId) _confirm;

  @override
  Future<Either<Failure, List<OrderEntity>>> getConsumerOrders({
    required String consumerId,
    required int page,
    required int pageSize,
  }) async =>
      Future.value(_getConsumer(
        consumerId: consumerId,
        page: page,
        pageSize: pageSize,
      ));

  @override
  Future<Either<Failure, List<OrderEntity>>> getVendorOrders({
    required String vendorId,
    required int page,
    required int pageSize,
  }) async =>
      Future.value(_getVendor(
        vendorId: vendorId,
        page: page,
        pageSize: pageSize,
      ));

  @override
  Future<Either<Failure, OrderEntity>> getOrderDetail({
    required String orderId,
    required String? consumerId,
    required String? vendorId,
    required bool isVendorSession,
  }) async =>
      Left(Failure.server('stub detail'));

  @override
  Future<Either<Failure, OrderStatsEntity>> getVendorOrderStats({
    required String vendorId,
  }) async =>
      Future.value(_getStats(vendorId: vendorId));

  @override
  Future<Either<Failure, OrderEntity>> cancelOrder({
    required String orderId,
    required String reason,
    required bool isVendorSession,
  }) async =>
      Left(Failure.server('stub'));

  @override
  Future<Either<Failure, OrderEntity>> confirmOrder(String orderId) async =>
      Future.value(_confirm(orderId));

  @override
  Future<Either<Failure, OrderEntity>> rejectOrder({
    required String orderId,
    required String reason,
  }) async =>
      Left(Failure.server('stub'));

  @override
  Future<Either<Failure, OrderEntity>> markProcessing(String orderId) async =>
      Left(Failure.server('stub'));

  @override
  Future<Either<Failure, OrderEntity>> markShipped({
    required String orderId,
    required ShippingInfo shippingInfo,
  }) async =>
      Left(Failure.server('stub'));

  @override
  Future<Either<Failure, OrderEntity>> markDelivered(String orderId) async =>
      Left(Failure.server('stub'));

  @override
  Future<Either<Failure, Unit>> registerCheckoutOrder(OrderEntity order) async =>
      const Right(unit);
}

typedef FutureOrEitherConsumerOrders = Either<Failure, List<OrderEntity>>
    Function({
  required String consumerId,
  required int page,
  required int pageSize,
});

typedef FutureOrEitherVendorOrders = Either<Failure, List<OrderEntity>>
    Function({
  required String vendorId,
  required int page,
  required int pageSize,
});

typedef FutureOrEitherOrderStats = Either<Failure, OrderStatsEntity>
    Function({required String vendorId});
