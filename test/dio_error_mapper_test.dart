import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:xstore/core/error/exceptions.dart';
import 'package:xstore/core/network/app_error_messages.dart';
import 'package:xstore/core/network/dio_error_mapper.dart';

void main() {
  group('mapDioException', () {
    test('401 uses API error string instead of Dio status boilerplate', () {
      final err = DioException(
        requestOptions: RequestOptions(path: '/api/auth/login'),
        response: Response(
          requestOptions: RequestOptions(path: '/api/auth/login'),
          statusCode: 401,
          data: {'error': 'Invalid email or password.'},
        ),
        type: DioExceptionType.badResponse,
      );

      final mapped = mapDioException(err);

      expect(mapped, isA<UnauthorizedException>());
      expect(mapped.message, 'Invalid email or password.');
    });

    test('400 prefers ASP.NET validation errors over generic message', () {
      final err = DioException(
        requestOptions: RequestOptions(path: '/api/auth/consumer/register'),
        response: Response(
          requestOptions: RequestOptions(path: '/api/auth/consumer/register'),
          statusCode: 400,
          data: {
            'errors': {
              'Email': ['Email is already registered.'],
            },
          },
        ),
        type: DioExceptionType.badResponse,
      );

      final mapped = mapDioException(err);

      expect(mapped, isA<ServerException>());
      expect(mapped.message, 'Email is already registered.');
    });
    test('400 uses errorEn from the isSuccess/data envelope', () {
      final err = DioException(
        requestOptions: RequestOptions(path: '/api/listings'),
        response: Response(
          requestOptions: RequestOptions(path: '/api/listings'),
          statusCode: 400,
          data: {
            'isSuccess': false,
            'data': null,
            'errorEn':
                'Location data is required. Please provide X-Latitude and X-Longitude headers.',
            'errorAr': 'بيانات الموقع مطلوبة',
            'statusCode': 400,
          },
        ),
        type: DioExceptionType.badResponse,
      );

      final mapped = mapDioException(err);

      expect(mapped, isA<ServerException>());
      expect(
        mapped.message,
        'Location data is required. Please provide X-Latitude and X-Longitude headers.',
      );
    });

    test('403 uses errorEn from the isSuccess/data envelope', () {
      final err = DioException(
        requestOptions: RequestOptions(path: '/api/listings'),
        response: Response(
          requestOptions: RequestOptions(path: '/api/listings'),
          statusCode: 403,
          data: {
            'isSuccess': false,
            'data': null,
            'errorEn': 'Account must be verified to create listings.',
            'errorAr': 'يجب توثيق الحساب',
            'statusCode': 403,
          },
        ),
        type: DioExceptionType.badResponse,
      );

      final mapped = mapDioException(err);

      expect(mapped, isA<UnauthorizedException>());
      expect(mapped.message, 'Account must be verified to create listings.');
    });

    test('400 "verify your phone" maps to the stable phoneNotVerified code', () {
      final err = DioException(
        requestOptions: RequestOptions(path: '/api/orders'),
        response: Response(
          requestOptions: RequestOptions(path: '/api/orders'),
          statusCode: 400,
          data: {
            'isSuccess': false,
            'data': null,
            'errorEn': 'Please verify your phone number before placing an order',
            'errorAr': 'يرجى تأكيد رقم هاتفك قبل تقديم الطلب',
            'statusCode': 400,
          },
        ),
        type: DioExceptionType.badResponse,
      );

      final mapped = mapDioException(err);

      expect(mapped, isA<ServerException>());
      expect(mapped.message, phoneNotVerifiedErrorCode);
    });

    test('403 "store location" maps to the stable storeLocationRequired code', () {
      final err = DioException(
        requestOptions: RequestOptions(path: '/api/listings'),
        response: Response(
          requestOptions: RequestOptions(path: '/api/listings'),
          statusCode: 403,
          data: {
            'isSuccess': false,
            'data': null,
            'errorEn':
                'Store location (latitude/longitude) must be set before creating a listing.',
            'errorAr': 'يجب تعيين موقع المتجر',
            'statusCode': 403,
          },
        ),
        type: DioExceptionType.badResponse,
      );

      final mapped = mapDioException(err);

      expect(mapped, isA<ServerException>());
      expect(mapped.message, storeLocationRequiredErrorCode);
    });

    test('500 replaces opaque EF SaveChanges boilerplate', () {
      final err = DioException(
        requestOptions: RequestOptions(path: '/api/listings'),
        response: Response(
          requestOptions: RequestOptions(path: '/api/listings'),
          statusCode: 500,
          data: {
            'error':
                'An error occurred while saving the entity changes. See the inner exception for details.',
          },
        ),
        type: DioExceptionType.badResponse,
      );

      final mapped = mapDioException(err);

      expect(mapped, isA<ServerException>());
      expect(
        mapped.message,
        'The server could not save your changes. Please try again later.',
      );
    });
  });
}
