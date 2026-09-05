// Screen-level, LIVE-mode (MOCK=false) test of the real, standalone
// OrderDetailScreen — a real user tapping through the app, not fixture
// data. Matches test/orders_screen_live_flow_test.dart's established
// pattern: real screen + real OrderDetailNotifier -> OrdersRepositoryImpl
// -> OrdersRemoteDataSourceImpl chain, only the Dio HTTP transport is
// scripted.
//
// This exercises a DIFFERENT provider (`orderDetailNotifierProvider`,
// family-keyed by orderId) than orders_screen_live_flow_test.dart's
// `ordersNotifierProvider` — same underlying use cases, but a distinct
// code path (OrderActionButtons / OrderDetailNotifier), so it is not
// redundant with that file even though some flows look similar.
//
// Run with: flutter test test/order_detail_screen_live_flow_test.dart
import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:xstore/core/analytics/analytics_service.dart';
import 'package:xstore/core/localization/app_localizations.dart';
import 'package:xstore/core/mock/mock_config.dart';
import 'package:xstore/core/network/api_endpoints.dart';
import 'package:xstore/core/network/dio_provider.dart';
import 'package:xstore/features/auth/domain/entities/user_entity.dart';
import 'package:xstore/features/auth/presentation/providers/auth_provider.dart';
import 'package:xstore/features/orders/presentation/providers/order_detail_provider.dart';
import 'package:xstore/features/orders/presentation/screens/order_detail_screen.dart';

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

Dio _fakeDio(Map<String, Object? Function(RequestOptions)> routes) {
  final d = Dio(BaseOptions(baseUrl: ApiEndpoints.baseUrl));
  d.interceptors.add(_RoutedInterceptor(routes));
  return d;
}

class _FakeAuth extends Auth {
  _FakeAuth(this._user);
  final UserEntity? _user;
  @override
  Future<UserEntity?> build() async => _user;
}

UserEntity _consumer() => const UserEntity(
  id: 'consumer_1',
  name: 'Test Buyer',
  email: 'buyer@test.com',
  phoneNumber: '01012345678',
);

UserEntity _vendor() => const UserEntity(
  id: 'vendor_1',
  name: 'Test Vendor',
  email: 'vendor@test.com',
  phoneNumber: '01099999999',
  role: UserRole.vendor,
);

/// Flat (non-nested `items`/`listing`) order shape — the same wire
/// contract orders_screen_live_flow_test.dart's fixtures use, parsed by
/// `_orderFromApiMap`'s `_itemFromFlatOrder` fallback.
Map<String, dynamic> _orderJson({
  String id = '501',
  String status = 'pending',
  String listingId = '9001',
  String consumerId = 'consumer_1',
}) => {
  'id': id,
  'consumerId': consumerId,
  'consumerName': 'Test Buyer',
  'consumerPhone': '01012345678',
  'vendorId': 'vendor_1',
  'vendorName': 'Ahmed',
  'vendorStoreName': 'Ahmed Store',
  'status': status,
  'listingId': listingId,
  'listingName': 'Wireless Earbuds',
  'quantity': 1,
  'price': 50000,
  'total': 50000,
  'createdAt': '2026-08-01T00:00:00.000Z',
  'updatedAt': '2026-08-01T00:00:00.000Z',
};

Widget _harness(List<Override> overrides, String orderId) => ProviderScope(
  overrides: overrides,
  child: MaterialApp(
    localizationsDelegates: const [
      AppLocalizations.delegate,
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
    ],
    supportedLocales: AppLocalizations.supportedLocales,
    // OrderDetailScreen renders its own Scaffold, so no extra Material
    // wrapper is needed here (unlike OrdersScreen).
    home: OrderDetailScreen(orderId: orderId),
  ),
);

/// Pumps the screen, then explicitly (re-)fetches the order once
/// `authProvider` has actually resolved. `OrderDetailScreen` fires its
/// one-shot `fetchOrder()` from an `initState` postFrameCallback — a
/// single call that reads `authProvider` synchronously at that instant
/// (`OrderDetailNotifier._consumerId`/`_vendorId`) and, if it's still
/// `AsyncLoading`, proceeds with a null id, which the repository maps to
/// `Failure.unauthorized()` rather than retrying later. Same race as
/// orders_screen_live_flow_test.dart's `_pumpReady`.
Future<ProviderContainer> _pumpReady(
  WidgetTester tester,
  List<Override> overrides,
  String orderId,
) async {
  await tester.pumpWidget(_harness(overrides, orderId));
  await tester.pump();
  final container = ProviderScope.containerOf(
    tester.element(find.byType(OrderDetailScreen)),
    listen: false,
  );
  await container.read(authProvider.future);
  // Deliberately not awaited — see the FakeAsync-zone note in
  // orders_screen_live_flow_test.dart's `_pumpReady`.
  unawaited(
    container.read(orderDetailNotifierProvider(orderId).notifier).fetchOrder(),
  );
  return container;
}

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

Future<void> _awaitAnalyticsReady(ProviderContainer container) async {
  await container.read(analyticsServiceProvider).ready;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    FlutterSecureStorage.setMockInitialValues({});
  });

  testWidgets(
    'consumer views a live order\'s full detail — items, seller, and address render from the wire response',
    skip: MockConfig.useMock,
    (tester) async {
      final dio = _fakeDio({
        'GET ${ApiEndpoints.orderMeById('501')}': (_) => _orderJson(),
      });

      final container = await _pumpReady(tester, [
        authProvider.overrideWith(() => _FakeAuth(_consumer())),
        dioProvider.overrideWithValue(dio),
      ], '501');
      await _settle(tester);

      expect(find.textContaining('Order #'), findsOneWidget);
      // "Pending" appears both in the status banner and the order
      // timeline's step labels — assert presence, not a unique count.
      expect(find.text('Pending'), findsWidgets);
      // The item tile renders just below the initial viewport inside the
      // screen's CustomScrollView — it's already built (within the
      // sliver's cache extent) but not yet painted, so `find.text`'s
      // default `skipOffstage: true` (which only matches what's actually
      // on screen) misses it; `skipOffstage: false` is enough here since
      // there's nothing scroll-specific under test, just that the data
      // made it into the tree.
      expect(
        find.text('Wireless Earbuds', skipOffstage: false),
        findsOneWidget,
      );

      // The address and seller sections are further down, past the
      // sliver's cache extent — those Elements aren't built at all yet,
      // so a real scroll (not just `skipOffstage: false`) is needed to
      // reach them. Scrolling in two smaller steps (rather than one big
      // drag) avoids overshooting past the Delivery Address section
      // before it gets a chance to build.
      await tester.drag(find.byType(CustomScrollView), const Offset(0, -500));
      await _settle(tester);

      expect(find.text('Delivery Address'), findsOneWidget);
      // No nested delivery-address object in the fixture, so the address
      // card falls back to the order's own consumerName — CONFIRMED
      // fallback behavior in `_addressFromApi`.
      expect(find.textContaining('Test Buyer'), findsWidgets);

      await tester.drag(find.byType(CustomScrollView), const Offset(0, -500));
      await _settle(tester);

      expect(find.text('Sold by'), findsOneWidget);
      expect(find.text('Ahmed Store'), findsOneWidget);

      await _awaitAnalyticsReady(container);
    },
  );

  testWidgets(
    'consumer cancels a pending order from the detail screen and the live cancel wire call updates the actions',
    skip: MockConfig.useMock,
    (tester) async {
      final dio = _fakeDio({
        'GET ${ApiEndpoints.orderMeById('502')}': (_) => _orderJson(id: '502'),
        'POST ${ApiEndpoints.orderCancel('502')}': (_) =>
            _orderJson(id: '502'),
      });

      final container = await _pumpReady(tester, [
        authProvider.overrideWith(() => _FakeAuth(_consumer())),
        dioProvider.overrideWithValue(dio),
      ], '502');
      await _settle(tester);

      expect(find.text('Cancel Order'), findsOneWidget);
      await tester.tap(find.text('Cancel Order'));
      await _settle(tester);

      // The reason dialog — a real user accepting the fastest path
      // (preset dropdown, tap Confirm).
      expect(find.text('Cancel this order?'), findsOneWidget);
      await tester.tap(find.text('Confirm'));
      await _settle(tester);

      expect(
        find.text('Cancel Order'),
        findsNothing,
        reason: 'a cancelled order no longer offers Cancel Order',
      );
      expect(
        find.textContaining('Shop Again'),
        findsOneWidget,
        reason: 'a cancelled order falls back to a Shop Again action',
      );

      await _awaitAnalyticsReady(container);
    },
  );

  testWidgets(
    'vendor confirms a pending order from the detail screen after choosing a delivery method',
    skip: MockConfig.useMock,
    (tester) async {
      // Captured and asserted on AFTER the pump loop — an expect()
      // failure thrown from inside a Dio interceptor callback doesn't
      // surface as a normal TestFailure; it hangs the pump loop instead
      // of failing fast (see orders_screen_live_flow_test.dart's note on
      // the same issue).
      RequestOptions? putRequest;
      final dio = _fakeDio({
        'GET ${ApiEndpoints.vendorOrders}': (_) => {
          'orders': [_orderJson(id: '901', status: 'pending')],
          'totalCount': 1,
          'pendingCount': 1,
          'confirmedCount': 0,
          'totalRevenue': 0,
        },
        'PUT ${ApiEndpoints.vendorOrdersStatus}': (options) {
          putRequest = options;
          return _orderJson(id: '901', status: 'confirmed');
        },
      });

      final container = await _pumpReady(tester, [
        authProvider.overrideWith(() => _FakeAuth(_vendor())),
        dioProvider.overrideWithValue(dio),
      ], '901');
      await _settle(tester);

      expect(find.textContaining('Confirm Order'), findsOneWidget);
      await tester.tap(find.textContaining('Confirm Order'));
      await _settle(tester);

      expect(find.text('How will this order be delivered?'), findsOneWidget);
      await tester.tap(find.text('Deliver it myself'));
      await _settle(tester);

      expect(putRequest, isNotNull);
      expect(putRequest!.data, {
        'orderIds': [901],
        'status': 1,
      });
      expect(
        find.text('Mark as Processing'),
        findsOneWidget,
        reason: 'a confirmed order moves on to Mark as Processing',
      );

      await _awaitAnalyticsReady(container);
    },
  );
}
