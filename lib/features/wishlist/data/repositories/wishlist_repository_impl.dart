import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failures.dart';
import '../../../cart/domain/repositories/cart_repository.dart';
import '../../domain/entities/wishlist_item_entity.dart';
import '../../domain/repositories/wishlist_repository.dart';
import '../datasources/wishlist_remote_datasource.dart';

class WishlistRepositoryImpl implements WishlistRepository {
  WishlistRepositoryImpl(
    this._remote,
    this._cartRepository,
  );

  final WishlistRemoteDataSource _remote;
  final CartRepository _cartRepository;

  @override
  Future<Either<Failure, List<WishlistItemEntity>>> getWishlist(
    String consumerId,
  ) async {
    try {
      return Right(await _remote.getWishlist(consumerId));
    } catch (e) {
      return Left(Failure.server(e.toString()));
    }
  }

  @override
  Future<Either<Failure, WishlistItemEntity>> addToWishlist({
    required String consumerId,
    required String listingId,
  }) async {
    try {
      return Right(
        await _remote.addToWishlist(
          consumerId: consumerId,
          listingId: listingId,
        ),
      );
    } catch (e) {
      return Left(Failure.server(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Unit>> removeFromWishlist({
    required String consumerId,
    required String listingId,
  }) async {
    try {
      await _remote.removeFromWishlist(
        consumerId: consumerId,
        listingId: listingId,
      );
      return const Right(unit);
    } catch (e) {
      return Left(Failure.server(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Unit>> moveListingToCart({
    required String consumerId,
    required String listingId,
    int quantity = 1,
  }) async {
    try {
      final r = await _cartRepository.addFromListing(
        consumerId: consumerId,
        listingId: listingId,
        quantity: quantity,
      );
      return r.fold(Left.new, (_) => const Right(unit));
    } catch (e) {
      return Left(Failure.server(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Unit>> clearWishlist(String consumerId) async {
    try {
      await _remote.clearWishlist(consumerId);
      return const Right(unit);
    } catch (e) {
      return Left(Failure.server(e.toString()));
    }
  }

  @override
  Future<WishlistItemEntity> stubFromListingId(String listingId) {
    return _remote.buildFromListingId(listingId);
  }
}
