import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failures.dart';
import '../../../auth/domain/entities/user_entity.dart';
import '../entities/profile_entity.dart';
import '../repositories/profile_repository.dart';

class GetProfileUseCase {
  GetProfileUseCase(this._repository);

  final ProfileRepository _repository;

  Future<Either<Failure, ProfileEntity>> call(UserEntity sessionUser) {
    return _repository.getProfile(sessionUser);
  }
}
