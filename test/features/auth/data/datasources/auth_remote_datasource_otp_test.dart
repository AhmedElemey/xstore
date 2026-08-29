import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:xstore/core/error/exceptions.dart';
import 'package:xstore/core/network/api_endpoints.dart';
import 'package:xstore/core/network/app_error_messages.dart';
import 'package:xstore/features/auth/data/datasources/auth_remote_datasource.dart';

/// Resolves (or rejects) every request with a scripted value instead of
/// hitting the network — same approach as the wishlist datasource tests.
class _ScriptedInterceptor extends Interceptor {
  _ScriptedInterceptor(this._respond);

  final Object? Function(RequestOptions options) _respond;
  RequestOptions? captured;

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    captured = options;
    final result = _respond(options);
    if (result is DioException) {
      handler.reject(result);
    } else {
      handler.resolve(
        Response(requestOptions: options, statusCode: 200, data: result),
      );
    }
  }
}

DioException _badResponse(
  RequestOptions options,
  int statusCode, {
  Object? data,
}) =>
    DioException(
      requestOptions: options,
      type: DioExceptionType.badResponse,
      response: Response(
        requestOptions: options,
        statusCode: statusCode,
        data: data,
      ),
    );

void main() {
  late Dio dio;
  late AuthRemoteDataSourceImpl datasource;

  Dio buildDio(Object? Function(RequestOptions options) respond) {
    final d = Dio(BaseOptions(baseUrl: 'https://example.test'));
    d.interceptors.add(_ScriptedInterceptor(respond));
    return d;
  }

  AuthRemoteDataSourceImpl datasourceFor(Object? body) {
    dio = buildDio((_) => body);
    datasource = AuthRemoteDataSourceImpl(dio);
    return datasource;
  }

  group('forgotPassword debug OTP', () {
    test('returns null when the response has no otp field', () async {
      final otp = await datasourceFor({'message': 'sent'})
          .forgotPassword('jane@test.com');
      expect(otp, isNull);
    });

    test('returns null when otp is empty', () async {
      final otp =
          await datasourceFor({'otp': '  '}).forgotPassword('jane@test.com');
      expect(otp, isNull);
    });

    test('returns the otp when the API still echoes it', () async {
      final otp = await datasourceFor({'otp': '654321'})
          .forgotPassword('jane@test.com');
      expect(otp, '654321');
    });
  });

  group('sendEmailOtp', () {
    test('POSTs {email} to /api/auth/send-email-otp', () async {
      RequestOptions? captured;
      dio = buildDio((options) {
        captured = options;
        return {'message': 'OTP sent'};
      });
      datasource = AuthRemoteDataSourceImpl(dio);

      final otp = await datasource.sendEmailOtp('a@b.com');

      expect(captured!.method, 'POST');
      expect(captured!.path, ApiEndpoints.sendEmailOtp);
      expect(captured!.data, {'email': 'a@b.com'});
      expect(otp, isNull);
    });

    test('returns the debug OTP when the envelope still echoes it', () async {
      dio = buildDio((_) => {'otp': '111222'});
      datasource = AuthRemoteDataSourceImpl(dio);

      expect(await datasource.sendEmailOtp('a@b.com'), '111222');
    });

    test('maps a 500 response to a ServerException', () async {
      dio = buildDio((options) => _badResponse(options, 500));
      datasource = AuthRemoteDataSourceImpl(dio);

      expect(
        () => datasource.sendEmailOtp('a@b.com'),
        throwsA(isA<ServerException>()),
      );
    });
  });

  group('verifyEmailOtp', () {
    test('POSTs {email, otpToken} to /api/auth/verify-email', () async {
      RequestOptions? captured;
      dio = buildDio((options) {
        captured = options;
        return null;
      });
      datasource = AuthRemoteDataSourceImpl(dio);

      await datasource.verifyEmailOtp(
        email: 'a@b.com',
        otpToken: '123456',
      );

      expect(captured!.method, 'POST');
      expect(captured!.path, ApiEndpoints.verifyEmail);
      expect(captured!.data, {'email': 'a@b.com', 'otpToken': '123456'});
    });

    test('maps a 400 invalid-OTP body to a ServerException', () async {
      dio = buildDio(
        (options) => _badResponse(
          options,
          400,
          data: {
            'isSuccess': false,
            'errorEn': 'Invalid OTP token.',
          },
        ),
      );
      datasource = AuthRemoteDataSourceImpl(dio);

      expect(
        () => datasource.verifyEmailOtp(email: 'a@b.com', otpToken: '000000'),
        throwsA(
          isA<ServerException>().having(
            (e) => e.message,
            'message',
            'Invalid OTP token.',
          ),
        ),
      );
    });
  });

  group('sendPhoneOtpBackend', () {
    test('POSTs {phoneNumber} to /api/auth/send-phone-otp', () async {
      RequestOptions? captured;
      dio = buildDio((options) {
        captured = options;
        return {'message': 'OTP sent'};
      });
      datasource = AuthRemoteDataSourceImpl(dio);

      final otp = await datasource.sendPhoneOtpBackend('01012345678');

      expect(captured!.method, 'POST');
      expect(captured!.path, ApiEndpoints.sendPhoneOtp);
      expect(captured!.data, {'phoneNumber': '01012345678'});
      expect(otp, isNull);
    });

    test(
      'maps the live email-before-phone 400 text to emailRequiredBeforePhoneErrorCode',
      () async {
        dio = buildDio(
          (options) => _badResponse(
            options,
            400,
            data: {
              'isSuccess': false,
              'data': null,
              'errorEn':
                  'Please add and verify your email address before requesting a phone OTP.',
              'errorAr': 'يرجى تأكيد البريد',
            },
          ),
        );
        datasource = AuthRemoteDataSourceImpl(dio);

        expect(
          () => datasource.sendPhoneOtpBackend('01012345678'),
          throwsA(
            isA<ServerException>().having(
              (e) => e.message,
              'message',
              emailRequiredBeforePhoneErrorCode,
            ),
          ),
        );
      },
    );

    test(
      'also maps the shorter "phone otp" wording to the same error code',
      () async {
        dio = buildDio(
          (options) => _badResponse(
            options,
            400,
            data: {
              'errorEn': 'Please verify your email before a phone OTP.',
            },
          ),
        );
        datasource = AuthRemoteDataSourceImpl(dio);

        expect(
          () => datasource.sendPhoneOtpBackend('01012345678'),
          throwsA(
            isA<ServerException>().having(
              (e) => e.message,
              'message',
              emailRequiredBeforePhoneErrorCode,
            ),
          ),
        );
      },
    );
  });

  group('verifyPhoneOtpBackend', () {
    test('POSTs {phoneNumber, otpToken} to /api/auth/verify-phone', () async {
      RequestOptions? captured;
      dio = buildDio((options) {
        captured = options;
        return null;
      });
      datasource = AuthRemoteDataSourceImpl(dio);

      await datasource.verifyPhoneOtpBackend(
        phoneNumber: '01012345678',
        otpToken: '654321',
      );

      expect(captured!.method, 'POST');
      expect(captured!.path, ApiEndpoints.verifyPhone);
      expect(captured!.data, {
        'phoneNumber': '01012345678',
        'otpToken': '654321',
      });
    });

    test('maps a 400 invalid-OTP body to a ServerException', () async {
      dio = buildDio(
        (options) => _badResponse(
          options,
          400,
          data: {
            'isSuccess': false,
            'errorEn': 'Invalid OTP token.',
          },
        ),
      );
      datasource = AuthRemoteDataSourceImpl(dio);

      expect(
        () => datasource.verifyPhoneOtpBackend(
          phoneNumber: '01012345678',
          otpToken: '000000',
        ),
        throwsA(isA<ServerException>()),
      );
    });
  });

  group('verifyForgotPasswordOtp', () {
    test(
      'POSTs {email, otpToken, newPassword, confirmNewPassword} to verify-forget-password-otp',
      () async {
        RequestOptions? captured;
        dio = buildDio((options) {
          captured = options;
          return null;
        });
        datasource = AuthRemoteDataSourceImpl(dio);

        await datasource.verifyForgotPasswordOtp(
          email: 'jane@test.com',
          otpToken: '654321',
          newPassword: 'NewPass1!',
          confirmNewPassword: 'NewPass1!',
        );

        expect(captured!.method, 'POST');
        expect(captured!.path, ApiEndpoints.verifyForgotPasswordOtp);
        expect(captured!.data, {
          'email': 'jane@test.com',
          'otpToken': '654321',
          'newPassword': 'NewPass1!',
          'confirmNewPassword': 'NewPass1!',
        });
      },
    );

    test('maps a 400 invalid-OTP body to a ServerException', () async {
      dio = buildDio(
        (options) => _badResponse(
          options,
          400,
          data: {
            'isSuccess': false,
            'errorEn': 'Invalid or expired OTP.',
          },
        ),
      );
      datasource = AuthRemoteDataSourceImpl(dio);

      expect(
        () => datasource.verifyForgotPasswordOtp(
          email: 'jane@test.com',
          otpToken: '000000',
          newPassword: 'NewPass1!',
          confirmNewPassword: 'NewPass1!',
        ),
        throwsA(
          isA<ServerException>().having(
            (e) => e.message,
            'message',
            'Invalid or expired OTP.',
          ),
        ),
      );
    });
  });
}
