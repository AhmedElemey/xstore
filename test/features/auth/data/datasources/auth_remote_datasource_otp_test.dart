import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:xstore/core/network/api_endpoints.dart';
import 'package:xstore/features/auth/data/datasources/auth_remote_datasource.dart';

class _ScriptedInterceptor extends Interceptor {
  _ScriptedInterceptor(this._respond);

  final Object? Function(RequestOptions options) _respond;

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final result = _respond(options);
    handler.resolve(
      Response(requestOptions: options, statusCode: 200, data: result),
    );
  }
}

void main() {
  AuthRemoteDataSourceImpl datasourceFor(Object? body) {
    final dio = Dio(BaseOptions(baseUrl: 'https://example.test'));
    dio.interceptors.add(_ScriptedInterceptor((_) => body));
    return AuthRemoteDataSourceImpl(dio);
  }

  group('forgotPassword debug OTP', () {
    test('returns null when the response has no otp field', () async {
      final otp = await datasourceFor({'message': 'sent'})
          .forgotPassword('jane@test.com');
      expect(otp, isNull);
    });

    test('returns null when otp is empty', () async {
      final otp = await datasourceFor({'otp': '  '})
          .forgotPassword('jane@test.com');
      expect(otp, isNull);
    });

    test('returns the otp when the API still echoes it', () async {
      final otp = await datasourceFor({'otp': '654321'})
          .forgotPassword('jane@test.com');
      expect(otp, '654321');
    });
  });

  group('send-email-otp debug OTP', () {
    test('returns null when the live envelope has no otp field', () async {
      final dio = Dio(BaseOptions(baseUrl: 'https://example.test'));
      dio.interceptors.add(
        _ScriptedInterceptor((options) {
          expect(options.path, ApiEndpoints.sendEmailOtp);
          return {'message': 'OTP sent'};
        }),
      );
      final otp = await AuthRemoteDataSourceImpl(dio).sendEmailOtp('a@b.com');
      expect(otp, isNull);
    });
  });
}
