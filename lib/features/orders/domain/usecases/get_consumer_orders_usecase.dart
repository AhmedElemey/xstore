import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failures.dart';
import '../entities/order_entity.dart';
import '../repositories/orders_repository.dart';

class GetConsumerOrdersUseCase {
  const GetConsumerOrdersUseCase(this._repository);

  final OrdersRepository _repository;

  Future<Either<Failure, List<OrderEntity>>> call({
    required String consumerId,
    required int page,
    required int pageSize,
  }) {
    return _repository.getConsumerOrders(
      consumerId: consumerId,
      page: page,
      pageSize: pageSize,
    );
  }
}
