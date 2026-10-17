import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:xstore/core/mock/mock_config.dart';
import 'package:xstore/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:xstore/features/auth/domain/entities/login_params.dart';
import 'package:xstore/features/auth/domain/entities/user_entity.dart';
import 'package:xstore/features/listing/data/datasources/listing_remote_datasource.dart';
import 'package:xstore/features/notifications/data/datasources/notifications_remote_datasource.dart';
import 'package:xstore/features/notifications/data/models/register_device_token_request.dart';
import 'package:xstore/features/orders/data/datasources/orders_remote_datasource.dart';
import 'package:xstore/features/product/data/datasources/product_remote_datasource.dart';
import 'package:xstore/features/product/domain/entities/review_write_params.dart';

import 'qa/support/scripted_adapter.dart';

/// Method, path and body of each request, checked against the backend
/// Postman collection (v10). Paths are literals on purpose: they must not
/// drift together with `ApiEndpoints`.
void main() {
  late ScriptedAdapter adapter;
  late Dio dio;

  setUp(() {
    adapter = ScriptedAdapter();
    dio = scriptedDio(adapter);
  });

  RequestOptions only() => adapter.requests.single;

  final skipMock = MockConfig.useMock
      ? 'MOCK=true short-circuits the request'
      : null;

  group('auth', () {
    test('password login posts phoneNumber, password and rememberMe', () async {
      adapter.reply('POST', '/api/auth/login', 200, {
        'token': 't',
        'refreshToken': 'r',
      });

      final user = await AuthRemoteDataSourceImpl(dio).login(
        const LoginParams(
          emailOrPhone: '01012345678',
          password: '123456',
          rememberMe: true,
        ),
      );

      expect(only().method, 'POST');
      expect(only().uri.path, '/api/auth/login');
      expect(only().data, {
        'phoneNumber': '01012345678',
        'password': '123456',
        'rememberMe': true,
      });
      expect(user.token, 't');
    }, skip: skipMock);

    test('send-login-otp posts only the phoneNumber', () async {
      adapter.reply('POST', '/api/auth/send-login-otp', 200, {});

      await AuthRemoteDataSourceImpl(dio).sendLoginOtp('01012345678');

      expect(only().method, 'POST');
      expect(only().uri.path, '/api/auth/send-login-otp');
      expect(only().data, {'phoneNumber': '01012345678'});
    }, skip: skipMock);

    test('login-with-otp posts phoneNumber, otpToken and rememberMe', () async {
      adapter.reply('POST', '/api/auth/login-with-otp', 200, {
        'token': 't',
        'refreshToken': 'r',
      });

      await AuthRemoteDataSourceImpl(dio).loginWithOtp(
        phoneNumber: '01012345678',
        otpToken: '483921',
        rememberMe: true,
      );

      expect(only().method, 'POST');
      expect(only().uri.path, '/api/auth/login-with-otp');
      expect(only().data, {
        'phoneNumber': '01012345678',
        'otpToken': '483921',
        'rememberMe': true,
      });
    }, skip: skipMock);
  });

  group('notifications', () {
    late NotificationsRemoteDataSourceImpl datasource;

    setUp(() => datasource = NotificationsRemoteDataSourceImpl(dio));

    test('unread-count is GET ?role=ALL and reads a bare integer', () async {
      adapter.reply('GET', '/api/notifications/unread-count', 200, 4);

      final count = await datasource.unreadCount(UserRole.consumer);

      expect(only().method, 'GET');
      expect(only().uri.path, '/api/notifications/unread-count');
      expect(only().queryParameters, {'role': 'ALL'});
      expect(count, 4);
    });

    test('mark read is a bodyless PUT /{id}/read', () async {
      adapter.reply('PUT', '/api/notifications/n7/read', 200);

      await datasource.markRead('n7');

      expect(only().method, 'PUT');
      expect(only().uri.path, '/api/notifications/n7/read');
      expect(only().data, isNull);
    });

    test('mark all read is PUT read-all?role=ALL', () async {
      adapter.reply('PUT', '/api/notifications/read-all', 200);

      await datasource.markAllRead(UserRole.vendor);

      expect(only().method, 'PUT');
      expect(only().uri.path, '/api/notifications/read-all');
      expect(only().queryParameters, {'role': 'ALL'});
    });

    test('register device token is POST {token}', () async {
      adapter.reply('POST', '/api/notifications/device-token', 200);

      await datasource.registerDeviceToken(
        const RegisterDeviceTokenRequest(token: 'fcm-1'),
      );

      expect(only().method, 'POST');
      expect(only().uri.path, '/api/notifications/device-token');
      expect(only().data, {'token': 'fcm-1'});
    });

    test(
      'unregister device token is DELETE with {token} in the body',
      () async {
        adapter.reply('DELETE', '/api/notifications/device-token', 200);

        await datasource.unregisterDeviceToken(
          const RegisterDeviceTokenRequest(token: 'fcm-1'),
        );

        expect(only().method, 'DELETE');
        expect(only().uri.path, '/api/notifications/device-token');
        expect(only().data, {'token': 'fcm-1'});
      },
    );
  });

  group('listings', () {
    test('delete is a bodyless PUT /{id}/cancel', () async {
      adapter.reply('PUT', '/api/listings/42/cancel', 200);

      await ListingRemoteDataSourceImpl(dio).deleteListing('42');

      expect(only().method, 'PUT');
      expect(only().uri.path, '/api/listings/42/cancel');
      expect(only().data, isNull);
    }, skip: skipMock);

    test('pause is a bodyless PUT /{id}/deactivate', () async {
      adapter.reply('PUT', '/api/listings/42/deactivate', 200);

      await ListingRemoteDataSourceImpl(dio).deactivateListing('42');

      expect(only().method, 'PUT');
      expect(only().uri.path, '/api/listings/42/deactivate');
      expect(only().data, isNull);
    }, skip: skipMock);
  });

  group('orders', () {
    test(
      'delivery coordinates are PUT /api/orders/{id} {latitude, longitude}',
      () async {
        adapter.reply('PUT', '/api/orders/o9', 200);

        await OrdersRemoteDataSourceImpl(dio).updateDeliveryCoordinates(
          orderId: 'o9',
          latitude: 30.0131,
          longitude: 31.2089,
        );

        expect(only().method, 'PUT');
        expect(only().uri.path, '/api/orders/o9');
        expect(only().data, {'latitude': 30.0131, 'longitude': 31.2089});
      },
      skip: skipMock,
    );
  });

  group('reviews', () {
    test(
      'update is PUT /api/listings/{id}/reviews/{reviewId} {rating, comment}',
      () async {
        adapter.reply('PUT', '/api/listings/5/reviews/r9', 200, {
          'id': 'r9',
          'rating': 3.5,
          'comment': 'Updated review.',
        });

        await ProductRemoteDataSourceImpl(dio).updateReview(
          listingId: '5',
          reviewId: 'r9',
          params: const ReviewWriteParams(
            rating: 3.5,
            comment: 'Updated review.',
          ),
        );

        expect(only().method, 'PUT');
        expect(only().uri.path, '/api/listings/5/reviews/r9');
        expect(only().data, {'rating': 3.5, 'comment': 'Updated review.'});
      },
      skip: skipMock,
    );

    test(
      'delete is a bodyless DELETE /api/listings/{id}/reviews/{reviewId}',
      () async {
        adapter.reply('DELETE', '/api/listings/5/reviews/r9', 200);

        await ProductRemoteDataSourceImpl(
          dio,
        ).deleteReview(listingId: '5', reviewId: 'r9');

        expect(only().method, 'DELETE');
        expect(only().uri.path, '/api/listings/5/reviews/r9');
        expect(only().data, isNull);
      },
      skip: skipMock,
    );
  });
}
