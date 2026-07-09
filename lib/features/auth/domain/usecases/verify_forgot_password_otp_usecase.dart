import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failures.dart';
import '../repositories/auth_repository.dart';

class VerifyForgotPasswordOtpUseCase {
  const VerifyForgotPasswordOtpUseCase(this._repository);

  final AuthRepository _repository;

  Future<Either<Failure, Unit>> call({
    required String email,
    required String otpToken,
    required String newPassword,
    required String confirmNewPassword,
  }) {
    return _repository.verifyForgotPasswordOtp(
      email: email,
      otpToken: otpToken,
      newPassword: newPassword,
      confirmNewPassword: confirmNewPassword,
    );
  }
}
