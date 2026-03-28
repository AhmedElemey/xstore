import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failures.dart';
import '../entities/cart_entity.dart';
import '../entities/cart_item_entity.dart';
import '../repositories/cart_repository.dart';

class AddOrUpdateCartItemUseCase {
  const AddOrUpdateCartItemUseCase(this._repository);

  final CartRepository _repository;

  Future<Either<Failure, CartEntity>> call({
    required String consumerId,
    required CartItemEntity item,
  }) {
    return _repository.addOrUpdateItem(consumerId: consumerId, item: item);
  }
}
