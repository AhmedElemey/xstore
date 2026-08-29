import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failures.dart';
import '../repositories/auth_repository.dart';

/// Server-driven phone OTP (`/api/auth/send-phone-otp`) for verifying an
/// already-signed-in user's number. Distinct from passwordless login
/// (`sendLoginOtp` / `loginWithOtp`).
class SendPhoneOtpBackendUseCase {
  const SendPhoneOtpBackendUseCase(this._repository);

  final AuthRepository _repository;

  Future<Either<Failure, String?>> call(String phoneNumber) {
    return _repository.sendPhoneOtpBackend(phoneNumber);
  }
}
