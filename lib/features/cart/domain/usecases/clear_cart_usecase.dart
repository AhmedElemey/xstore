import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failures.dart';
import '../entities/cart_entity.dart';
import '../repositories/cart_repository.dart';

class ClearCartUseCase {
  const ClearCartUseCase(this._repository);

  final CartRepository _repository;

  Future<Either<Failure, CartEntity>> call(String consumerId) {
    return _repository.clearCart(consumerId);
  }
}
