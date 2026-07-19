import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failures.dart';
import '../entities/user_entity.dart';
import '../repositories/auth_repository.dart';

/// Exchanges a login OTP for a session (existing accounts only).
class LoginWithOtpUseCase {
  const LoginWithOtpUseCase(this._repository);

  final AuthRepository _repository;

  Future<Either<Failure, UserEntity>> call({
    required String phoneNumber,
    required String otpToken,
  }) {
    return _repository.loginWithOtp(phoneNumber: phoneNumber, otpToken: otpToken);
  }
}
