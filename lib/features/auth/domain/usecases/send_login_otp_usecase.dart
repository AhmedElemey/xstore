import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failures.dart';
import '../repositories/auth_repository.dart';

/// Requests a passwordless-login SMS OTP for an existing account. Right payload
/// is the debug OTP echoed by the backend, if present.
class SendLoginOtpUseCase {
  const SendLoginOtpUseCase(this._repository);

  final AuthRepository _repository;

  Future<Either<Failure, String?>> call(String phoneNumber) {
    return _repository.sendLoginOtp(phoneNumber);
  }
}
