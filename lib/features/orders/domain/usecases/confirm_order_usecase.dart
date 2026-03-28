import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failures.dart';
import '../entities/order_entity.dart';
import '../repositories/orders_repository.dart';

class ConfirmOrderUseCase {
  const ConfirmOrderUseCase(this._repository);

  final OrdersRepository _repository;

  Future<Either<Failure, OrderEntity>> call(String orderId) {
    return _repository.confirmOrder(orderId);
  }
}
