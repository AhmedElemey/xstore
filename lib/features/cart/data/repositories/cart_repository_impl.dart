import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failures.dart';
import '../../../orders/domain/entities/order_entity.dart';
import '../../../orders/domain/repositories/orders_repository.dart';
import '../../domain/entities/cart_entity.dart';
import '../../domain/entities/cart_item_entity.dart';
import '../../domain/entities/place_order_params.dart';
import '../../domain/repositories/cart_repository.dart';
import '../datasources/cart_remote_datasource.dart';

class CartRepositoryImpl implements CartRepository {
  CartRepositoryImpl(
    this._remote,
    this._ordersRepository,
  );

  final CartRemoteDataSource _remote;
  final OrdersRepository _ordersRepository;

  @override
  Future<Either<Failure, CartEntity>> getCart(String consumerId) async {
    try {
      return Right(await _remote.getCart(consumerId));
    } catch (e) {
      return Left(Failure.server(e.toString()));
    }
  }

  @override
  Future<Either<Failure, CartEntity>> addFromListing({
    required String consumerId,
    required String listingId,
    required int quantity,
  }) async {
    try {
      final line = _remote.buildLineFromListing(listingId, quantity);
      return Right(
        await _remote.addOrUpdateItem(consumerId: consumerId, item: line),
      );
    } catch (e) {
      return Left(Failure.server(e.toString()));
    }
  }

  @override
  Future<Either<Failure, CartEntity>> addOrUpdateItem({
    required String consumerId,
    required CartItemEntity item,
  }) async {
    try {
      return Right(
        await _remote.addOrUpdateItem(consumerId: consumerId, item: item),
      );
    } catch (e) {
      return Left(Failure.server(e.toString()));
    }
  }

  @override
  Future<Either<Failure, CartEntity>> removeItem({
    required String consumerId,
    required String itemId,
  }) async {
    try {
      return Right(await _remote.removeItem(consumerId: consumerId, itemId: itemId));
    } catch (e) {
      return Left(Failure.server(e.toString()));
    }
  }

  @override
  Future<Either<Failure, CartEntity>> updateQuantity({
    required String consumerId,
    required String itemId,
    required int quantity,
  }) async {
    try {
      return Right(
        await _remote.updateQuantity(
          consumerId: consumerId,
          itemId: itemId,
          quantity: quantity,
        ),
      );
    } catch (e) {
      return Left(Failure.server(e.toString()));
    }
  }

  @override
  Future<Either<Failure, CartEntity>> clearCart(String consumerId) async {
    try {
      return Right(await _remote.clearCart(consumerId));
    } catch (e) {
      return Left(Failure.server(e.toString()));
    }
  }

  @override
  Future<Either<Failure, CouponEntity>> applyCoupon({
    required String consumerId,
    required String code,
    required double eligibleSubtotal,
  }) async {
    try {
      return Right(
        await _remote.applyCoupon(
          code: code,
          eligibleSubtotal: eligibleSubtotal,
        ),
      );
    } on CouponException catch (e) {
      return Left(Failure.validation(e.message));
    } catch (e) {
      return Left(Failure.server(e.toString()));
    }
  }

  @override
  Future<Either<Failure, CartEntity>> removeCoupon(String consumerId) async {
    try {
      return Right(await _remote.removeCoupon(consumerId));
    } catch (e) {
      return Left(Failure.server(e.toString()));
    }
  }

  @override
  Future<Either<Failure, OrderEntity>> placeOrder(PlaceOrderParams params) async {
    try {
      final order = await _remote.placeOrder(params);
      final reg = await _ordersRepository.registerCheckoutOrder(order);
      return reg.fold(Left.new, (_) => Right(order));
    } catch (e) {
      return Left(Failure.server(e.toString()));
    }
  }
}
