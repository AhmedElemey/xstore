import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failures.dart';
import '../entities/order_entity.dart';
import '../repositories/orders_repository.dart';

class RejectOrderUseCase {
  const RejectOrderUseCase(this._repository);

  final OrdersRepository _repository;

  Future<Either<Failure, OrderEntity>> call({
    required String orderId,
    required String reason,
  }) {
    return _repository.rejectOrder(orderId: orderId, reason: reason);
  }
}
