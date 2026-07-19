import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failures.dart';
import '../entities/user_entity.dart';
import '../repositories/auth_repository.dart';

/// Signs in (or auto-registers) with Google via the role-specific backend
/// endpoint, using the Google identity token obtained during sign-in.
class GoogleLoginUseCase {
  const GoogleLoginUseCase(this._repository);

  final AuthRepository _repository;

  Future<Either<Failure, UserEntity>> call({
    required String idToken,
    required UserRole role,
  }) {
    return _repository.loginWithGoogle(idToken: idToken, role: role);
  }
}
