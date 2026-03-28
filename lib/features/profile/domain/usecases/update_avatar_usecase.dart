import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failures.dart';
import '../repositories/profile_repository.dart';

class UpdateAvatarUseCase {
  UpdateAvatarUseCase(this._repository);

  final ProfileRepository _repository;

  Future<Either<Failure, String>> call({
    required String userId,
    required String filePath,
  }) {
    return _repository.updateAvatar(userId: userId, filePath: filePath);
  }
}
