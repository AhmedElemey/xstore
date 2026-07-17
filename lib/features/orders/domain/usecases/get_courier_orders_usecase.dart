import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failures.dart';
import '../entities/order_entity.dart';
import '../repositories/orders_repository.dart';

class GetCourierOrdersUseCase {
  const GetCourierOrdersUseCase(this._repository);

  final OrdersRepository _repository;

  Future<Either<Failure, List<OrderEntity>>> call({
    required String courierId,
    required int page,
    required int pageSize,
  }) {
    return _repository.getCourierOrders(
      courierId: courierId,
      page: page,
      pageSize: pageSize,
    );
  }
}
