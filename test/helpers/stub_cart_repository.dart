import 'package:fpdart/fpdart.dart';
import 'package:xstore/core/error/failures.dart';
import 'package:xstore/features/cart/domain/entities/cart_entity.dart';
import 'package:xstore/features/cart/domain/entities/cart_item_entity.dart';
import 'package:xstore/features/cart/domain/entities/place_order_params.dart';
import 'package:xstore/features/cart/domain/repositories/cart_repository.dart';
import 'package:xstore/features/orders/domain/entities/order_entity.dart';

CartEntity _stubEmpty(String consumerId) => CartEntity(
      id: 'cart_stub',
      consumerId: consumerId,
      items: const [],
      selectedItemIds: const {},
      subtotal: 0,
      shippingTotal: 0,
      discount: 0,
      total: 0,
    );

class StubCartRepository implements CartRepository {
  StubCartRepository({
    Either<Failure, CartEntity> Function({
      required String consumerId,
      required String listingId,
      required int quantity,
    })? addFromListingResult,
    Either<Failure, OrderEntity> Function(PlaceOrderParams params)? placeOrderResult,
  })  : _addFromListingResult = addFromListingResult ??
            (({
              required String consumerId,
              required String listingId,
              required int quantity,
            }) =>
                Left(Failure.network('stub'))),
        _placeOrderResult =
            placeOrderResult ?? ((_) => Left(Failure.server('stub')));

  final Either<Failure, CartEntity> Function({
    required String consumerId,
    required String listingId,
    required int quantity,
  }) _addFromListingResult;

  final Either<Failure, OrderEntity> Function(PlaceOrderParams params)
      _placeOrderResult;

  @override
  Future<Either<Failure, CartEntity>> getCart(String consumerId) async =>
      Right(_stubEmpty(consumerId));

  @override
  Future<Either<Failure, CartEntity>> addFromListing({
    required String consumerId,
    required String listingId,
    required int quantity,
  }) async =>
      Future.value(_addFromListingResult(
        consumerId: consumerId,
        listingId: listingId,
        quantity: quantity,
      ));

  @override
  Future<Either<Failure, CartEntity>> addOrUpdateItem({
    required String consumerId,
    required CartItemEntity item,
  }) async =>
      Right(_stubEmpty(consumerId));

  @override
  Future<Either<Failure, CartEntity>> removeItem({
    required String consumerId,
    required String itemId,
  }) async =>
      Right(_stubEmpty(consumerId));

  @override
  Future<Either<Failure, CartEntity>> updateQuantity({
    required String consumerId,
    required String itemId,
    required int quantity,
  }) async =>
      Right(_stubEmpty(consumerId));

  @override
  Future<Either<Failure, CartEntity>> clearCart(String consumerId) async =>
      Right(_stubEmpty(consumerId));

  @override
  Future<Either<Failure, CouponEntity>> applyCoupon({
    required String consumerId,
    required String code,
    required double eligibleSubtotal,
  }) async =>
      Left(Failure.validation('stub'));

  @override
  Future<Either<Failure, CartEntity>> removeCoupon(String consumerId) async =>
      Right(_stubEmpty(consumerId));

  @override
  Future<Either<Failure, OrderEntity>> placeOrder(PlaceOrderParams params) async =>
      Future.value(_placeOrderResult(params));
}
