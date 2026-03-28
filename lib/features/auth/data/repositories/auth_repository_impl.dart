import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:fpdart/fpdart.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_datasource.dart';
import '../models/user_model.dart';

class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl({
    required AuthRemoteDataSource remote,
    required FlutterSecureStorage secureStorage,
  })  : _remote = remote,
        _secureStorage = secureStorage;

  final AuthRemoteDataSource _remote;
  final FlutterSecureStorage _secureStorage;

  static const _tokenKey = 'xstore_auth_token';
  static const _userKey = 'xstore_auth_user';

  @override
  Future<Either<Failure, UserEntity?>> restoreSession() async {
    try {
      final json = await _secureStorage.read(key: _userKey);
      if (json == null || json.isEmpty) {
        return const Right(null);
      }
      final map = jsonDecode(json) as Map<String, dynamic>;
      final model = UserModel.fromJson(map);
      return Right(model.toEntity());
    } catch (e) {
      return Left(Failure.cache(e.toString()));
    }
  }

  @override
  Future<Either<Failure, UserEntity>> login({
    required String email,
    required String password,
  }) async {
    try {
      final model = await _remote.login(email: email, password: password);
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
  Future<Either<Failure, UserEntity>> register({
    required String email,
    required String password,
  }) async {
    try {
      final model = await _remote.register(email: email, password: password);
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
      await _secureStorage.delete(key: _tokenKey);
      await _secureStorage.delete(key: _userKey);
      return const Right(unit);
    } catch (e) {
      return Left(Failure.cache(e.toString()));
    }
  }

  Future<void> _persistUser(UserModel model) async {
    final json = jsonEncode({
      'id': model.id,
      'email': model.email,
      'isVendor': model.isVendor,
      'token': model.token,
    });
    if (model.token != null) {
      await _secureStorage.write(key: _tokenKey, value: model.token);
    }
    await _secureStorage.write(key: _userKey, value: json);
  }
}
