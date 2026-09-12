import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failures.dart';
import '../entities/user_entity.dart';
import '../repositories/auth_repository.dart';

/// Read-only lookup — does NOT create an account. Lets the caller skip the
/// buyer/seller picker and call [GoogleLoginUseCase] directly with the
/// returned role when the Google identity already has an account.
class CheckGoogleUserUseCase {
  const CheckGoogleUserUseCase(this._repository);

  final AuthRepository _repository;

  Future<Either<Failure, ({bool exists, UserRole? role})>> call({
    required String idToken,
  }) {
    return _repository.checkGoogleUser(idToken: idToken);
  }
}
