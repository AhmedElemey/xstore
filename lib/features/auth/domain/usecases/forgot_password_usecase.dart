import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failures.dart';
import '../repositories/auth_repository.dart';

class ForgotPasswordUseCase {
  const ForgotPasswordUseCase(this._repository);

  final AuthRepository _repository;

  Future<Either<Failure, String?>> call(String email) {
    return _repository.forgotPassword(email);
  }
}
