import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failures.dart';
import '../entities/auth_token_pair.dart';
import '../entities/consumer_register_params.dart';
import '../entities/login_params.dart';
import '../entities/register_params.dart';
import '../entities/send_otp_params.dart';
import '../entities/send_otp_result.dart';
import '../entities/social_auth_result.dart';
import '../entities/user_entity.dart';
import '../entities/vendor_register_params.dart';
import '../entities/verify_otp_params.dart';

abstract interface class AuthRepository {
  Future<Either<Failure, UserEntity?>> restoreSession();

  Future<Either<Failure, UserEntity>> login(LoginParams params);

  Future<Either<Failure, UserEntity>> register(RegisterParams params);

  Future<Either<Failure, UserEntity>> registerConsumer(
    ConsumerRegisterParams params,
  );
  Future<Either<Failure, UserEntity>> registerVendor(
    VendorRegisterParams params,
  );

  Future<Either<Failure, Unit>> changePassword({
    required String currentPassword,
    required String newPassword,
    required String confirmNewPassword,
  });
  /// Right payload is the debug OTP echoed by the backend, if present (no
  /// real email gateway wired up yet) — null once one exists.
  Future<Either<Failure, String?>> forgotPassword(String email);
  Future<Either<Failure, Unit>> verifyForgotPasswordOtp({
    required String email,
    required String otpToken,
    required String newPassword,
    required String confirmNewPassword,
  });
  Future<Either<Failure, AuthTokenPair>> refreshToken(String token);

  /// Backend-driven email OTP (`/api/auth/send-email-otp` /
  /// `verify-email`) — not wired into any screen yet. Right payload is the
  /// debug OTP echoed by the backend, if present.
  Future<Either<Failure, String?>> sendEmailOtp(String email);
  Future<Either<Failure, Unit>> verifyEmailOtp(String otpToken);

  /// Backend-driven phone OTP (`/api/auth/send-phone-otp` / `verify-phone`)
  /// — distinct from [sendOtp]/[verifyOtp] below (Firebase-based). Not
  /// wired into any screen yet; see PhoneAuthDatasource for the active flow.
  /// Right payload is the debug OTP echoed by the backend, if present.
  Future<Either<Failure, String?>> sendPhoneOtpBackend(String phoneNumber);
  Future<Either<Failure, Unit>> verifyPhoneOtpBackend(String otpToken);

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
