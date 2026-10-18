// Orbit QA round: error text follows the app language (QA-V-2), the delivery
// client maps Dio errors (QA-V-3), RejectOrderSheet has one title (QA-V-5),
// phone numbers / order ids stay left-to-right in Arabic (QA-V-6), and a
// failed cart fetch is an error, not an empty cart (QA-V-10).
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:xstore/core/error/exceptions.dart';
import 'package:xstore/core/error/failures.dart';
import 'package:xstore/core/localization/app_localizations.dart';
import 'package:xstore/core/network/app_error_messages.dart';
import 'package:xstore/core/network/dio_error_mapper.dart';
import 'package:xstore/core/utils/extensions/context_extensions.dart';
import 'package:xstore/features/auth/domain/entities/user_entity.dart';
import 'package:xstore/features/auth/presentation/providers/auth_provider.dart';
import 'package:xstore/features/cart/domain/entities/cart_entity.dart';
import 'package:xstore/features/cart/presentation/providers/cart_dependencies.dart';
import 'package:xstore/features/cart/presentation/widgets/cart_consumer_body.dart';
import 'package:xstore/features/cart/presentation/widgets/cart_empty_state.dart';
import 'package:xstore/features/delivery/data/datasources/delivery_request_remote_datasource.dart';
import 'package:xstore/features/orders/domain/entities/order_entity.dart';
import 'package:xstore/features/orders/presentation/widgets/reject_order_sheet.dart';
import 'package:xstore/features/orders/presentation/widgets/vendor_order_card.dart';
import 'package:xstore/shared/widgets/app_snackbar.dart';
import 'package:xstore/shared/widgets/error_state_widget.dart';

import 'helpers/fake_async_auth_notifier.dart';
import 'helpers/stub_cart_repository.dart';

const _ar = Locale('ar');

Widget _app(Widget home, {Locale? locale}) => MaterialApp(
  locale: locale,
  localizationsDelegates: const [
    AppLocalizations.delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
  ],
  supportedLocales: AppLocalizations.supportedLocales,
  home: Scaffold(body: home),
);

/// Throws [error] for every request, like a transport that fails.
Dio _failingDio(DioException Function(RequestOptions) error) {
  final dio = Dio(BaseOptions(baseUrl: 'https://delivery.test'));
  dio.interceptors.add(
    InterceptorsWrapper(onRequest: (o, h) => h.reject(error(o))),
  );
  return dio;
}

OrderEntity _order() {
  final now = DateTime(2026, 7, 1);
  return OrderEntity(
    id: 'order_1',
    consumerId: 'c1',
    consumerName: 'Test Buyer',
    consumerPhone: '+20 101 987 6543',
    vendorId: 'v1',
    vendorName: 'Vendor',
    vendorStoreName: 'Store',
    items: const [],
    status: OrderStatus.pending,
    paymentMethod: PaymentMethod.cashOnDelivery,
    deliveryAddress: const OrderAddress(
      fullName: 'Test Buyer',
      phone: '+20 101 987 6543',
      street: '14 Road 9',
      city: 'Cairo',
      wilaya: 'Cairo',
    ),
    subtotal: 10,
    shippingCost: 0,
    discount: 0,
    total: 10,
    createdAt: now,
    updatedAt: now,
  );
}

class _FailingCartRepo extends StubCartRepository {
  var healed = false;

  @override
  Future<Either<Failure, CartEntity>> getCart(String consumerId) async =>
      healed ? super.getCart(consumerId) : Left(Failure.network('offline'));
}

void main() {
  final ar = lookupAppLocalizations(_ar);

  tearDown(() => errorMessagesInArabic = false);

  group('error text follows the app language (QA-V-2)', () {
    testWidgets('the English offline text a repository stored shows in Arabic', (
      tester,
    ) async {
      late BuildContext ctx;
      await tester.pumpWidget(
        _app(
          Builder(
            builder: (c) {
              ctx = c;
              return const SizedBox();
            },
          ),
          locale: _ar,
        ),
      );

      expect(ctx.localizedError(networkUnavailableMessageEn), ar.noInternet);
      expect(resolveAppError(ctx, networkUnavailableMessageEn), ar.noInternet);
      // A message the backend wrote (errorAr) is shown as sent.
      expect(ctx.localizedError('رسالة من الخادم'), 'رسالة من الخادم');
    });

    testWidgets('error state and snackbar both show the Arabic message', (
      tester,
    ) async {
      await tester.pumpWidget(
        _app(
          Builder(
            builder: (context) => Column(
              children: [
                const Expanded(
                  child: ErrorStateWidget(message: networkUnavailableMessageEn),
                ),
                TextButton(
                  onPressed: () =>
                      AppSnackbar.error(context, networkUnavailableMessageEn),
                  child: const Text('snack'),
                ),
              ],
            ),
          ),
          locale: _ar,
        ),
      );
      expect(find.text(ar.noInternet), findsOneWidget);

      await tester.tap(find.text('snack'));
      await tester.pump();
      expect(find.text(ar.noInternet), findsNWidgets(2));
      expect(find.textContaining('Network unavailable'), findsNothing);
    });

    test('mapper keeps the backend errorAr when the app is Arabic', () {
      errorMessagesInArabic = true;
      final e = DioException.badResponse(
        statusCode: 400,
        requestOptions: RequestOptions(path: '/x'),
        response: Response(
          requestOptions: RequestOptions(path: '/x'),
          statusCode: 400,
          data: {'isSuccess': false, 'errorEn': 'Bad thing', 'errorAr': 'شيء'},
        ),
      );
      expect(mapDioException(e).message, 'شيء');
    });
  });

  group('delivery client maps Dio errors (QA-V-3)', () {
    test('a 400 never surfaces Dio\'s own text', () async {
      final ds = DeliveryRequestRemoteDataSource(
        _failingDio(
          (o) => DioException.badResponse(
            statusCode: 400,
            requestOptions: o,
            response: Response(requestOptions: o, statusCode: 400),
          ),
        ),
      );
      await expectLater(
        ds.getCourierPackages('c1'),
        throwsA(
          isA<AppException>().having(
            (e) => e.message,
            'message',
            allOf(
              isNot(contains('exception was thrown')),
              equals(genericErrorMessage()),
            ),
          ),
        ),
      );
    });

    test('offline and Arabic give the localized offline message', () async {
      errorMessagesInArabic = true;
      final ds = DeliveryRequestRemoteDataSource(
        _failingDio(
          (o) => DioException(
            requestOptions: o,
            type: DioExceptionType.connectionError,
          ),
        ),
      );
      await expectLater(
        ds.getMyRequests('c1'),
        throwsA(
          isA<AppException>().having((e) => e.message, 'message', ar.noInternet),
        ),
      );
    });

    test('a ProblemDetails title from the backend is kept', () async {
      final ds = DeliveryRequestRemoteDataSource(
        _failingDio(
          (o) => DioException.badResponse(
            statusCode: 400,
            requestOptions: o,
            response: Response(
              requestOptions: o,
              statusCode: 400,
              data: {'title': 'Package already picked up'},
            ),
          ),
        ),
      );
      await expectLater(
        ds.markPickedUp('p1'),
        throwsA(
          isA<AppException>().having(
            (e) => e.message,
            'message',
            'Package already picked up',
          ),
        ),
      );
    });
  });

  testWidgets('RejectOrderSheet shows its title once (QA-V-5)', (tester) async {
    await tester.pumpWidget(_app(RejectOrderSheet(onConfirm: (_) async {})));
    final en = lookupAppLocalizations(const Locale('en'));
    expect(find.text(en.vendorRejectTitle), findsOneWidget);
  });

  group('LTR values in Arabic (QA-V-6)', () {
    testWidgets('vendor order card isolates phone and order id', (tester) async {
      await tester.pumpWidget(
        _app(
          SingleChildScrollView(
            child: VendorOrderCard(
              order: _order(),
              onConfirm: () {},
              onReject: () {},
              onProcessing: () {},
              onShipped: () {},
              onDelivered: () {},
            ),
          ),
          locale: _ar,
        ),
      );
      expect(find.text('\u2066+20 101 987 6543\u2069'), findsOneWidget);
      expect(find.textContaining('\u2066#XS-2024-001\u2069'), findsOneWidget);
    });

    testWidgets('English text is left untouched', (tester) async {
      late BuildContext ctx;
      await tester.pumpWidget(
        _app(
          Builder(
            builder: (c) {
              ctx = c;
              return const SizedBox();
            },
          ),
        ),
      );
      expect(ctx.ltr('+20 101 987 6543'), '+20 101 987 6543');
      expect(ctx.isolate('14 Road 9'), '14 Road 9');
      expect(ctx.orderRef('XS-1'), 'Order #XS-1');
    });
  });

  group('cart fetch failure (QA-V-10)', () {
    testWidgets('shows the error state with Retry, not the empty cart', (
      tester,
    ) async {
      final repo = _FailingCartRepo();
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            authProvider.overrideWith(
              () => FakeAuth(
                const UserEntity(
                  id: 'consumer_1',
                  name: 'Buyer',
                  email: 'b@test.com',
                  phoneNumber: '01012345678',
                ),
              ),
            ),
            cartRepositoryProvider.overrideWithValue(repo),
          ],
          child: _app(const CartConsumerBody()),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(ErrorStateWidget), findsOneWidget);
      expect(find.byType(CartEmptyState), findsNothing);

      repo.healed = true;
      await tester.tap(find.text('Retry'));
      await tester.pumpAndSettle();
      expect(find.byType(CartEmptyState), findsOneWidget);
    });
  });
}
