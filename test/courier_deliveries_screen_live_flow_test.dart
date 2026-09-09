// Screen-level, LIVE-mode test of the real CourierDeliveriesScreen — a
// real courier viewing their active/finished run and cash-in-hand, not
// fixture data. Matches test/orders_screen_live_flow_test.dart's
// established pattern: real screen + real OrdersRepositoryImpl ->
// OrdersRemoteDataSourceImpl chain, only the Dio HTTP transport is
// scripted. The existing test/courier_deliveries_screen_test.dart covers
// this screen with fixture data only — this file is additive.
//
// This screen also fetches courierPackagesProvider (delivery requests,
// on delivery's OWN Dio client — see send_package_screen_live_flow_test
// .dart) and courierCashWalletProvider (which independently re-fetches
// the SAME GET .../orders/courier/{id} endpoint with a larger page size
// to sum cash-in-hand — since the scripted interceptor keys only on
// method+path, not query params, one scripted route correctly serves
// both callers). The packages endpoint is scripted to return an empty
// list so the test stays focused on the orders side.
//
// GetCourierOrdersUseCase/markDelivered go through
// OrdersRemoteDataSourceImpl, which DOES branch on MockConfig — this
// test needs the usual `skip: MockConfig.useMock`.
//
// Run with: flutter test test/courier_deliveries_screen_live_flow_test.dart
import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:xstore/core/localization/app_localizations.dart';
import 'package:xstore/core/mock/mock_config.dart';
import 'package:xstore/core/network/api_endpoints.dart';
import 'package:xstore/core/network/delivery_api_endpoints.dart';
import 'package:xstore/core/network/dio_provider.dart';
import 'package:xstore/features/auth/domain/entities/user_entity.dart';
import 'package:xstore/features/auth/presentation/providers/auth_provider.dart';
import 'package:xstore/features/delivery/data/delivery_dio_provider.dart';
import 'package:xstore/features/delivery/presentation/providers/courier_deliveries_provider.dart';
import 'package:xstore/features/delivery/presentation/providers/courier_packages_provider.dart';
import 'package:xstore/features/delivery/presentation/screens/courier_deliveries_screen.dart';

/// Routes each request by (method, path) to a scripted response — same
/// technique as orders_screen_live_flow_test.dart's `_RoutedInterceptor`.
class _RoutedInterceptor extends Interceptor {
  _RoutedInterceptor(this._routes);

  final Map<String, Object? Function(RequestOptions options)> _routes;

  String _key(RequestOptions o) => '${o.method} ${o.path}';

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final route = _routes[_key(options)];
    if (route == null) {
      handler.reject(
        DioException(
          requestOptions: options,
          error: StateError('unscripted request: ${_key(options)}'),
        ),
      );
      return;
    }
    final result = route(options);
    if (result is DioException) {
      handler.reject(result);
    } else {
      handler.resolve(
        Response(requestOptions: options, statusCode: 200, data: result),
      );
    }
  }
}

Dio _fakeDio(
  String baseUrl,
  Map<String, Object? Function(RequestOptions)> routes,
) {
  final d = Dio(BaseOptions(baseUrl: baseUrl));
  d.interceptors.add(_RoutedInterceptor(routes));
  return d;
}

class _FakeAuth extends Auth {
  _FakeAuth(this._user);
  final UserEntity? _user;
  @override
  Future<UserEntity?> build() async => _user;
}

UserEntity _courier() => const UserEntity(
  id: 'courier_1',
  name: 'Test Courier',
  email: 'courier@test.com',
  phoneNumber: '01012345678',
  role: UserRole.courier,
);

Map<String, dynamic> _orderJson({
  String id = '700',
  String status = 'shipped',
  double total = 500,
}) => {
  'id': id,
  'consumerId': 'consumer_1',
  'consumerName': 'Test Buyer',
  'consumerPhone': '01012345678',
  'vendorId': 'vendor_1',
  'vendorName': 'Ahmed',
  'vendorStoreName': 'Ahmed Store',
  'status': status,
  'listingId': '9001',
  'listingName': 'Wireless Earbuds',
  'quantity': 1,
  'price': total,
  'total': total,
  'courierId': 'courier_1',
  'createdAt': '2026-08-01T00:00:00.000Z',
  'updatedAt': '2026-08-01T00:00:00.000Z',
};

Widget _harness(List<Override> overrides) => ProviderScope(
  overrides: overrides,
  child: const MaterialApp(
    localizationsDelegates: [
      AppLocalizations.delegate,
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
    ],
    supportedLocales: AppLocalizations.supportedLocales,
    // CourierDeliveriesScreen renders its own Scaffold, and neither test
    // below navigates away from it, so no extra Navigator scaffolding is
    // needed here.
    home: CourierDeliveriesScreen(),
  ),
);

/// Bounded frame pump instead of `pumpAndSettle()` — matches the
/// established convention from orders_screen_live_flow_test.dart.
Future<void> _settle(
  WidgetTester tester, {
  int times = 15,
  Duration step = const Duration(milliseconds: 100),
}) async {
  for (var i = 0; i < times; i++) {
    await tester.pump(step);
  }
}

/// Pumps the screen, then explicitly (re-)fetches once `authProvider` has
/// actually resolved — `CourierDeliveriesScreen`'s postFrameCallback only
/// calls `fetchOrders()`/`fetchPackages()` when `authProvider` is ALREADY
/// resolved at that instant (both notifiers' synchronous `ref.read`), the
/// same race orders_screen_live_flow_test.dart's `_pumpReady` works
/// around.
Future<ProviderContainer> _pumpReady(
  WidgetTester tester,
  List<Override> overrides,
) async {
  await tester.pumpWidget(_harness(overrides));
  await tester.pump();
  final container = ProviderScope.containerOf(
    tester.element(find.byType(CourierDeliveriesScreen)),
    listen: false,
  );
  await container.read(authProvider.future);
  // Deliberately not awaited — see the FakeAsync-zone note in
  // orders_screen_live_flow_test.dart's `_pumpReady`.
  unawaited(container.read(courierDeliveriesProvider.notifier).fetchOrders());
  unawaited(
    container.read(courierPackagesProvider.notifier).fetchPackages(),
  );
  return container;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    FlutterSecureStorage.setMockInitialValues({});
  });

  testWidgets(
    'courier views their active run and cash-in-hand from live orders',
    skip: MockConfig.useMock,
    (tester) async {
      final ordersDio = _fakeDio(ApiEndpoints.baseUrl, {
        'GET ${ApiEndpoints.ordersCourier('courier_1')}': (_) => [
          _orderJson(id: '700', status: 'shipped', total: 500),
          _orderJson(id: '701', status: 'delivered', total: 300),
        ],
      });
      final deliveryDio = _fakeDio(DeliveryApiEndpoints.baseUrl, {
        'GET ${DeliveryApiEndpoints.deliveryRequestsCourierMine}': (_) => [],
      });

      await _pumpReady(tester, [
        authProvider.overrideWith(() => _FakeAuth(_courier())),
        dioProvider.overrideWithValue(ordersDio),
        deliveryDioProvider.overrideWithValue(deliveryDio),
      ]);
      await _settle(tester);

      expect(find.text('Active'), findsOneWidget);
      expect(find.text('History'), findsOneWidget);
      // Cash-in-hand sums only the delivered, unpaid-COD order (300) —
      // the same amount also renders on that order's own history card, so
      // this legitimately matches twice (see the cash summary header AND
      // the card's own collected-amount line).
      expect(find.text('EGP 300'), findsWidgets);
    },
  );

  testWidgets(
    'courier marks a shipped order delivered via the live PUT wire call',
    skip: MockConfig.useMock,
    (tester) async {
      var status = 'shipped';
      final ordersDio = _fakeDio(ApiEndpoints.baseUrl, {
        'GET ${ApiEndpoints.ordersCourier('courier_1')}': (_) => [
          _orderJson(id: '700', status: status, total: 500),
        ],
        'PUT ${ApiEndpoints.vendorOrdersStatus}': (_) {
          status = 'delivered';
          return _orderJson(id: '700', status: status, total: 500);
        },
      });
      final deliveryDio = _fakeDio(DeliveryApiEndpoints.baseUrl, {
        'GET ${DeliveryApiEndpoints.deliveryRequestsCourierMine}': (_) => [],
      });

      await _pumpReady(tester, [
        authProvider.overrideWith(() => _FakeAuth(_courier())),
        dioProvider.overrideWithValue(ordersDio),
        deliveryDioProvider.overrideWithValue(deliveryDio),
      ]);
      await _settle(tester);

      expect(find.text('Active'), findsOneWidget);

      await tester.tap(find.text('Delivered'));
      await _settle(tester);

      // The dialog's confirm button shares the card action's label — the
      // dialog's own button is the LAST match once it's open.
      await tester.tap(find.text('Delivered').last);
      await _settle(tester);

      expect(find.text('History'), findsOneWidget);
    },
  );
}
