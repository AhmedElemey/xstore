import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failures.dart';
import '../entities/cart_entity.dart';
import '../repositories/cart_repository.dart';

class UpdateQuantityUseCase {
  const UpdateQuantityUseCase(this._repository);

  final CartRepository _repository;

  Future<Either<Failure, CartEntity>> call({
    required String consumerId,
    required String itemId,
    required int quantity,
  }) {
    return _repository.updateQuantity(
      consumerId: consumerId,
      itemId: itemId,
      quantity: quantity,
    );
  }
}
