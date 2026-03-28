import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failures.dart';
import '../entities/order_entity.dart';
import '../repositories/orders_repository.dart';

class GetOrderDetailUseCase {
  const GetOrderDetailUseCase(this._repository);

  final OrdersRepository _repository;

  Future<Either<Failure, OrderEntity>> call({
    required String orderId,
    required String? consumerId,
    required String? vendorId,
    required bool isVendorSession,
  }) {
    return _repository.getOrderDetail(
      orderId: orderId,
      consumerId: consumerId,
      vendorId: vendorId,
      isVendorSession: isVendorSession,
    );
  }
}
