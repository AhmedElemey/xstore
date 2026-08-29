import 'package:xstore/features/cart/data/datasources/cart_remote_datasource.dart';
import 'package:xstore/features/cart/domain/entities/cart_entity.dart';
import 'package:xstore/features/cart/domain/entities/cart_item_entity.dart';
import 'package:xstore/features/cart/domain/entities/place_order_params.dart';
import 'package:xstore/features/orders/domain/entities/order_entity.dart';

/// Fake [CartRemoteDataSource] for [CartRepositoryImpl] tests — same
/// callback-per-method convention as [StubWishlistRemoteDataSource] and
/// [StubCartRepository]: an unstubbed method throws so a test never
/// silently exercises behavior it didn't configure.
class StubCartRemoteDataSource implements CartRemoteDataSource {
  StubCartRemoteDataSource({
    Future<CartEntity> Function(String consumerId)? onGetCart,
    Future<CartEntity> Function({
      required String consumerId,
      required CartItemEntity item,
    })? onAddOrUpdateItem,
    Future<CartEntity> Function({
      required String consumerId,
      required String itemId,
    })? onRemoveItem,
    Future<CartEntity> Function({
      required String consumerId,
      required String itemId,
      required int quantity,
    })? onUpdateQuantity,
    Future<CartEntity> Function(String consumerId)? onClearCart,
    Future<CouponEntity> Function({
      required String code,
      required double eligibleSubtotal,
    })? onApplyCoupon,
    Future<CartEntity> Function(String consumerId)? onRemoveCoupon,
    Future<OrderEntity> Function(PlaceOrderParams params)? onPlaceOrder,
    Future<CartItemEntity> Function(String listingId, int quantity)?
        onBuildLineFromListing,
  })  : _onGetCart = onGetCart,
        _onAddOrUpdateItem = onAddOrUpdateItem,
        _onRemoveItem = onRemoveItem,
        _onUpdateQuantity = onUpdateQuantity,
        _onClearCart = onClearCart,
        _onApplyCoupon = onApplyCoupon,
        _onRemoveCoupon = onRemoveCoupon,
        _onPlaceOrder = onPlaceOrder,
        _onBuildLineFromListing = onBuildLineFromListing;

  final Future<CartEntity> Function(String consumerId)? _onGetCart;
  final Future<CartEntity> Function({
    required String consumerId,
    required CartItemEntity item,
  })? _onAddOrUpdateItem;
  final Future<CartEntity> Function({
    required String consumerId,
    required String itemId,
  })? _onRemoveItem;
  final Future<CartEntity> Function({
    required String consumerId,
    required String itemId,
    required int quantity,
  })? _onUpdateQuantity;
  final Future<CartEntity> Function(String consumerId)? _onClearCart;
  final Future<CouponEntity> Function({
    required String code,
    required double eligibleSubtotal,
  })? _onApplyCoupon;
  final Future<CartEntity> Function(String consumerId)? _onRemoveCoupon;
  final Future<OrderEntity> Function(PlaceOrderParams params)? _onPlaceOrder;
  final Future<CartItemEntity> Function(String listingId, int quantity)?
      _onBuildLineFromListing;

  @override
  Future<CartEntity> getCart(String consumerId) {
    final cb = _onGetCart;
    if (cb == null) throw UnimplementedError('getCart not stubbed');
    return cb(consumerId);
  }

  @override
  Future<CartEntity> addOrUpdateItem({
    required String consumerId,
    required CartItemEntity item,
  }) {
    final cb = _onAddOrUpdateItem;
    if (cb == null) throw UnimplementedError('addOrUpdateItem not stubbed');
    return cb(consumerId: consumerId, item: item);
  }

  @override
  Future<CartEntity> removeItem({
    required String consumerId,
    required String itemId,
  }) {
    final cb = _onRemoveItem;
    if (cb == null) throw UnimplementedError('removeItem not stubbed');
    return cb(consumerId: consumerId, itemId: itemId);
  }

  @override
  Future<CartEntity> updateQuantity({
    required String consumerId,
    required String itemId,
    required int quantity,
  }) {
    final cb = _onUpdateQuantity;
    if (cb == null) throw UnimplementedError('updateQuantity not stubbed');
    return cb(consumerId: consumerId, itemId: itemId, quantity: quantity);
  }

  @override
  Future<CartEntity> clearCart(String consumerId) {
    final cb = _onClearCart;
    if (cb == null) throw UnimplementedError('clearCart not stubbed');
    return cb(consumerId);
  }

  @override
  Future<CouponEntity> applyCoupon({
    required String code,
    required double eligibleSubtotal,
  }) {
    final cb = _onApplyCoupon;
    if (cb == null) throw UnimplementedError('applyCoupon not stubbed');
    return cb(code: code, eligibleSubtotal: eligibleSubtotal);
  }

  @override
  Future<CartEntity> removeCoupon(String consumerId) {
    final cb = _onRemoveCoupon;
    if (cb == null) throw UnimplementedError('removeCoupon not stubbed');
    return cb(consumerId);
  }

  @override
  Future<OrderEntity> placeOrder(PlaceOrderParams params) {
    final cb = _onPlaceOrder;
    if (cb == null) throw UnimplementedError('placeOrder not stubbed');
    return cb(params);
  }

  @override
  Future<CartItemEntity> buildLineFromListing(String listingId, int quantity) {
    final cb = _onBuildLineFromListing;
    if (cb == null) {
      throw UnimplementedError('buildLineFromListing not stubbed');
    }
    return cb(listingId, quantity);
  }
}
