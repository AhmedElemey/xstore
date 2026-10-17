import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failures.dart';
import '../entities/store_hours_entity.dart';

abstract interface class StoreHoursRepository {
  Future<Either<Failure, StoreHoursEntity>> getStoreHours(String vendorId);
  Future<Either<Failure, StoreHoursEntity>> updateStoreHours(StoreHoursEntity hours);
  Future<Either<Failure, bool>> toggleStoreStatus(String vendorId, bool isOpen);
}

