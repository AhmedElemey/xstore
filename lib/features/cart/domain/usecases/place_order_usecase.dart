import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failures.dart';
import '../../../orders/domain/entities/order_entity.dart';
import '../entities/place_order_params.dart';
import '../repositories/cart_repository.dart';

class PlaceOrderUseCase {
  const PlaceOrderUseCase(this._repository);

  final CartRepository _repository;

  Future<Either<Failure, OrderEntity>> call(PlaceOrderParams params) {
    return _repository.placeOrder(params);
  }
}
