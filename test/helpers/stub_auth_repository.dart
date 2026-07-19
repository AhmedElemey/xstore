import 'package:fpdart/fpdart.dart';
import 'package:xstore/core/error/failures.dart';
import 'package:xstore/features/auth/domain/entities/auth_token_pair.dart';
import 'package:xstore/features/auth/domain/entities/consumer_register_params.dart';
import 'package:xstore/features/auth/domain/entities/login_params.dart';
import 'package:xstore/features/auth/domain/entities/register_params.dart';
import 'package:xstore/features/auth/domain/entities/send_otp_params.dart';
import 'package:xstore/features/auth/domain/entities/send_otp_result.dart';
import 'package:xstore/features/auth/domain/entities/social_auth_result.dart';
import 'package:xstore/features/auth/domain/entities/user_entity.dart';
import 'package:xstore/features/auth/domain/entities/vendor_register_params.dart';
import 'package:xstore/features/auth/domain/entities/verify_otp_params.dart';
import 'package:xstore/features/auth/domain/repositories/auth_repository.dart';

class StubAuthRepository implements AuthRepository {
  StubAuthRepository({
    this.restoreUser,
    Either<Failure, UserEntity>? loginResult,
    Either<Failure, UserEntity>? registerResult,
    Either<Failure, UserEntity>? registerConsumerResult,
    Either<Failure, UserEntity>? registerVendorResult,
    Either<Failure, Unit>? changePasswordResult,
    Either<Failure, String?>? forgotPasswordResult,
    Either<Failure, Unit>? verifyForgotPasswordOtpResult,
    Either<Failure, AuthTokenPair>? refreshTokenResult,
  })  : _loginResult = loginResult ?? Left(Failure.server('stub login')),
        _registerResult =
            registerResult ?? Left(Failure.server('stub register')),
        _registerConsumerResult = registerConsumerResult ??
            Left(Failure.server('stub register consumer')),
        _registerVendorResult = registerVendorResult ??
            Left(Failure.server('stub register vendor')),
        _changePasswordResult = changePasswordResult ??
            Left(Failure.server('stub change password')),
        _forgotPasswordResult = forgotPasswordResult ??
            Left(Failure.server('stub forgot password')),
        _verifyForgotPasswordOtpResult = verifyForgotPasswordOtpResult ??
            Left(Failure.server('stub verify forgot password otp')),
        _refreshTokenResult = refreshTokenResult ??
            Left(Failure.server('stub refresh token'));

  final UserEntity? restoreUser;
  final Either<Failure, UserEntity> _loginResult;
  final Either<Failure, UserEntity> _registerResult;
  final Either<Failure, UserEntity> _registerConsumerResult;
  final Either<Failure, UserEntity> _registerVendorResult;
  final Either<Failure, Unit> _changePasswordResult;
  final Either<Failure, String?> _forgotPasswordResult;
  final Either<Failure, Unit> _verifyForgotPasswordOtpResult;
  final Either<Failure, AuthTokenPair> _refreshTokenResult;

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
  Future<Either<Failure, UserEntity>> registerConsumer(
    ConsumerRegisterParams params,
  ) async =>
      _registerConsumerResult;

  @override
  Future<Either<Failure, UserEntity>> registerVendor(
    VendorRegisterParams params,
  ) async =>
      _registerVendorResult;

  @override
  Future<Either<Failure, Unit>> changePassword({
    required String currentPassword,
    required String newPassword,
    required String confirmNewPassword,
  }) async =>
      _changePasswordResult;

  @override
  Future<Either<Failure, String?>> forgotPassword(String email) async =>
      _forgotPasswordResult;

  @override
  Future<Either<Failure, Unit>> verifyForgotPasswordOtp({
    required String email,
    required String otpToken,
    required String newPassword,
    required String confirmNewPassword,
  }) async =>
      _verifyForgotPasswordOtpResult;

  @override
  Future<Either<Failure, AuthTokenPair>> refreshToken(String token) async =>
      _refreshTokenResult;

  @override
  Future<Either<Failure, String?>> sendEmailOtp(String email) async =>
      Left(Failure.server('stub'));

  @override
  Future<Either<Failure, Unit>> verifyEmailOtp(String otpToken) async =>
      Left(Failure.server('stub'));

  @override
  Future<Either<Failure, String?>> sendPhoneOtpBackend(
    String phoneNumber,
  ) async =>
      Left(Failure.server('stub'));

  @override
  Future<Either<Failure, Unit>> verifyPhoneOtpBackend(
    String otpToken,
  ) async =>
      Left(Failure.server('stub'));

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

  @override
  Future<Either<Failure, String?>> sendLoginOtp(String phoneNumber) async =>
      Left(Failure.server('stub'));

  @override
  Future<Either<Failure, UserEntity>> loginWithOtp({
    required String phoneNumber,
    required String otpToken,
  }) async =>
      Left(Failure.server('stub'));

  @override
  Future<Either<Failure, UserEntity>> loginWithGoogle({
    required String idToken,
    required UserRole role,
  }) async =>
      Left(Failure.socialAuth('stub'));
}
