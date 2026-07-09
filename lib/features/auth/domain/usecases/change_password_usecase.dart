import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failures.dart';
import '../repositories/auth_repository.dart';

class ChangePasswordUseCase {
  const ChangePasswordUseCase(this._repository);

  final AuthRepository _repository;

  Future<Either<Failure, Unit>> call({
    required String currentPassword,
    required String newPassword,
    required String confirmNewPassword,
  }) {
    return _repository.changePassword(
      currentPassword: currentPassword,
      newPassword: newPassword,
      confirmNewPassword: confirmNewPassword,
    );
  }
}
