import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failures.dart';
import '../repositories/wishlist_repository.dart';

class RemoveFromWishlistUseCase {
  const RemoveFromWishlistUseCase(this._repository);

  final WishlistRepository _repository;

  Future<Either<Failure, Unit>> call({
    required String consumerId,
    required String listingId,
  }) {
    return _repository.removeFromWishlist(
      consumerId: consumerId,
      listingId: listingId,
    );
  }
}
