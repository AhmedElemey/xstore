import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failures.dart';
import '../../../auth/domain/entities/user_entity.dart';
import '../repositories/profile_repository.dart';

class UpdateProfileUseCase {
  UpdateProfileUseCase(this._repository);

  final ProfileRepository _repository;

  Future<Either<Failure, UserEntity>> call(UserEntity updated) {
    return _repository.updateProfile(updated);
  }
}
