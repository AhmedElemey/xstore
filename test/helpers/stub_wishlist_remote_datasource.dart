import 'package:xstore/features/wishlist/data/datasources/wishlist_remote_datasource.dart';
import 'package:xstore/features/wishlist/domain/entities/wishlist_item_entity.dart';

/// Fake [WishlistRemoteDataSource] for repository tests — no mocking
/// library is used in this repo (see auth_remote_datasource tests), so
/// this mirrors [StubCartRepository]'s pattern: each method is backed by
/// an optional callback, and calling an unstubbed method throws so a test
/// never silently exercises behavior it didn't configure.
class StubWishlistRemoteDataSource implements WishlistRemoteDataSource {
  StubWishlistRemoteDataSource({
    Future<List<WishlistItemEntity>> Function(String consumerId)? onGetWishlist,
    Future<WishlistItemEntity> Function({
      required String consumerId,
      required String listingId,
    })?
    onAddToWishlist,
    Future<void> Function({
      required String consumerId,
      required String listingId,
      String? wishlistItemId,
    })?
    onRemoveFromWishlist,
    Future<void> Function(String consumerId)? onClearWishlist,
    Future<WishlistItemEntity> Function(String listingId, {String? wishId})?
    onBuildFromListingId,
  }) : _onGetWishlist = onGetWishlist,
       _onAddToWishlist = onAddToWishlist,
       _onRemoveFromWishlist = onRemoveFromWishlist,
       _onClearWishlist = onClearWishlist,
       _onBuildFromListingId = onBuildFromListingId;

  final Future<List<WishlistItemEntity>> Function(String consumerId)?
  _onGetWishlist;
  final Future<WishlistItemEntity> Function({
    required String consumerId,
    required String listingId,
  })?
  _onAddToWishlist;
  final Future<void> Function({
    required String consumerId,
    required String listingId,
    String? wishlistItemId,
  })?
  _onRemoveFromWishlist;
  final Future<void> Function(String consumerId)? _onClearWishlist;
  final Future<WishlistItemEntity> Function(String listingId, {String? wishId})?
  _onBuildFromListingId;

  @override
  Future<List<WishlistItemEntity>> getWishlist(String consumerId) {
    final cb = _onGetWishlist;
    if (cb == null) throw UnimplementedError('getWishlist not stubbed');
    return cb(consumerId);
  }

  @override
  Future<WishlistItemEntity> addToWishlist({
    required String consumerId,
    required String listingId,
  }) {
    final cb = _onAddToWishlist;
    if (cb == null) throw UnimplementedError('addToWishlist not stubbed');
    return cb(consumerId: consumerId, listingId: listingId);
  }

  @override
  Future<void> removeFromWishlist({
    required String consumerId,
    required String listingId,
    String? wishlistItemId,
  }) {
    final cb = _onRemoveFromWishlist;
    if (cb == null) throw UnimplementedError('removeFromWishlist not stubbed');
    return cb(
      consumerId: consumerId,
      listingId: listingId,
      wishlistItemId: wishlistItemId,
    );
  }

  @override
  Future<void> clearWishlist(String consumerId) {
    final cb = _onClearWishlist;
    if (cb == null) throw UnimplementedError('clearWishlist not stubbed');
    return cb(consumerId);
  }

  @override
  Future<WishlistItemEntity> buildFromListingId(
    String listingId, {
    String? wishId,
  }) {
    final cb = _onBuildFromListingId;
    if (cb == null) {
      throw UnimplementedError('buildFromListingId not stubbed');
    }
    return cb(listingId, wishId: wishId);
  }
}
