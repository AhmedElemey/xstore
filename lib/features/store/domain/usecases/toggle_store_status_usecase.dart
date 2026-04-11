import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failures.dart';
import '../repositories/store_hours_repository.dart';

class ToggleStoreStatusUseCase {
  const ToggleStoreStatusUseCase(this._repo);

  final StoreHoursRepository _repo;

  Future<Either<Failure, bool>> call({
    required String vendorId,
    required bool isOpen,
  }) {
    return _repo.toggleStoreStatus(vendorId, isOpen);
  }
}

