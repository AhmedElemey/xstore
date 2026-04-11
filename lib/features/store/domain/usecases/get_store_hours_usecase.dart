import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failures.dart';
import '../entities/store_hours_entity.dart';
import '../repositories/store_hours_repository.dart';

class GetStoreHoursUseCase {
  const GetStoreHoursUseCase(this._repo);

  final StoreHoursRepository _repo;

  Future<Either<Failure, StoreHoursEntity>> call(String vendorId) {
    return _repo.getStoreHours(vendorId);
  }
}

