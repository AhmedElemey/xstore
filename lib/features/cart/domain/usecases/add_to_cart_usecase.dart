import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failures.dart';
import '../entities/cart_entity.dart';
import '../repositories/cart_repository.dart';

class AddToCartUseCase {
  const AddToCartUseCase(this._repository);

  final CartRepository _repository;

  Future<Either<Failure, CartEntity>> call({
    required String consumerId,
    required String listingId,
    required int quantity,
  }) {
    return _repository.addFromListing(
      consumerId: consumerId,
      listingId: listingId,
      quantity: quantity,
    );
  }
}
