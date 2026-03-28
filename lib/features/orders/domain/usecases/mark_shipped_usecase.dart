import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failures.dart';
import '../entities/order_entity.dart';
import '../repositories/orders_repository.dart';

class MarkShippedUseCase {
  const MarkShippedUseCase(this._repository);

  final OrdersRepository _repository;

  Future<Either<Failure, OrderEntity>> call({
    required String orderId,
    required ShippingInfo shippingInfo,
  }) {
    return _repository.markShipped(orderId: orderId, shippingInfo: shippingInfo);
  }
}
