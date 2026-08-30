import 'package:fpdart/fpdart.dart';
import 'package:xstore/core/error/failures.dart';
import 'package:xstore/features/orders/domain/entities/order_entity.dart';
import 'package:xstore/features/orders/domain/repositories/orders_repository.dart';

class StubOrdersRepository implements OrdersRepository {
  StubOrdersRepository({
    FutureOrEitherConsumerOrders? getConsumerOrdersResult,
    FutureOrEitherVendorOrders? getVendorOrdersResult,
    FutureOrEitherCourierOrders? getCourierOrdersResult,
    FutureOrEitherOrderStats? getVendorStatsResult,
    Either<Failure, OrderEntity> Function(String orderId, DeliveryMethod method)?
        confirmOrderResult,
    Either<Failure, OrderEntity> Function(String orderId, String reason)?
        rejectOrderResult,
    Either<Failure, OrderEntity> Function(String orderId)? markProcessingResult,
    Either<Failure, OrderEntity> Function(String orderId, ShippingInfo info)?
        markShippedResult,
    Either<Failure, OrderEntity> Function(String orderId)? markDeliveredResult,
  })  : _reject =
            rejectOrderResult ??
                ((_, __) => Left(Failure.server('stub reject'))),
        _markProcessing =
            markProcessingResult ??
                ((_) => Left(Failure.server('stub markProcessing'))),
        _markShipped =
            markShippedResult ??
                ((_, __) => Left(Failure.server('stub markShipped'))),
        _markDelivered =
            markDeliveredResult ??
                ((_) => Left(Failure.server('stub markDelivered'))),
        _getConsumer =
            getConsumerOrdersResult ??
                (({required consumerId, required page, required pageSize}) =>
                    Left(Failure.network('stub consumer orders'))),
        _getVendor =
            getVendorOrdersResult ??
                (({required vendorId, required page, required pageSize}) =>
                    Left(Failure.network('stub vendor orders'))),
        _getCourier =
            getCourierOrdersResult ??
                (({required courierId, required page, required pageSize}) =>
                    Left(Failure.network('stub courier orders'))),
        _getStats =
            getVendorStatsResult ??
                (({required vendorId}) => Left(Failure.network('stub stats'))),
        _confirm =
            confirmOrderResult ??
                ((_, __) => Left(Failure.server('stub confirm')));

  final FutureOrEitherConsumerOrders _getConsumer;
  final FutureOrEitherVendorOrders _getVendor;
  final FutureOrEitherCourierOrders _getCourier;
  final FutureOrEitherOrderStats _getStats;
  final Either<Failure, OrderEntity> Function(String orderId, DeliveryMethod method)
      _confirm;
  final Either<Failure, OrderEntity> Function(String orderId, String reason) _reject;
  final Either<Failure, OrderEntity> Function(String orderId) _markProcessing;
  final Either<Failure, OrderEntity> Function(String orderId, ShippingInfo info)
      _markShipped;
  final Either<Failure, OrderEntity> Function(String orderId) _markDelivered;

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
  Future<Either<Failure, List<OrderEntity>>> getCourierOrders({
    required String courierId,
    required int page,
    required int pageSize,
  }) async =>
      Future.value(_getCourier(
        courierId: courierId,
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
  Future<Either<Failure, OrderEntity>> confirmOrder({
    required String orderId,
    required DeliveryMethod method,
  }) async =>
      Future.value(_confirm(orderId, method));

  @override
  Future<Either<Failure, OrderEntity>> rejectOrder({
    required String orderId,
    required String reason,
  }) async =>
      Future.value(_reject(orderId, reason));

  @override
  Future<Either<Failure, OrderEntity>> markProcessing(String orderId) async =>
      Future.value(_markProcessing(orderId));

  @override
  Future<Either<Failure, OrderEntity>> markShipped({
    required String orderId,
    required ShippingInfo shippingInfo,
  }) async =>
      Future.value(_markShipped(orderId, shippingInfo));

  @override
  Future<Either<Failure, OrderEntity>> markDelivered(String orderId) async =>
      Future.value(_markDelivered(orderId));

  @override
  Future<Either<Failure, Unit>> updateDeliveryLocation({
    required String orderId,
    required double latitude,
    required double longitude,
  }) async =>
      const Right(unit);

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

typedef FutureOrEitherCourierOrders = Either<Failure, List<OrderEntity>>
    Function({
  required String courierId,
  required int page,
  required int pageSize,
});

typedef FutureOrEitherOrderStats = Either<Failure, OrderStatsEntity>
    Function({required String vendorId});
