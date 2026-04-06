import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failures.dart';
import '../entities/user_entity.dart';
import '../entities/verify_otp_params.dart';
import '../repositories/auth_repository.dart';

class VerifyOtpUseCase {
  const VerifyOtpUseCase(this._repository);

  final AuthRepository _repository;

  Future<Either<Failure, UserEntity>> call(VerifyOtpParams params) {
    return _repository.verifyOtp(params);
  }
}
