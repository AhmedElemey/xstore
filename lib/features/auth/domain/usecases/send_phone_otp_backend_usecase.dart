import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failures.dart';
import '../repositories/auth_repository.dart';

/// Server-driven phone OTP (`/api/auth/send-phone-otp`) — distinct from the
/// existing Firebase-based phone auth flow (`sendOtp`/`PhoneAuthDatasource`).
/// Not wired into any screen yet; see auth_repository.dart for context.
class SendPhoneOtpBackendUseCase {
  const SendPhoneOtpBackendUseCase(this._repository);

  final AuthRepository _repository;

  Future<Either<Failure, String?>> call(String phoneNumber) {
    return _repository.sendPhoneOtpBackend(phoneNumber);
  }
}
