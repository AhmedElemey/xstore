import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failures.dart';
import '../entities/order_entity.dart';
import '../repositories/orders_repository.dart';

class CancelOrderUseCase {
  const CancelOrderUseCase(this._repository);

  final OrdersRepository _repository;

  Future<Either<Failure, OrderEntity>> call({
    required String orderId,
    required String reason,
    required bool isVendorSession,
  }) {
    return _repository.cancelOrder(
      orderId: orderId,
      reason: reason,
      isVendorSession: isVendorSession,
    );
  }
}
