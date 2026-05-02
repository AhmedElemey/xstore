import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failures.dart';
import '../../../cart/domain/entities/cart_item_entity.dart';
import '../entities/wishlist_item_entity.dart';

abstract interface class WishlistRepository {
  Future<Either<Failure, List<WishlistItemEntity>>> getWishlist(String consumerId);

  Future<Either<Failure, WishlistItemEntity>> addToWishlist({
    required String consumerId,
    required String listingId,
  });

  Future<Either<Failure, Unit>> removeFromWishlist({
    required String consumerId,
    required String listingId,
  });

  Future<Either<Failure, Unit>> moveListingToCart({
    required String consumerId,
    required String listingId,
    int quantity,
  });

  Future<Either<Failure, Unit>> clearWishlist(String consumerId);

  /// Build entity from cart line (save for later) without catalog round-trip.
  WishlistItemEntity entityFromCartItem(CartItemEntity item);

  /// Insert or replace by [listingId] (e.g. save for later from cart).
  Future<Either<Failure, WishlistItemEntity>> upsertFromCartItem(
    CartItemEntity item,
  );

  /// Catalog-only preview for optimistic UI (not persisted).
  Future<WishlistItemEntity> stubFromListingId(String listingId);
}
