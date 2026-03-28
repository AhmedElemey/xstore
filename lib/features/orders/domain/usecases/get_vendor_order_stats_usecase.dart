import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failures.dart';
import '../entities/order_entity.dart';
import '../repositories/orders_repository.dart';

class GetVendorOrderStatsUseCase {
  const GetVendorOrderStatsUseCase(this._repository);

  final OrdersRepository _repository;

  Future<Either<Failure, OrderStatsEntity>> call(String vendorId) {
    return _repository.getVendorOrderStats(vendorId: vendorId);
  }
}
