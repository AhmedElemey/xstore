import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failures.dart';
import '../repositories/wishlist_repository.dart';

class MoveToCartUseCase {
  const MoveToCartUseCase(this._repository);

  final WishlistRepository _repository;

  Future<Either<Failure, Unit>> call({
    required String consumerId,
    required String listingId,
    int quantity = 1,
  }) {
    return _repository.moveListingToCart(
      consumerId: consumerId,
      listingId: listingId,
      quantity: quantity,
    );
  }
}
