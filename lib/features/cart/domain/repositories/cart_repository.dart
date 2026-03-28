import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failures.dart';
import '../../../orders/domain/entities/order_entity.dart';
import '../entities/cart_entity.dart';
import '../entities/cart_item_entity.dart';
import '../entities/place_order_params.dart';

abstract interface class CartRepository {
  Future<Either<Failure, CartEntity>> getCart(String consumerId);

  Future<Either<Failure, CartEntity>> addFromListing({
    required String consumerId,
    required String listingId,
    required int quantity,
  });

  Future<Either<Failure, CartEntity>> addOrUpdateItem({
    required String consumerId,
    required CartItemEntity item,
  });

  Future<Either<Failure, CartEntity>> removeItem({
    required String consumerId,
    required String itemId,
  });

  Future<Either<Failure, CartEntity>> updateQuantity({
    required String consumerId,
    required String itemId,
    required int quantity,
  });

  Future<Either<Failure, CartEntity>> clearCart(String consumerId);

  Future<Either<Failure, CouponEntity>> applyCoupon({
    required String consumerId,
    required String code,
    required double eligibleSubtotal,
  });

  Future<Either<Failure, CartEntity>> removeCoupon(String consumerId);

  Future<Either<Failure, OrderEntity>> placeOrder(PlaceOrderParams params);
}
