import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failures.dart';
import '../repositories/wishlist_repository.dart';

class ClearWishlistUseCase {
  const ClearWishlistUseCase(this._repository);

  final WishlistRepository _repository;

  Future<Either<Failure, Unit>> call(String consumerId) {
    return _repository.clearWishlist(consumerId);
  }
}
