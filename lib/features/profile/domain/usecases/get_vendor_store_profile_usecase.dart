import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failures.dart';
import '../entities/profile_entity.dart';
import '../repositories/profile_repository.dart';

class GetVendorStoreProfileUseCase {
  GetVendorStoreProfileUseCase(this._repository);

  final ProfileRepository _repository;

  Future<Either<Failure, ProfileEntity>> call(String sellerId) {
    return _repository.getVendorStoreProfile(sellerId);
  }
}
