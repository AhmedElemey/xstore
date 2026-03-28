import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failures.dart';
import '../entities/order_entity.dart';
import '../repositories/orders_repository.dart';

class GetVendorOrdersUseCase {
  const GetVendorOrdersUseCase(this._repository);

  final OrdersRepository _repository;

  Future<Either<Failure, List<OrderEntity>>> call({
    required String vendorId,
    required int page,
    required int pageSize,
  }) {
    return _repository.getVendorOrders(
      vendorId: vendorId,
      page: page,
      pageSize: pageSize,
    );
  }
}
