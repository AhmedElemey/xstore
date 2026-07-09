import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failures.dart';
import '../repositories/auth_repository.dart';

/// Server-driven phone OTP verification (`/api/auth/verify-phone`) —
/// distinct from the existing Firebase-based phone auth flow. Not wired
/// into any screen yet; see auth_repository.dart for context.
class VerifyPhoneOtpBackendUseCase {
  const VerifyPhoneOtpBackendUseCase(this._repository);

  final AuthRepository _repository;

  Future<Either<Failure, Unit>> call(String otpToken) {
    return _repository.verifyPhoneOtpBackend(otpToken);
  }
}
