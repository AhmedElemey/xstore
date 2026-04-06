import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failures.dart';
import '../entities/login_params.dart';
import '../entities/register_params.dart';
import '../entities/send_otp_params.dart';
import '../entities/send_otp_result.dart';
import '../entities/social_auth_result.dart';
import '../entities/user_entity.dart';
import '../entities/verify_otp_params.dart';

abstract interface class AuthRepository {
  Future<Either<Failure, UserEntity?>> restoreSession();

  Future<Either<Failure, UserEntity>> login(LoginParams params);

  Future<Either<Failure, UserEntity>> register(RegisterParams params);

  Future<Either<Failure, SocialAuthResult>> signInWithGoogle();
  Future<Either<Failure, SocialAuthResult>> signInWithApple();
  Future<Either<Failure, SocialAuthResult>> signInWithFacebook();
  Future<Either<Failure, Unit>> signOutSocial();
  Future<Either<Failure, SendOtpResult>> sendOtp(SendOtpParams params);
  Future<Either<Failure, UserEntity>> verifyOtp(VerifyOtpParams params);

  Future<Either<Failure, Unit>> logout();

  /// Writes the current session user JSON (keeps existing auth token if set).
  Future<Either<Failure, Unit>> persistSessionUser(UserEntity user);
}
