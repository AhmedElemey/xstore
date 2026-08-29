import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failures.dart';
import '../entities/auth_token_pair.dart';
import '../entities/consumer_register_params.dart';
import '../entities/login_params.dart';
import '../entities/register_params.dart';
import '../entities/social_auth_result.dart';
import '../entities/user_entity.dart';
import '../entities/vendor_register_params.dart';

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
  /// Right payload is the debug OTP only when the API actually returned
  /// an `otp` field. Live forgot-password no longer echoes it.
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
  Future<Either<Failure, Unit>> verifyEmailOtp({
    required String email,
    required String otpToken,
  });

  /// Backend-driven phone OTP (`/api/auth/send-phone-otp` / `verify-phone`)
  /// for verifying an already-signed-in user's number. Distinct from
  /// passwordless login (`sendLoginOtp` / `loginWithOtp`).
  /// Right payload is the debug OTP only when the API returned an `otp` field.
  Future<Either<Failure, String?>> sendPhoneOtpBackend(String phoneNumber);
  Future<Either<Failure, Unit>> verifyPhoneOtpBackend({
    required String phoneNumber,
    required String otpToken,
  });

  /// Passwordless login for an existing account. [sendLoginOtp] Right payload
  /// is the debug OTP echoed by the backend, if present (null once a real SMS
  /// gateway exists); a 404 surfaces as "No account found with this phone
  /// number.". [loginWithOtp] resolves the full profile and persists the session.
  Future<Either<Failure, String?>> sendLoginOtp(String phoneNumber);
  Future<Either<Failure, UserEntity>> loginWithOtp({
    required String phoneNumber,
    required String otpToken,
  });

  Future<Either<Failure, SocialAuthResult>> signInWithGoogle();

  /// Exchanges a Google identity token for a backend session via the
  /// role-specific endpoint (auto-creates the account if none exists), then
  /// resolves the full profile and persists the session.
  Future<Either<Failure, UserEntity>> loginWithGoogle({
    required String idToken,
    required UserRole role,
  });

  Future<Either<Failure, SocialAuthResult>> signInWithApple();
  Future<Either<Failure, SocialAuthResult>> signInWithFacebook();
  Future<Either<Failure, Unit>> signOutSocial();

  Future<Either<Failure, Unit>> logout();

  /// Writes the current session user JSON (keeps existing auth token if set).
  Future<Either<Failure, Unit>> persistSessionUser(UserEntity user);
}
