import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:fpdart/fpdart.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/login_params.dart';
import '../../domain/entities/register_params.dart';
import '../../domain/entities/send_otp_params.dart';
import '../../domain/entities/send_otp_result.dart';
import '../../domain/entities/social_auth_result.dart';
import '../../domain/entities/user_entity.dart';
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
  })  : _remote = remote,
        _social = social,
        _phone = phone,
        _secureStorage = secureStorage;

  final AuthRemoteDataSource _remote;
  final SocialAuthDatasource _social;
  final PhoneAuthDatasource _phone;
  final FlutterSecureStorage _secureStorage;

  static const _tokenKey = 'xstore_auth_token';
  static const _userKey = 'xstore_auth_user';

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
  Future<Either<Failure, Unit>> logout() async {
    try {
      await _social.signOutSocial();
      await _secureStorage.delete(key: _tokenKey);
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
      return Right(result);
    } on SocialAuthCancelledException catch (e) {
      return Left(Failure.socialAuthCancelled(e.message));
    } on SocialAuthException catch (e) {
      return Left(Failure.socialAuth(e.message));
    } catch (e) {
      return Left(Failure.socialAuth(e.toString()));
    }
  }

  @override
  Future<Either<Failure, SocialAuthResult>> signInWithApple() async {
    try {
      final result = await _social.signInWithApple();
      return Right(result);
    } on SocialAuthCancelledException catch (e) {
      return Left(Failure.socialAuthCancelled(e.message));
    } on SocialAuthException catch (e) {
      return Left(Failure.socialAuth(e.message));
    } catch (e) {
      return Left(Failure.socialAuth(e.toString()));
    }
  }

  @override
  Future<Either<Failure, SocialAuthResult>> signInWithFacebook() async {
    try {
      final result = await _social.signInWithFacebook();
      return Right(result);
    } on SocialAuthCancelledException catch (e) {
      return Left(Failure.socialAuthCancelled(e.message));
    } on SocialAuthException catch (e) {
      return Left(Failure.socialAuth(e.message));
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
      final user = await _phone.verifyOtp(
        verificationId: params.verificationId,
        otpCode: params.otpCode,
        phoneNumber: params.phoneNumber,
      );
      await persistSessionUser(user);
      return Right(user);
    } on PhoneAuthException catch (e) {
      return Left(Failure.phoneAuth(e.message));
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
    await _secureStorage.write(key: _userKey, value: jsonEncode(map));
  }
}
