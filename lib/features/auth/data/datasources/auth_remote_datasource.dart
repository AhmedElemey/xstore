import 'package:dio/dio.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/network/api_endpoints.dart';
import '../models/user_model.dart';

abstract interface class AuthRemoteDataSource {
  Future<UserModel> login({
    required String email,
    required String password,
  });

  Future<UserModel> register({
    required String email,
    required String password,
  });
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  AuthRemoteDataSourceImpl(this._dio);

  final Dio _dio;

  @override
  Future<UserModel> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        ApiEndpoints.login,
        data: {'email': email, 'password': password},
      );
      final data = response.data;
      if (data == null) {
        throw const ServerException('Empty response');
      }
      return UserModel.fromJson(data);
    } on DioException catch (e) {
      if (_isOffline(e)) {
        return _demoUser(email: email);
      }
      throw _mapDio(e);
    }
  }

  @override
  Future<UserModel> register({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        ApiEndpoints.register,
        data: {'email': email, 'password': password},
      );
      final data = response.data;
      if (data == null) {
        throw const ServerException('Empty response');
      }
      return UserModel.fromJson(data);
    } on DioException catch (e) {
      if (_isOffline(e)) {
        return _demoUser(email: email);
      }
      throw _mapDio(e);
    }
  }

  bool _isOffline(DioException e) {
    return e.type == DioExceptionType.connectionError ||
        e.type == DioExceptionType.connectionTimeout;
  }

  UserModel _demoUser({required String email}) {
    return UserModel(
      id: 'demo-${email.hashCode}',
      email: email,
      isVendor: email.toLowerCase().contains('vendor'),
      token: 'demo-token',
    );
  }

  AppException _mapDio(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.connectionError:
        return NetworkException(e.message);
      case DioExceptionType.badResponse:
        final code = e.response?.statusCode;
        if (code == 401 || code == 403) {
          return UnauthorizedException(e.message);
        }
        return ServerException(e.message);
      default:
        return ServerException(e.message);
    }
  }
}
