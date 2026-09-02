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
      if (isVendorSession) {
        // No confirmed vendor-scoped by-id route exists (only
        // GET /orders/me/{id}, which is consumer-scoped) — find it in the
        // vendor's own order list instead.
        if (vendorId == null) return Left(Failure.unauthorized());
        final rows = await _remote.getVendorOrders(
          vendorId: vendorId,
          page: 1,
          pageSize: 100,
        );
        final row = rows.where((e) => e.id == orderId).firstOrNull;
        if (row == null) return Left(Failure.notFound('Order'));
        return Right(row.toEntity());
      }
      if (consumerId == null || consumerId.isEmpty) {
        return Left(Failure.unauthorized());
      }
      // GET /orders/me/{id} is consumer-scoped but its payload was never
      // live-probed — it may 404, wrap `{data:…}`, or omit consumerId.
      // The orders list already rendered this row; fall back to it.
      OrderModel? row;
      Object? byIdError;
      try {
        row = await _remote.getOrderById(orderId);
      } catch (e) {
        byIdError = e;
      }
      if (row == null) {
        final rows = await _remote.getConsumerOrders(
          consumerId: consumerId,
          page: 1,
          pageSize: 100,
        );
        row = rows.where((e) => e.id == orderId).firstOrNull;
      }
      if (row == null) {
        if (byIdError != null) return Left(Failure.server(byIdError.toString()));
        return Left(Failure.notFound('Order'));
      }
      final e = row.toEntity();
      if (e.consumerId.isNotEmpty && e.consumerId != consumerId) {
        return Left(Failure.unauthorized());
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
  Future<Either<Failure, OrderEntity>> confirmOrder({
    required String orderId,
    required DeliveryMethod method,
  }) async {
    try {
      final row = await _remote.confirmOrder(orderId: orderId, method: method);
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
  Future<Either<Failure, Unit>> updateDeliveryLocation({
    required String orderId,
    required double latitude,
    required double longitude,
  }) async {
    try {
      await _remote.updateDeliveryCoordinates(
        orderId: orderId,
        latitude: latitude,
        longitude: longitude,
      );
      return const Right(unit);
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
