import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failures.dart';
import '../../../auth/domain/entities/user_entity.dart';
import '../entities/update_profile_request.dart';
import '../repositories/profile_repository.dart';

class UpdateProfileUseCase {
  UpdateProfileUseCase(this._repository);

  final ProfileRepository _repository;

  Future<Either<Failure, UserEntity>> call(
    UpdateProfileRequest request, {
    required UserEntity sessionUser,
  }) {
    return _repository.updateProfile(request, sessionUser: sessionUser);
  }
}
