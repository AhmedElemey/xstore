// QA suite (2026-09-24), round 2 Flutter fixes: the cart survives an app
// restart, the `0001-01-01` birth-date sentinel reads as unset, and server
// errors follow the app language.
import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:xstore/core/error/exceptions.dart';
import 'package:xstore/core/localization/app_localizations.dart';
import 'package:xstore/core/localization/localization_provider.dart';
import 'package:xstore/core/mock/mock_config.dart';
import 'package:xstore/core/network/app_error_messages.dart';
import 'package:xstore/core/network/dio_error_mapper.dart';
import 'package:xstore/features/auth/data/models/user_model.dart';
import 'package:xstore/features/cart/data/datasources/cart_remote_datasource.dart';
import 'package:xstore/features/cart/domain/entities/cart_item_entity.dart';
import 'package:xstore/features/orders/data/datasources/orders_remote_datasource.dart';

import 'support/scripted_adapter.dart';

CartItemEntity _line(String id, String listingId, {int qty = 1}) =>
    CartItemEntity(
      id: id,
      listingId: listingId,
      listingName: 'Item $id',
      listingImage: 'https://img/$id.jpg',
      vendorId: 'v1',
      vendorName: 'Vendor',
      vendorStoreName: 'Store',
      price: 150.5,
      compareAtPrice: 200,
      quantity: qty,
      maxQuantity: 5,
      category: 'Electronics',
      condition: 'new',
      shippingAvailable: true,
      shippingCost: 30,
      addedAt: DateTime(2026, 9, 24, 10),
    );

CartRemoteDataSourceImpl _newDataSource() {
  final dio = scriptedDio(ScriptedAdapter());
  return CartRemoteDataSourceImpl(dio, OrdersRemoteDataSourceImpl(dio));
}

/// Simulates killing and relaunching the app: the static in-memory cart is
/// gone, the device's SharedPreferences are not.
void _restartApp() => CartRemoteDataSourceImpl.clearSessionCache();

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Cart survives an app restart (#15)', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
      CartRemoteDataSourceImpl.clearSessionCache();
    });

    test('lines added before a restart are there after it, unchanged',
        () async {
      await _newDataSource()
          .addOrUpdateItem(consumerId: '6', item: _line('a', '1', qty: 2));
      await _newDataSource()
          .addOrUpdateItem(consumerId: '6', item: _line('b', '2'));
      _restartApp();

      final cart = await _newDataSource().getCart('6');
      expect(cart.items.map((e) => e.id), ['a', 'b']);
      final a = cart.items.first;
      expect(a.quantity, 2);
      expect(a.price, 150.5);
      expect(a.compareAtPrice, 200);
      expect(a.shippingCost, 30);
      expect(a.listingImage, 'https://img/a.jpg');
      expect(a.addedAt, DateTime(2026, 9, 24, 10));
    });

    test('another user on the same phone never sees it', () async {
      await _newDataSource()
          .addOrUpdateItem(consumerId: '6', item: _line('a', '1'));
      _restartApp();
      expect((await _newDataSource().getCart('7')).items, isEmpty);
      _restartApp();
      expect((await _newDataSource().getCart('6')).items, hasLength(1));
    });

    test('removing, clearing and quantity changes are persisted', () async {
      final ds = _newDataSource();
      await ds.addOrUpdateItem(consumerId: '6', item: _line('a', '1'));
      await ds.addOrUpdateItem(consumerId: '6', item: _line('b', '2'));
      await ds.updateQuantity(consumerId: '6', itemId: 'a', quantity: 4);
      await ds.removeItem(consumerId: '6', itemId: 'b');
      _restartApp();
      final after = await _newDataSource().getCart('6');
      expect(after.items.map((e) => (e.id, e.quantity)), [('a', 4)]);

      await _newDataSource().clearCart('6');
      _restartApp();
      expect((await _newDataSource().getCart('6')).items, isEmpty);
    });

    test('adding right after launch keeps the saved lines too', () async {
      await _newDataSource()
          .addOrUpdateItem(consumerId: '6', item: _line('a', '1'));
      _restartApp();
      // No getCart first: the add itself must restore before saving.
      await _newDataSource()
          .addOrUpdateItem(consumerId: '6', item: _line('b', '2'));
      _restartApp();
      final cart = await _newDataSource().getCart('6');
      expect(cart.items.map((e) => e.id), unorderedEquals(['a', 'b']));
    });

    test('a corrupted saved cart is an empty cart, not a crash', () async {
      SharedPreferences.setMockInitialValues({'cart_items_v1_6': '{nope'});
      expect((await _newDataSource().getCart('6')).items, isEmpty);
    });

    test('a saved line with a missing/invalid field is dropped', () async {
      SharedPreferences.setMockInitialValues({
        'cart_items_v1_6': jsonEncode([
          {'id': 'x', 'listingId': '9', 'price': 10, 'quantity': 0},
          {'id': 'y', 'price': 10, 'quantity': 1},
        ]),
      });
      expect((await _newDataSource().getCart('6')).items, isEmpty);
    });
  }, skip: MockConfig.useMock ? 'Mock mode seeds its own cart' : false);

  group('Birth-date sentinel (#13)', () {
    Map<String, dynamic> profile(String birthDate) => {
          'user': {
            'id': 6,
            'fullName': 'مختبر الجودة',
            'email': 'qa@example.com',
            'phoneNumber': '01557719930',
            'birthDate': birthDate,
            'roleName': 'Consumer',
          },
          'store': null,
          'isEmailVerified': false,
          'isPhoneVerified': false,
          'hasPassword': true,
        };

    test('live "0001-01-01T00:00:00" (C# default) reads as not set', () {
      final m = userModelFromProfileResponse(profile('0001-01-01T00:00:00'));
      expect(m.dateOfBirth, isNull);
    });

    test('a real birth date is kept as the calendar date', () {
      final m = userModelFromProfileResponse(profile('1995-03-14T00:00:00'));
      expect(m.dateOfBirth, DateTime(1995, 3, 14));
    });
  });

  group('Server errors follow the app language', () {
    tearDown(() => errorMessagesInArabic = false);

    DioException bad(int status, Map<String, Object?> body) {
      final req = RequestOptions(path: '/x');
      return DioException(
        requestOptions: req,
        type: DioExceptionType.badResponse,
        response: Response<dynamic>(
          requestOptions: req,
          statusCode: status,
          data: body,
        ),
      );
    }

    final loginFailed = {
      'isSuccess': false,
      'errorEn': 'Invalid Phone Number or password.',
      'errorAr': 'رقم الهاتف أو كلمة المرور غير صالحة',
      'statusCode': 401,
    };

    test('English app shows errorEn', () {
      expect(mapDioException(bad(401, loginFailed)).message,
          'Invalid Phone Number or password.');
    });

    test('Arabic app shows errorAr', () {
      errorMessagesInArabic = true;
      expect(mapDioException(bad(401, loginFailed)).message,
          'رقم الهاتف أو كلمة المرور غير صالحة');
    });

    test('Arabic app still maps stable codes (matching keys on errorEn)', () {
      errorMessagesInArabic = true;
      final e = mapDioException(bad(400, {
        'errorEn': 'Please verify your phone number before placing an order',
        'errorAr': 'يرجى تأكيد رقم هاتفك قبل تقديم الطلب',
      }));
      expect(e.message, phoneNotVerifiedErrorCode);
    });

    test('Arabic app falls back to errorEn when errorAr is missing', () {
      errorMessagesInArabic = true;
      expect(mapDioException(bad(404, {'errorEn': 'Listing not found.'})).message,
          'Listing not found.');
    });

    test('no-connection message is Arabic in an Arabic app', () {
      errorMessagesInArabic = true;
      final e = mapDioException(DioException(
        requestOptions: RequestOptions(),
        type: DioExceptionType.connectionError,
      ));
      expect(e, isA<NetworkException>());
      expect(e.message,
          lookupAppLocalizations(const Locale('ar')).noInternet);
    });

    test('switching the app language updates the mapper', () async {
      SharedPreferences.setMockInitialValues({});
      final container = ProviderContainer();
      addTearDown(container.dispose);
      final notifier = container.read(appLocaleProvider.notifier);
      await notifier.setLanguage(AppLanguage.arabic);
      expect(errorMessagesInArabic, isTrue);
      await notifier.setLanguage(AppLanguage.english);
      expect(errorMessagesInArabic, isFalse);
    });

    test('a saved Arabic preference applies on launch', () async {
      SharedPreferences.setMockInitialValues({'app_language': 'arabic'});
      final container = ProviderContainer();
      addTearDown(container.dispose);
      container.read(appLocaleProvider);
      await Future<void>.delayed(Duration.zero);
      await Future<void>.delayed(Duration.zero);
      expect(container.read(appLocaleProvider), AppLanguage.arabic);
      expect(errorMessagesInArabic, isTrue);
    });

    testWidgets('rate-limit message is localized', (tester) async {
      late String ar;
      await tester.pumpWidget(MaterialApp(
        locale: const Locale('ar'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Builder(builder: (context) {
          ar = resolveAppError(context, rateLimitErrorCode);
          return const SizedBox();
        }),
      ));
      expect(ar, lookupAppLocalizations(const Locale('ar')).phoneTooManyRequests);
    });
  });
}
