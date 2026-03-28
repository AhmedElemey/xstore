import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failures.dart';
import '../entities/wishlist_item_entity.dart';
import '../repositories/wishlist_repository.dart';

class AddToWishlistUseCase {
  const AddToWishlistUseCase(this._repository);

  final WishlistRepository _repository;

  Future<Either<Failure, WishlistItemEntity>> call({
    required String consumerId,
    required String listingId,
  }) {
    return _repository.addToWishlist(consumerId: consumerId, listingId: listingId);
  }
}
