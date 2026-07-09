import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
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
      final model = UserModel.fromJson(map);
      return Right(model.toEntity());
    } catch (e) {
      return Left(Failure.cache(e.toString()));
    }
  }

  @override
  Future<Either<Failure, UserEntity>> login(LoginParams params) async {
    try {
      final model = await _remote.login(params);
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
      final model = await _remote.registerConsumer(params);
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
      final model = await _remote.registerVendor(params);
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
    try {
      if (!MockConfig.useMock) {
        // Best-effort — local state is always cleared below regardless of
        // whether the remote call succeeds (e.g. token already expired).
        try {
          await _remote.logout();
        } catch (_) {
          // Ignore: local cleanup below is what actually signs the user out.
        }
      }
      await _social.signOutSocial();
      await _secureStorage.delete(key: _tokenKey);
      await _secureStorage.delete(key: PrefsKeys.authRefreshToken);
      await _secureStorage.delete(key: _userKey);
      return const Right(unit);
    } catch (e) {
      return Left(Failure.cache(e.toString()));
    }
  }

  @override
  Future<Either<Failure, SocialAuthResult>> signInWithGoogle() async {
    try {
      final result = await _social.signInWithGoogle();
      final model = await _exchangeSocialToken(result);
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
  Future<Either<Failure, SocialAuthResult>> signInWithApple() async {
    try {
      final result = await _social.signInWithApple();
      final model = await _exchangeSocialToken(result);
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
      final model = await _exchangeSocialToken(result);
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
      );
      await _persistUser(model);
      return const Right(unit);
    } catch (e) {
      return Left(Failure.cache(e.toString()));
    }
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

  Future<UserModel> _exchangeSocialToken(SocialAuthResult result) async {
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
