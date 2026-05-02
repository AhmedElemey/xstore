import 'package:dio/dio.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/mock/mock_config.dart';
import '../../../../core/mock/mock_users.dart';
import '../../../../core/network/api_endpoints.dart';
import '../../domain/entities/login_params.dart';
import '../../domain/entities/register_params.dart';
import '../models/user_model.dart';

abstract interface class AuthRemoteDataSource {
  Future<UserModel> login(LoginParams params);

  Future<UserModel> register(RegisterParams params);
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  AuthRemoteDataSourceImpl(this._dio);

  final Dio _dio;

  @override
  Future<UserModel> login(LoginParams params) async {
    final identifier = params.emailOrPhone.trim();
    final password = params.password;

    if (MockConfig.useMock) {
      if (password == 'wrong123') {
        throw const AuthException('Invalid credentials');
      }
      final model = mockLoginIsVendor(identifier)
          ? mockVendorUserModel(email: identifier.contains('@') ? identifier : 'vendor@xstore.com')
          : mockConsumerUserModel(email: identifier.contains('@') ? identifier : 'user@xstore.com');
      return MockConfig.simulate(model);
    }

    try {
      final response = await _dio.post<Map<String, dynamic>>(
        ApiEndpoints.login,
        data: {
          'emailOrPhone': identifier,
          'password': password,
          'rememberMe': params.rememberMe,
        },
      );
      final data = response.data;
      if (data == null) {
        throw const ServerException('Empty response');
      }
      return UserModel.fromJson(data);
    } on DioException catch (e) {
      throw _mapDio(e);
    }
  }

  @override
  Future<UserModel> register(RegisterParams params) async {
    if (MockConfig.useMock) {
      final model = userModelFromRegisterParams(params);
      return MockConfig.simulateScaled(model, multiplier: 2);
    }

    try {
      final response = await _dio.post<Map<String, dynamic>>(
        ApiEndpoints.register,
        data: {
          'role': params.role.name,
          'fullName': params.fullName,
          'email': params.email,
          'phoneNumber': params.phoneNumber,
          'countryCode': params.countryCode,
          'dateOfBirth': params.dateOfBirth?.toIso8601String(),
          'location': params.location,
          'password': params.password,
          'storeName': params.storeName,
          'storeCategory': params.storeCategory,
          'storeDescription': params.storeDescription,
          'storeCity': params.storeCity,
          'storeWilaya': params.storeWilaya,
          'whatsappNumber': params.whatsappNumber,
        },
      );
      final data = response.data;
      if (data == null) {
        throw const ServerException('Empty response');
      }
      return UserModel.fromJson(data);
    } on DioException catch (e) {
      throw _mapDio(e);
    }
  }

  AppException _mapDio(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.connectionError:
        return const NetworkException(
          'Network unavailable. Please check your connection and try again.',
        );
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
