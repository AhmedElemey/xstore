import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failures.dart';
import '../repositories/auth_repository.dart';

class SendEmailOtpUseCase {
  const SendEmailOtpUseCase(this._repository);

  final AuthRepository _repository;

  Future<Either<Failure, String?>> call(String email) {
    return _repository.sendEmailOtp(email);
  }
}
