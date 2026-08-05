import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failures.dart';
import '../repositories/auth_repository.dart';

class VerifyEmailOtpUseCase {
  const VerifyEmailOtpUseCase(this._repository);

  final AuthRepository _repository;

  Future<Either<Failure, Unit>> call({
    required String email,
    required String otpToken,
  }) {
    return _repository.verifyEmailOtp(email: email, otpToken: otpToken);
  }
}
