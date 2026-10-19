import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failures.dart';
import '../entities/user_entity.dart';
import '../repositories/auth_repository.dart';

/// Logs an existing account in with Google (`/api/auth/google/login`), using
/// the Google identity token obtained during sign-in.
class GoogleLoginUseCase {
  const GoogleLoginUseCase(this._repository);

  final AuthRepository _repository;

  Future<Either<Failure, UserEntity>> call({required String idToken}) {
    return _repository.loginWithGoogle(idToken: idToken);
  }
}
