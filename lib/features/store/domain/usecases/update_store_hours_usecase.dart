import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failures.dart';
import '../entities/store_hours_entity.dart';
import '../repositories/store_hours_repository.dart';

class UpdateStoreHoursUseCase {
  const UpdateStoreHoursUseCase(this._repo);

  final StoreHoursRepository _repo;

  Future<Either<Failure, StoreHoursEntity>> call(StoreHoursEntity hours) {
    return _repo.updateStoreHours(hours);
  }
}

