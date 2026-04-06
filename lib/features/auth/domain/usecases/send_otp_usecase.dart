import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failures.dart';
import '../entities/send_otp_params.dart';
import '../entities/send_otp_result.dart';
import '../repositories/auth_repository.dart';

class SendOtpUseCase {
  const SendOtpUseCase(this._repository);

  final AuthRepository _repository;

  Future<Either<Failure, SendOtpResult>> call(SendOtpParams params) {
    return _repository.sendOtp(params);
  }
}
