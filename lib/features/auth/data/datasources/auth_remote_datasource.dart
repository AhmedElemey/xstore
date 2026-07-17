import 'package:dio/dio.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/mock/mock_config.dart';
import '../../../../core/mock/mock_users.dart';
import '../../../../core/network/api_auth_headers.dart';
import '../../../../core/network/api_endpoints.dart';
import '../../../../core/network/dio_error_mapper.dart';
import '../../../../core/network/legacy_route_options.dart';
import '../../domain/entities/consumer_register_params.dart';
import '../../domain/entities/login_params.dart';
import '../../domain/entities/register_params.dart';
import '../../domain/entities/vendor_register_params.dart';
import '../models/user_model.dart';

abstract interface class AuthRemoteDataSource {
  Future<UserModel> login(LoginParams params);

  Future<UserModel> register(RegisterParams params);

  Future<UserModel> registerConsumer(ConsumerRegisterParams params);
  Future<UserModel> registerVendor(VendorRegisterParams params);

  /// CONFIRMED live backend: login/register only return
  /// `{token, refreshToken}` — no user fields. Call this immediately after
  /// (with the token already persisted, so it's sent via X-Auth-Token) to
  /// get the actual user. Response shape: `{"user": {...}, "store": ...}`.
  Future<UserModel> fetchProfile();

  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
    required String confirmNewPassword,
  });
  /// Returns the debug OTP echoed back by the backend, if present (the
  /// server includes it in the response body while no real email/SMS
  /// gateway is wired up). Null once a real gateway is in place.
  Future<String?> forgotPassword(String email);
  Future<void> verifyForgotPasswordOtp({
    required String email,
    required String otpToken,
    required String newPassword,
    required String confirmNewPassword,
  });
  Future<({String token, String refreshToken})> refreshToken(String token);

  /// See [forgotPassword] doc — same debug-OTP-echo behavior.
  Future<String?> sendEmailOtp(String email);
  Future<void> verifyEmailOtp(String otpToken);
  Future<String?> sendPhoneOtpBackend(String phoneNumber);
  Future<void> verifyPhoneOtpBackend(String otpToken);

  Future<void> logout();

  /// Exchanges a Firebase ID token (verified server-side) for a backend session.
  /// Returns null while the backend route is not deployed yet (404) — callers
  /// fall back to a local-only session.
  Future<UserModel?> loginWithSocialToken({
    required String provider,
    required String idToken,
  });

  /// Exchanges a Firebase phone-auth ID token for a backend session.
  Future<UserModel> loginWithPhoneToken({
    required String firebaseIdToken,
    required String phoneNumber,
  });
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  AuthRemoteDataSourceImpl(this._dio);

  final Dio _dio;

  @override
  Future<UserModel> login(LoginParams params) async {
    final identifier = params.emailOrPhone.trim();
    final password = params.password;

    if (MockConfig.useMock) {
      // Identifier-routed fake sessions (any password). Courier is the only
      // role the backend cannot mint yet — this is the supported way to run
      // the app as a driver until courier auth ships server-side.
      final model = mockLoginIsCourier(identifier)
          ? mockCourierUserModel()
          : mockLoginIsVendor(identifier)
              ? mockVendorUserModel()
              : mockConsumerUserModel();
      return MockConfig.simulate(model);
    }

    try {
      final response = await _dio.post<Map<String, dynamic>>(
        ApiEndpoints.apiLogin,
        data: {
          'emailOrPhone': identifier,
          'password': password,
          'rememberMe': params.rememberMe,
        },
        options: ApiAuthHeaders.public(),
      );
      final data = response.data;
      if (data == null) {
        throw const ServerException('Empty response');
      }
      return _tokenOnlyModel(data, email: identifier);
    } on DioException catch (e) {
      throw mapDioException(e);
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
      throw mapDioException(e);
    }
  }

  @override
  Future<UserModel> registerConsumer(ConsumerRegisterParams params) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        ApiEndpoints.consumerRegister,
        data: {
          'fullNameEn': params.fullNameEn,
          'fullNameAr': params.fullNameAr,
          // Email is optional (phone is the account identifier); the live
          // backend registers fine without the key, so omit it when blank.
          if (params.email.trim().isNotEmpty) 'email': params.email.trim(),
          'phoneNumber': params.phoneNumber,
          'password': params.password,
          'confirmPassword': params.confirmPassword,
          'dateOfBirth': params.dateOfBirth?.toIso8601String(),
        },
        options: ApiAuthHeaders.public(),
      );
      final data = response.data;
      if (data == null) throw const ServerException('Empty response');
      return _tokenOnlyModel(data, email: params.email);
    } on DioException catch (e) {
      throw mapDioException(e);
    }
  }

  @override
  Future<UserModel> registerVendor(VendorRegisterParams params) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        ApiEndpoints.vendorRegister,
        data: {
          'fullNameEn': params.fullNameEn,
          'fullNameAr': params.fullNameAr,
          // See registerConsumer — email is optional, omit when blank.
          if (params.email.trim().isNotEmpty) 'email': params.email.trim(),
          'phoneNumber': params.phoneNumber,
          'password': params.password,
          'confirmPassword': params.confirmPassword,
          'dateOfBirth': params.dateOfBirth?.toIso8601String(),
          'storeNameEn': params.storeNameEn,
          'storeNameAr': params.storeNameAr,
          'storeDescriptionEn': params.storeDescriptionEn,
          'storeDescriptionAr': params.storeDescriptionAr,
          'storeCategoryId': params.storeCategoryId,
          'storeCityId': params.storeCityId,
          'storeGovernmentId': params.storeGovernmentId,
          'whatsappNumber': params.whatsappNumber,
        },
        options: ApiAuthHeaders.public(),
      );
      final data = response.data;
      if (data == null) throw const ServerException('Empty response');
      return _tokenOnlyModel(data, email: params.email);
    } on DioException catch (e) {
      throw mapDioException(e);
    }
  }

  /// Builds a placeholder [UserModel] carrying only the token/refreshToken
  /// from a login/register response (which has no user fields at all — see
  /// [AuthRemoteDataSource.fetchProfile] doc). The repository immediately
  /// replaces this with the real profile; [email] is a best-effort display
  /// placeholder in case that follow-up call fails.
  UserModel _tokenOnlyModel(Map<String, dynamic> data, {required String email}) {
    final token = data['token'] as String?;
    if (token == null || token.isEmpty) {
      throw const ServerException('Missing token in response');
    }
    return UserModel(
      id: '',
      email: email,
      token: token,
      refreshToken: data['refreshToken'] as String?,
    );
  }

  @override
  Future<UserModel> fetchProfile() async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        ApiEndpoints.getProfile,
        options: ApiAuthHeaders.authenticated(),
      );
      final data = response.data;
      if (data == null) throw const ServerException('Empty profile response');
      final userJson = parseProfileUserJson(data);
      return UserModel.fromJson(userJson);
    } on FormatException {
      throw const ServerException('Empty profile response');
    } on DioException catch (e) {
      throw mapDioException(e);
    }
  }

  @override
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
    required String confirmNewPassword,
  }) async {
    try {
      await _dio.post<void>(
        ApiEndpoints.changePassword,
        data: {
          'currentPassword': currentPassword,
          'newPassword': newPassword,
          'confirmNewPassword': confirmNewPassword,
        },
        options: ApiAuthHeaders.authenticated(),
      );
    } on DioException catch (e) {
      throw mapDioException(e);
    }
  }

  @override
  Future<String?> forgotPassword(String email) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        ApiEndpoints.forgotPassword,
        data: {'email': email},
        options: ApiAuthHeaders.public(),
      );
      return response.data?['otp'] as String?;
    } on DioException catch (e) {
      throw mapDioException(e);
    }
  }

  @override
  Future<void> verifyForgotPasswordOtp({
    required String email,
    required String otpToken,
    required String newPassword,
    required String confirmNewPassword,
  }) async {
    try {
      await _dio.post<void>(
        ApiEndpoints.verifyForgotPasswordOtp,
        data: {
          'email': email,
          'otpToken': otpToken,
          'newPassword': newPassword,
          'confirmNewPassword': confirmNewPassword,
        },
        options: ApiAuthHeaders.public(),
      );
    } on DioException catch (e) {
      throw mapDioException(e);
    }
  }

  @override
  Future<({String token, String refreshToken})> refreshToken(
    String token,
  ) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        ApiEndpoints.refreshToken,
        data: {'token': token},
        options: ApiAuthHeaders.public(),
      );
      final data = response.data;
      if (data == null) throw const ServerException('Empty response');
      return (
        token: data['token'] as String,
        refreshToken: data['refreshToken'] as String? ?? '',
      );
    } on DioException catch (e) {
      throw mapDioException(e);
    }
  }

  @override
  Future<String?> sendEmailOtp(String email) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        ApiEndpoints.sendEmailOtp,
        data: {'email': email},
        options: ApiAuthHeaders.authenticated(),
      );
      return response.data?['otp'] as String?;
    } on DioException catch (e) {
      throw mapDioException(e);
    }
  }

  @override
  Future<void> verifyEmailOtp(String otpToken) async {
    try {
      await _dio.post<void>(
        ApiEndpoints.verifyEmail,
        data: {'otpToken': otpToken},
        options: ApiAuthHeaders.authenticated(),
      );
    } on DioException catch (e) {
      throw mapDioException(e);
    }
  }

  @override
  Future<String?> sendPhoneOtpBackend(String phoneNumber) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        ApiEndpoints.sendPhoneOtp,
        data: {'phoneNumber': phoneNumber},
        options: ApiAuthHeaders.authenticated(),
      );
      return response.data?['otp'] as String?;
    } on DioException catch (e) {
      throw mapDioException(e);
    }
  }

  @override
  Future<void> verifyPhoneOtpBackend(String otpToken) async {
    try {
      await _dio.post<void>(
        ApiEndpoints.verifyPhone,
        data: {'otpToken': otpToken},
        options: ApiAuthHeaders.authenticated(),
      );
    } on DioException catch (e) {
      throw mapDioException(e);
    }
  }

  @override
  Future<void> logout() async {
    try {
      await _dio.post<void>(
        ApiEndpoints.apiLogout,
        options: ApiAuthHeaders.authenticated(),
      );
    } on DioException catch (e) {
      throw mapDioException(e);
    }
  }

  @override
  Future<UserModel?> loginWithSocialToken({
    required String provider,
    required String idToken,
  }) async {
    if (MockConfig.useMock) {
      final model = mockConsumerUserModel(email: 'social-$provider@xstore.com');
      return MockConfig.simulate(model);
    }

    try {
      // TODO(backend): confirm payload keys (`provider`, `idToken`) and response shape.
      final response = await _dio.post<Map<String, dynamic>>(
        ApiEndpoints.socialLogin,
        data: {
          'provider': provider,
          'idToken': idToken,
        },
        options: LegacyRouteOptions.allowNotFound(),
      );
      // Route not deployed yet — signal the caller to use a local session.
      if (LegacyRouteOptions.isNotFound(response)) return null;
      final data = response.data;
      if (data == null) {
        throw const ServerException('Empty response');
      }
      return UserModel.fromJson(data);
    } on DioException catch (e) {
      throw mapDioException(e);
    }
  }

  @override
  Future<UserModel> loginWithPhoneToken({
    required String firebaseIdToken,
    required String phoneNumber,
  }) async {
    if (MockConfig.useMock) {
      final model = mockConsumerUserModel(phoneNumber: phoneNumber);
      return MockConfig.simulate(model);
    }

    try {
      // TODO(backend): confirm payload keys (`firebaseIdToken`, `phoneNumber`).
      final response = await _dio.post<Map<String, dynamic>>(
        ApiEndpoints.phoneLogin,
        data: {
          'firebaseIdToken': firebaseIdToken,
          'phoneNumber': phoneNumber,
        },
      );
      final data = response.data;
      if (data == null) {
        throw const ServerException('Empty response');
      }
      return UserModel.fromJson(data);
    } on DioException catch (e) {
      throw mapDioException(e);
    }
  }
}
