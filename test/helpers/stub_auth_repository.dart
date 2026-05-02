import 'package:fpdart/fpdart.dart';
import 'package:xstore/core/error/failures.dart';
import 'package:xstore/features/auth/domain/entities/login_params.dart';
import 'package:xstore/features/auth/domain/entities/register_params.dart';
import 'package:xstore/features/auth/domain/entities/send_otp_params.dart';
import 'package:xstore/features/auth/domain/entities/send_otp_result.dart';
import 'package:xstore/features/auth/domain/entities/social_auth_result.dart';
import 'package:xstore/features/auth/domain/entities/user_entity.dart';
import 'package:xstore/features/auth/domain/entities/verify_otp_params.dart';
import 'package:xstore/features/auth/domain/repositories/auth_repository.dart';

class StubAuthRepository implements AuthRepository {
  StubAuthRepository({
    this.restoreUser,
    Either<Failure, UserEntity>? loginResult,
    Either<Failure, UserEntity>? registerResult,
  })  : _loginResult = loginResult ?? Left(Failure.server('stub login')),
        _registerResult =
            registerResult ?? Left(Failure.server('stub register'));

  final UserEntity? restoreUser;
  final Either<Failure, UserEntity> _loginResult;
  final Either<Failure, UserEntity> _registerResult;

  @override
  Future<Either<Failure, UserEntity?>> restoreSession() async =>
      Right(restoreUser);

  @override
  Future<Either<Failure, UserEntity>> login(LoginParams params) async =>
      _loginResult;

  @override
  Future<Either<Failure, UserEntity>> register(RegisterParams params) async =>
      _registerResult;

  @override
  Future<Either<Failure, Unit>> logout() async => const Right(unit);

  @override
  Future<Either<Failure, Unit>> persistSessionUser(UserEntity user) async =>
      const Right(unit);

  @override
  Future<Either<Failure, SendOtpResult>> sendOtp(SendOtpParams params) async =>
      Left(Failure.phoneAuth('stub'));

  @override
  Future<Either<Failure, SocialAuthResult>> signInWithApple() async =>
      Left(Failure.socialAuth('stub'));

  @override
  Future<Either<Failure, SocialAuthResult>> signInWithFacebook() async =>
      Left(Failure.socialAuth('stub'));

  @override
  Future<Either<Failure, SocialAuthResult>> signInWithGoogle() async =>
      Left(Failure.socialAuth('stub'));

  @override
  Future<Either<Failure, Unit>> signOutSocial() async => const Right(unit);

  @override
  Future<Either<Failure, UserEntity>> verifyOtp(VerifyOtpParams params) async =>
      Left(Failure.phoneAuth('stub'));
}
