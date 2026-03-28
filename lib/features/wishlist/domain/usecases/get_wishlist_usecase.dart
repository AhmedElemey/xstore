import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failures.dart';
import '../entities/wishlist_item_entity.dart';
import '../repositories/wishlist_repository.dart';

class GetWishlistUseCase {
  const GetWishlistUseCase(this._repository);

  final WishlistRepository _repository;

  Future<Either<Failure, List<WishlistItemEntity>>> call(String consumerId) {
    return _repository.getWishlist(consumerId);
  }
}
