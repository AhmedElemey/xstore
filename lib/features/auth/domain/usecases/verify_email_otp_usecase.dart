import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failures.dart';
import '../repositories/auth_repository.dart';

class VerifyEmailOtpUseCase {
  const VerifyEmailOtpUseCase(this._repository);

  final AuthRepository _repository;

  Future<Either<Failure, Unit>> call(String otpToken) {
    return _repository.verifyEmailOtp(otpToken);
  }
}
