import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failures.dart';
import '../entities/cart_entity.dart';
import '../repositories/cart_repository.dart';

class ApplyCouponUseCase {
  const ApplyCouponUseCase(this._repository);

  final CartRepository _repository;

  Future<Either<Failure, CouponEntity>> call({
    required String consumerId,
    required String code,
    required double eligibleSubtotal,
  }) {
    return _repository.applyCoupon(
      consumerId: consumerId,
      code: code,
      eligibleSubtotal: eligibleSubtotal,
    );
  }
}
