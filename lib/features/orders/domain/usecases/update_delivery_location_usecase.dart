import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failures.dart';
import '../repositories/orders_repository.dart';

class UpdateDeliveryLocationUseCase {
  const UpdateDeliveryLocationUseCase(this._repository);

  final OrdersRepository _repository;

  Future<Either<Failure, Unit>> call({
    required String orderId,
    required double latitude,
    required double longitude,
  }) {
    return _repository.updateDeliveryLocation(
      orderId: orderId,
      latitude: latitude,
      longitude: longitude,
    );
  }
}
