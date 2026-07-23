import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:fpdart/fpdart.dart';

import '../../../../core/constants/prefs_keys.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/mock/mock_config.dart';
import '../../domain/entities/auth_token_pair.dart';
import '../../domain/entities/consumer_register_params.dart';
import '../../domain/entities/login_params.dart';
import '../../domain/entities/register_params.dart';
import '../../domain/entities/send_otp_params.dart';
import '../../domain/entities/send_otp_result.dart';
import '../../domain/entities/social_auth_result.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/entities/vendor_register_params.dart';
import '../../domain/entities/verify_otp_params.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_datasource.dart';
import '../datasources/phone_auth_datasource.dart';
import '../datasources/social_auth_datasource.dart';
import '../../../../core/utils/jwt_payload.dart';
import '../models/user_model.dart';

class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl({
    required AuthRemoteDataSource remote,
    required SocialAuthDatasource social,
    required PhoneAuthDatasource phone,
    required FlutterSecureStorage secureStorage,
    FirebaseAuth? firebaseAuth,
  })  : _remote = remote,
        _social = social,
        _phone = phone,
        _secureStorage = secureStorage,
        _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance;

  final AuthRemoteDataSource _remote;
  final SocialAuthDatasource _social;
  final PhoneAuthDatasource _phone;
  final FlutterSecureStorage _secureStorage;
  final FirebaseAuth _firebaseAuth;

  static const _tokenKey = PrefsKeys.authToken;
  static const _userKey = PrefsKeys.authUser;

  @override
  Future<Either<Failure, UserEntity?>> restoreSession() async {
    try {
      final jsonStr = await _secureStorage.read(key: _userKey);
      if (jsonStr == null || jsonStr.isEmpty) {
        return const Right(null);
      }
      final map = jsonDecode(jsonStr) as Map<String, dynamic>;
      var model = UserModel.fromJson(map);
      if (model.id.isEmpty) {
        final token = await _secureStorage.read(key: _tokenKey);
        final id = userIdFromJwt(token);
        if (id != null) {
          model = model.copyWith(id: id);
          await _persistUser(model);
        }
      }
      return Right(model.toEntity());
    } catch (e) {
      return Left(Failure.cache(e.toString()));
    }
  }

  @override
  Future<Either<Failure, UserEntity>> login(LoginParams params) async {
    try {
      final model = await _resolveFullUser(await _remote.login(params));
      await _persistUser(model);
      return Right(model.toEntity());
    } on AuthException catch (e) {
      return Left(Failure.unauthorized(e.message));
    } on NetworkException catch (e) {
      return Left(Failure.network(e.message));
    } on UnauthorizedException catch (e) {
      return Left(Failure.unauthorized(e.message));
    } on ServerException catch (e) {
      return Left(Failure.server(e.message));
    } catch (e) {
      return Left(Failure.server(e.toString()));
    }
  }

  @override
  Future<Either<Failure, String?>> sendLoginOtp(String phoneNumber) async {
    try {
      final otp = await _remote.sendLoginOtp(phoneNumber);
      return Right(otp);
    } on NetworkException catch (e) {
      return Left(Failure.network(e.message));
    } on UnauthorizedException catch (e) {
      return Left(Failure.unauthorized(e.message));
    } on ServerException catch (e) {
      return Left(Failure.server(e.message));
    } catch (e) {
      return Left(Failure.server(e.toString()));
    }
  }

  @override
  Future<Either<Failure, UserEntity>> loginWithOtp({
    required String phoneNumber,
    required String otpToken,
  }) async {
    try {
      final model = await _resolveFullUser(
        await _remote.loginWithOtp(
          phoneNumber: phoneNumber,
          otpToken: otpToken,
          // No remember-me toggle on the phone-login sheet; keep the session
          // alive by requesting a refresh token.
          rememberMe: true,
        ),
      );
      await _persistUser(model);
      return Right(model.toEntity());
    } on AuthException catch (e) {
      return Left(Failure.unauthorized(e.message));
    } on NetworkException catch (e) {
      return Left(Failure.network(e.message));
    } on UnauthorizedException catch (e) {
      return Left(Failure.unauthorized(e.message));
    } on ServerException catch (e) {
      return Left(Failure.server(e.message));
    } catch (e) {
      return Left(Failure.server(e.toString()));
    }
  }

  @override
  Future<Either<Failure, UserEntity>> loginWithGoogle({
    required String idToken,
    required UserRole role,
  }) async {
    try {
      final model = await _resolveFullUser(
        await _remote.loginWithGoogle(
          idToken: idToken,
          asVendor: role == UserRole.vendor,
        ),
      );
      await _persistUser(model);
      return Right(model.toEntity());
    } on AuthException catch (e) {
      return Left(Failure.unauthorized(e.message));
    } on NetworkException catch (e) {
      return Left(Failure.network(e.message));
    } on UnauthorizedException catch (e) {
      return Left(Failure.unauthorized(e.message));
    } on ServerException catch (e) {
      return Left(Failure.server(e.message));
    } catch (e) {
      return Left(Failure.server(e.toString()));
    }
  }

  @override
  Future<Either<Failure, UserEntity>> register(RegisterParams params) async {
    try {
      final model = await _remote.register(params);
      await _persistUser(model);
      return Right(model.toEntity());
    } on NetworkException catch (e) {
      return Left(Failure.network(e.message));
    } on UnauthorizedException catch (e) {
      return Left(Failure.unauthorized(e.message));
    } on ServerException catch (e) {
      return Left(Failure.server(e.message));
    } catch (e) {
      return Left(Failure.server(e.toString()));
    }
  }

  @override
  Future<Either<Failure, UserEntity>> registerConsumer(
    ConsumerRegisterParams params,
  ) async {
    try {
      final model = await _resolveFullUser(await _remote.registerConsumer(params));
      await _persistUser(model);
      return Right(model.toEntity());
    } on NetworkException catch (e) {
      return Left(Failure.network(e.message));
    } on UnauthorizedException catch (e) {
      return Left(Failure.unauthorized(e.message));
    } on ServerException catch (e) {
      return Left(Failure.server(e.message));
    } catch (e) {
      return Left(Failure.server(e.toString()));
    }
  }

  @override
  Future<Either<Failure, UserEntity>> registerVendor(
    VendorRegisterParams params,
  ) async {
    try {
      final model = await _resolveFullUser(await _remote.registerVendor(params));
      await _persistUser(model);
      return Right(model.toEntity());
    } on NetworkException catch (e) {
      return Left(Failure.network(e.message));
    } on UnauthorizedException catch (e) {
      return Left(Failure.unauthorized(e.message));
    } on ServerException catch (e) {
      return Left(Failure.server(e.message));
    } catch (e) {
      return Left(Failure.server(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Unit>> changePassword({
    required String currentPassword,
    required String newPassword,
    required String confirmNewPassword,
  }) async {
    try {
      await _remote.changePassword(
        currentPassword: currentPassword,
        newPassword: newPassword,
        confirmNewPassword: confirmNewPassword,
      );
      return const Right(unit);
    } on AuthException catch (e) {
      return Left(Failure.unauthorized(e.message));
    } on NetworkException catch (e) {
      return Left(Failure.network(e.message));
    } on ServerException catch (e) {
      return Left(Failure.server(e.message));
    } catch (e) {
      return Left(Failure.server(e.toString()));
    }
  }

  @override
  Future<Either<Failure, String?>> forgotPassword(String email) async {
    try {
      final otp = await _remote.forgotPassword(email);
      return Right(otp);
    } on NetworkException catch (e) {
      return Left(Failure.network(e.message));
    } on ServerException catch (e) {
      return Left(Failure.server(e.message));
    } catch (e) {
      return Left(Failure.server(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Unit>> verifyForgotPasswordOtp({
    required String email,
    required String otpToken,
    required String newPassword,
    required String confirmNewPassword,
  }) async {
    try {
      await _remote.verifyForgotPasswordOtp(
        email: email,
        otpToken: otpToken,
        newPassword: newPassword,
        confirmNewPassword: confirmNewPassword,
      );
      return const Right(unit);
    } on NetworkException catch (e) {
      return Left(Failure.network(e.message));
    } on ServerException catch (e) {
      return Left(Failure.server(e.message));
    } catch (e) {
      return Left(Failure.server(e.toString()));
    }
  }

  @override
  Future<Either<Failure, AuthTokenPair>> refreshToken(String token) async {
    try {
      final result = await _remote.refreshToken(token);
      final pair = AuthTokenPair(
        token: result.token,
        refreshToken: result.refreshToken,
      );
      await _secureStorage.write(key: _tokenKey, value: pair.token);
      await _secureStorage.write(
        key: PrefsKeys.authRefreshToken,
        value: pair.refreshToken,
      );
      return Right(pair);
    } on UnauthorizedException catch (e) {
      return Left(Failure.unauthorized(e.message));
    } on NetworkException catch (e) {
      return Left(Failure.network(e.message));
    } on ServerException catch (e) {
      return Left(Failure.server(e.message));
    } catch (e) {
      return Left(Failure.server(e.toString()));
    }
  }

  @override
  Future<Either<Failure, String?>> sendEmailOtp(String email) async {
    try {
      final otp = await _remote.sendEmailOtp(email);
      return Right(otp);
    } on NetworkException catch (e) {
      return Left(Failure.network(e.message));
    } on ServerException catch (e) {
      return Left(Failure.server(e.message));
    } catch (e) {
      return Left(Failure.server(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Unit>> verifyEmailOtp(String otpToken) async {
    try {
      await _remote.verifyEmailOtp(otpToken);
      return const Right(unit);
    } on NetworkException catch (e) {
      return Left(Failure.network(e.message));
    } on ServerException catch (e) {
      return Left(Failure.server(e.message));
    } catch (e) {
      return Left(Failure.server(e.toString()));
    }
  }

  @override
  Future<Either<Failure, String?>> sendPhoneOtpBackend(
    String phoneNumber,
  ) async {
    try {
      final otp = await _remote.sendPhoneOtpBackend(phoneNumber);
      return Right(otp);
    } on NetworkException catch (e) {
      return Left(Failure.network(e.message));
    } on ServerException catch (e) {
      return Left(Failure.server(e.message));
    } catch (e) {
      return Left(Failure.server(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Unit>> verifyPhoneOtpBackend(
    String otpToken,
  ) async {
    try {
      await _remote.verifyPhoneOtpBackend(otpToken);
      return const Right(unit);
    } on NetworkException catch (e) {
      return Left(Failure.network(e.message));
    } on ServerException catch (e) {
      return Left(Failure.server(e.message));
    } catch (e) {
      return Left(Failure.server(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Unit>> logout() async {
    // Remote and social sign-outs are best-effort — local cleanup below is
    // what actually signs the user out, and must run even if they fail
    // (expired token, offline, unconfigured Facebook SDK throwing).
    try {
      await _remote.logout();
    } catch (_) {}
    try {
      await _social.signOutSocial();
    } catch (_) {}
    try {
      await _secureStorage.delete(key: _tokenKey);
      await _secureStorage.delete(key: PrefsKeys.authRefreshToken);
      await _secureStorage.delete(key: _userKey);
      await _secureStorage.delete(key: PrefsKeys.socialAuthCredentials);
      return const Right(unit);
    } catch (e) {
      return Left(Failure.cache(e.toString()));
    }
  }

  @override
  Future<Either<Failure, SocialAuthResult>> signInWithGoogle() async {
    try {
      // Google only obtains the identity token here; the backend session is
      // minted later by [loginWithGoogle] once the user picks a role (the two
      // Google endpoints are role-specific and auto-create the account).
      final result = await _social.signInWithGoogle();
      await _persistSocialCredentials(result);
      return Right(result);
    } on SocialAuthCancelledException catch (e) {
      return Left(Failure.socialAuthCancelled(e.message));
    } on SocialAuthException catch (e) {
      return Left(Failure.socialAuth(e.message));
    } on AuthException catch (e) {
      return Left(Failure.unauthorized(e.message));
    } on NetworkException catch (e) {
      return Left(Failure.network(e.message));
    } on UnauthorizedException catch (e) {
      return Left(Failure.unauthorized(e.message));
    } on ServerException catch (e) {
      return Left(Failure.server(e.message));
    } catch (e) {
      return Left(Failure.socialAuth(e.toString()));
    }
  }

  @override
  Future<Either<Failure, SocialAuthResult>> signInWithApple() async {
    try {
      final result = await _social.signInWithApple();
      await _persistSocialCredentials(result);
      final model = await _exchangeSocialToken(result);
      if (model == null) return Right(result);
      await _persistUser(model);
      return Right(result.copyWith(isNewUser: model.isNewUser));
    } on SocialAuthCancelledException catch (e) {
      return Left(Failure.socialAuthCancelled(e.message));
    } on SocialAuthException catch (e) {
      return Left(Failure.socialAuth(e.message));
    } on AuthException catch (e) {
      return Left(Failure.unauthorized(e.message));
    } on NetworkException catch (e) {
      return Left(Failure.network(e.message));
    } on UnauthorizedException catch (e) {
      return Left(Failure.unauthorized(e.message));
    } on ServerException catch (e) {
      return Left(Failure.server(e.message));
    } catch (e) {
      return Left(Failure.socialAuth(e.toString()));
    }
  }

  @override
  Future<Either<Failure, SocialAuthResult>> signInWithFacebook() async {
    try {
      final result = await _social.signInWithFacebook();
      await _persistSocialCredentials(result);
      final model = await _exchangeSocialToken(result);
      if (model == null) return Right(result);
      await _persistUser(model);
      return Right(result.copyWith(isNewUser: model.isNewUser));
    } on SocialAuthCancelledException catch (e) {
      return Left(Failure.socialAuthCancelled(e.message));
    } on SocialAuthException catch (e) {
      return Left(Failure.socialAuth(e.message));
    } on AuthException catch (e) {
      return Left(Failure.unauthorized(e.message));
    } on NetworkException catch (e) {
      return Left(Failure.network(e.message));
    } on UnauthorizedException catch (e) {
      return Left(Failure.unauthorized(e.message));
    } on ServerException catch (e) {
      return Left(Failure.server(e.message));
    } catch (e) {
      return Left(Failure.socialAuth(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Unit>> signOutSocial() async {
    try {
      await _social.signOutSocial();
      return const Right(unit);
    } on SocialAuthException catch (e) {
      return Left(Failure.socialAuth(e.message));
    } catch (e) {
      return Left(Failure.socialAuth(e.toString()));
    }
  }

  @override
  Future<Either<Failure, SendOtpResult>> sendOtp(SendOtpParams params) async {
    try {
      final result = await _phone.sendOtp(e164Number: params.e164Number);
      return Right(result);
    } on PhoneAuthException catch (e) {
      return Left(Failure.phoneAuth(e.message));
    } catch (e) {
      return Left(Failure.phoneAuth(e.toString()));
    }
  }

  @override
  Future<Either<Failure, UserEntity>> verifyOtp(VerifyOtpParams params) async {
    try {
      await _phone.verifyOtp(
        verificationId: params.verificationId,
        otpCode: params.otpCode,
        phoneNumber: params.phoneNumber,
      );
      final firebaseIdToken = await _requireFirebaseIdToken();
      final model = await _remote.loginWithPhoneToken(
        firebaseIdToken: firebaseIdToken,
        phoneNumber: params.phoneNumber,
      );
      await _persistUser(model);
      return Right(model.toEntity());
    } on PhoneAuthException catch (e) {
      return Left(Failure.phoneAuth(e.message));
    } on AuthException catch (e) {
      return Left(Failure.unauthorized(e.message));
    } on NetworkException catch (e) {
      return Left(Failure.network(e.message));
    } on UnauthorizedException catch (e) {
      return Left(Failure.unauthorized(e.message));
    } on ServerException catch (e) {
      return Left(Failure.server(e.message));
    } catch (e) {
      return Left(Failure.phoneAuth(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Unit>> persistSessionUser(UserEntity user) async {
    try {
      final token = await _secureStorage.read(key: _tokenKey);
      final model = UserModel(
        id: user.id,
        name: user.name,
        email: user.email,
        phoneNumber: user.phoneNumber,
        avatarUrl: user.avatarUrl,
        role: user.role,
        isVerified: user.isVerified,
        rating: user.rating,
        totalSales: user.totalSales,
        joinedAt: user.joinedAt,
        location: user.location,
        storeName: user.storeName,
        storeSlug: user.storeSlug,
        storeCategory: user.storeCategory,
        storeDescription: user.storeDescription,
        storeLogoUrl: user.storeLogoUrl,
        storeCity: user.storeCity,
        storeWilaya: user.storeWilaya,
        whatsappNumber: user.whatsappNumber,
        bio: user.bio,
        dateOfBirth: user.dateOfBirth,
        instagramHandle: user.instagramHandle,
        facebookPage: user.facebookPage,
        token: token,
        fullNameEn: user.fullNameEn,
        fullNameAr: user.fullNameAr,
        storeNameEn: user.storeNameEn,
        storeNameAr: user.storeNameAr,
        storeDescriptionEn: user.storeDescriptionEn,
        storeDescriptionAr: user.storeDescriptionAr,
        storeCategoryId: user.storeCategoryId,
        storeCityId: user.storeCityId,
        storeGovernmentId: user.storeGovernmentId,
        storeId: user.storeId,
      );
      await _persistUser(model);
      return const Right(unit);
    } catch (e) {
      return Left(Failure.cache(e.toString()));
    }
  }

  /// Live login/register responses only carry `{token, refreshToken}` — no
  /// user fields at all (confirmed against a live backend), so the identity
  /// is fetched via get-profile. Persists the token first (so it's sent via
  /// X-Auth-Token), merging the token pair back in. Mock login is the one
  /// path that already returns a full identity (non-empty id) — skip the
  /// profile round-trip for it, since a mock token would 401 on the live
  /// get-profile route.
  Future<UserModel> _resolveFullUser(UserModel loginResult) async {
    if (loginResult.token != null && loginResult.token!.isNotEmpty) {
      await _secureStorage.write(key: _tokenKey, value: loginResult.token);
    }
    if (loginResult.id.isNotEmpty) return loginResult;
    final profile = await _remote.fetchProfile(authToken: loginResult.token);
    var merged = profile.copyWith(
      token: loginResult.token,
      refreshToken: loginResult.refreshToken,
    );
    if (merged.id.isEmpty) {
      final id = userIdFromJwt(loginResult.token);
      if (id != null) merged = merged.copyWith(id: id);
    }
    return merged;
  }

  Future<void> _persistUser(UserModel model) async {
    final map = model.toJson();
    if (model.token != null) {
      await _secureStorage.write(key: _tokenKey, value: model.token);
    }
    if (model.refreshToken != null) {
      await _secureStorage.write(
        key: PrefsKeys.authRefreshToken,
        value: model.refreshToken,
      );
    }
    await _secureStorage.write(key: _userKey, value: jsonEncode(map));
  }

  /// Local-only for now: the backend social endpoint isn't live yet, so keep
  /// the full provider credential set for later registration and debugging.
  /// Best-effort — a storage failure must never abort the sign-in flow.
  Future<void> _persistSocialCredentials(SocialAuthResult result) async {
    try {
      final firebaseIdToken = MockConfig.useMock
          ? 'mock-firebase-id-token'
          : await _firebaseAuth.currentUser?.getIdToken();
      await _secureStorage.write(
        key: PrefsKeys.socialAuthCredentials,
        value: jsonEncode({
          'provider': result.provider.name,
          'uid': result.uid,
          'email': result.email,
          'displayName': result.displayName,
          'photoUrl': result.photoUrl,
          'accessToken': result.accessToken,
          'idToken': result.idToken,
          'firebaseIdToken': firebaseIdToken,
          'savedAt': DateTime.now().toIso8601String(),
        }),
      );
      if (kDebugMode) {
        debugPrint(
          'Social credentials saved locally '
          '(${result.provider.name}, ${result.email})',
        );
      }
    } catch (e) {
      if (kDebugMode) debugPrint('Failed to save social credentials: $e');
    }
  }

  /// Null while the backend social route is not deployed (404) — the social
  /// sign-in then proceeds as a local-only session: the notifier persists the
  /// Firebase-derived user via authProvider.setUser, and Firebase's own
  /// isNewUser flag drives role selection.
  Future<UserModel?> _exchangeSocialToken(SocialAuthResult result) async {
    final firebaseIdToken = await _requireFirebaseIdToken();
    return _remote.loginWithSocialToken(
      provider: result.provider.name,
      idToken: firebaseIdToken,
    );
  }

  Future<String> _requireFirebaseIdToken() async {
    if (MockConfig.useMock) return 'mock-firebase-id-token';
    final token = await _firebaseAuth.currentUser?.getIdToken();
    if (token == null || token.isEmpty) {
      throw const AuthException('Firebase session missing after sign-in');
    }
    return token;
  }
}
