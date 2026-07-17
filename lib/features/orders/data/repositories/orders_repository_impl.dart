import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failures.dart';
import '../../domain/entities/order_entity.dart';
import '../../domain/repositories/orders_repository.dart';
import '../datasources/orders_remote_datasource.dart';
import '../models/order_model.dart';

class OrdersRepositoryImpl implements OrdersRepository {
  OrdersRepositoryImpl(this._remote);

  final OrdersRemoteDataSource _remote;

  @override
  Future<Either<Failure, List<OrderEntity>>> getConsumerOrders({
    required String consumerId,
    required int page,
    required int pageSize,
  }) async {
    try {
      final rows = await _remote.getConsumerOrders(
        consumerId: consumerId,
        page: page,
        pageSize: pageSize,
      );
      return Right(rows.map((e) => e.toEntity()).toList());
    } catch (e) {
      return Left(Failure.server(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<OrderEntity>>> getVendorOrders({
    required String vendorId,
    required int page,
    required int pageSize,
  }) async {
    try {
      final rows = await _remote.getVendorOrders(
        vendorId: vendorId,
        page: page,
        pageSize: pageSize,
      );
      return Right(rows.map((e) => e.toEntity()).toList());
    } catch (e) {
      return Left(Failure.server(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<OrderEntity>>> getCourierOrders({
    required String courierId,
    required int page,
    required int pageSize,
  }) async {
    try {
      final rows = await _remote.getCourierOrders(
        courierId: courierId,
        page: page,
        pageSize: pageSize,
      );
      return Right(rows.map((e) => e.toEntity()).toList());
    } catch (e) {
      return Left(Failure.server(e.toString()));
    }
  }

  @override
  Future<Either<Failure, OrderEntity>> getOrderDetail({
    required String orderId,
    required String? consumerId,
    required String? vendorId,
    required bool isVendorSession,
  }) async {
    try {
      final row = await _remote.getOrderById(orderId);
      if (row == null) return Left(Failure.notFound('Order'));
      final e = row.toEntity();
      if (isVendorSession) {
        if (e.vendorId != vendorId) return Left(Failure.unauthorized());
      } else {
        if (e.consumerId != consumerId) return Left(Failure.unauthorized());
      }
      return Right(e);
    } catch (e) {
      return Left(Failure.server(e.toString()));
    }
  }

  @override
  Future<Either<Failure, OrderStatsEntity>> getVendorOrderStats({
    required String vendorId,
  }) async {
    try {
      return Right(await _remote.getVendorOrderStats(vendorId: vendorId));
    } catch (e) {
      return Left(Failure.server(e.toString()));
    }
  }

  @override
  Future<Either<Failure, OrderEntity>> cancelOrder({
    required String orderId,
    required String reason,
    required bool isVendorSession,
  }) async {
    try {
      final row = await _remote.cancelOrder(
        orderId: orderId,
        reason: reason,
        isVendorSession: isVendorSession,
      );
      return Right(row.toEntity());
    } catch (e) {
      return Left(Failure.server(e.toString()));
    }
  }

  @override
  Future<Either<Failure, OrderEntity>> confirmOrder(String orderId) async {
    try {
      final row = await _remote.confirmOrder(orderId);
      return Right(row.toEntity());
    } catch (e) {
      return Left(Failure.server(e.toString()));
    }
  }

  @override
  Future<Either<Failure, OrderEntity>> rejectOrder({
    required String orderId,
    required String reason,
  }) async {
    try {
      final row = await _remote.rejectOrder(orderId: orderId, reason: reason);
      return Right(row.toEntity());
    } catch (e) {
      return Left(Failure.server(e.toString()));
    }
  }

  @override
  Future<Either<Failure, OrderEntity>> markProcessing(String orderId) async {
    try {
      final row = await _remote.markProcessing(orderId);
      return Right(row.toEntity());
    } catch (e) {
      return Left(Failure.server(e.toString()));
    }
  }

  @override
  Future<Either<Failure, OrderEntity>> markShipped({
    required String orderId,
    required ShippingInfo shippingInfo,
  }) async {
    try {
      final row = await _remote.markShipped(
        orderId: orderId,
        shippingInfo: shippingInfo,
      );
      return Right(row.toEntity());
    } catch (e) {
      return Left(Failure.server(e.toString()));
    }
  }

  @override
  Future<Either<Failure, OrderEntity>> markDelivered(String orderId) async {
    try {
      final row = await _remote.markDelivered(orderId);
      return Right(row.toEntity());
    } catch (e) {
      return Left(Failure.server(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Unit>> registerCheckoutOrder(OrderEntity order) async {
    try {
      await _remote.registerPlacedConsumerOrder(OrderModelX.fromEntity(order));
      return const Right(unit);
    } catch (e) {
      return Left(Failure.server(e.toString()));
    }
  }
}
