// Screen-level, LIVE-mode (MOCK=false) test of the real, standalone
// VendorOrderDetailScreen — a real vendor tapping through the app, not
// fixture data. Matches test/orders_screen_live_flow_test.dart's
// established pattern: real screen + real OrdersRepositoryImpl ->
// OrdersRemoteDataSourceImpl chain, only the Dio HTTP transport is
// scripted.
//
// VendorOrderDetailScreen (pushed from VendorOrdersScreen) is its own
// separate implementation with its own `VendorOrderDetailNotifier` (a
// plain StateNotifier) — its confirm/reject/markProcessing/markShipped
// methods all delegate to `VendorOrdersNotifier`'s own methods (the same
// ones test/vendor_orders_screen_live_flow_test.dart already exercises),
// so they hit the same confirmed PUT /api/vendor/orders/status wire
// contract, but the fetch/refresh wiring around them here is genuinely
// distinct code, previously untested.
//
// Run with: flutter test test/vendor_order_detail_screen_live_flow_test.dart
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
import 'package:xstore/core/network/dio_provider.dart';
import 'package:xstore/features/auth/domain/entities/user_entity.dart';
import 'package:xstore/features/auth/presentation/providers/auth_provider.dart';
import 'package:xstore/features/orders/presentation/providers/vendor_order_detail_provider.dart';
import 'package:xstore/features/orders/presentation/screens/vendor_order_detail_screen.dart';

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

UserEntity _vendor() => const UserEntity(
  id: 'vendor_1',
  name: 'Test Vendor',
  email: 'vendor@test.com',
  phoneNumber: '01099999999',
  role: UserRole.vendor,
);

Map<String, dynamic> _vendorOrderJson({
  String id = '920',
  String status = 'pending',
}) => {
  'id': id,
  'consumerId': 'consumer_1',
  'consumerName': 'Nadia Mansouri',
  'consumerPhone': '01022223333',
  'vendorId': 'vendor_1',
  'vendorName': 'Test Vendor',
  'vendorStoreName': 'Test Store',
  'status': status,
  'listingId': '9002',
  'listingName': 'Bluetooth Speaker',
  'quantity': 1,
  'price': 30000,
  'total': 30000,
  'createdAt': '2026-08-05T00:00:00.000Z',
  'updatedAt': '2026-08-05T00:00:00.000Z',
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
    // VendorOrderDetailScreen renders its own Scaffold, so no extra
    // Material wrapper is needed here.
    home: VendorOrderDetailScreen(orderId: orderId),
  ),
);

/// Pumps the screen, then explicitly (re-)fetches once `authProvider` has
/// actually resolved. `VendorOrderDetailScreen` fires its one-shot
/// `fetchOrder()` from an `initState` postFrameCallback — same race
/// orders_screen_live_flow_test.dart's `_pumpReady` works around, since
/// `VendorOrderDetailNotifier._vendorId` reads `authProvider`
/// synchronously.
Future<ProviderContainer> _pumpReady(
  WidgetTester tester,
  List<Override> overrides,
  String orderId,
) async {
  await tester.pumpWidget(_harness(overrides, orderId));
  await tester.pump();
  final container = ProviderScope.containerOf(
    tester.element(find.byType(VendorOrderDetailScreen)),
    listen: false,
  );
  await container.read(authProvider.future);
  // Deliberately not awaited — see the FakeAsync-zone note in
  // orders_screen_live_flow_test.dart's `_pumpReady`.
  unawaited(
    container.read(vendorOrderDetailProvider(orderId).notifier).fetchOrder(),
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

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    FlutterSecureStorage.setMockInitialValues({});
  });

  testWidgets(
    'vendor views a live order\'s detail — item, buyer, and status render from the wire response',
    // Exercises OrdersRemoteDataSourceImpl's LIVE (non-mock) branch.
    skip: MockConfig.useMock,
    (tester) async {
      final dio = _fakeDio({
        'GET ${ApiEndpoints.vendorOrders}': (_) => {
          'orders': [_vendorOrderJson()],
          'totalCount': 1,
          'pendingCount': 1,
          'confirmedCount': 0,
          'totalRevenue': 0,
        },
      });

      await _pumpReady(tester, [
        authProvider.overrideWith(() => _FakeAuth(_vendor())),
        dioProvider.overrideWithValue(dio),
      ], '920');
      await _settle(tester);

      expect(find.textContaining('Order #'), findsOneWidget);
      expect(find.text('Awaiting your confirmation'), findsOneWidget);
      expect(
        find.text('Bluetooth Speaker', skipOffstage: false),
        findsOneWidget,
      );
      // Appears twice: the buyer-info card's own consumerName, and the
      // delivery-address card's fullName — which falls back to
      // consumerName since the fixture has no nested address object
      // (same CONFIRMED `_addressFromApi` fallback behavior as
      // order_detail_screen_live_flow_test.dart).
      expect(
        find.text('Nadia Mansouri', skipOffstage: false),
        findsWidgets,
      );
      expect(find.text('Confirm Order'), findsOneWidget);
    },
  );

  testWidgets(
    'vendor confirms a pending order from the detail screen after choosing a delivery method',
    skip: MockConfig.useMock,
    (tester) async {
      // Mutable so the SECOND GET (fired by fetchOrder() re-running after
      // a successful confirm) reflects the new status — VendorOrderDetailNotifier
      // doesn't use the PUT response directly, it always re-fetches.
      var status = 'pending';
      RequestOptions? putRequest;
      final dio = _fakeDio({
        'GET ${ApiEndpoints.vendorOrders}': (_) => {
          'orders': [_vendorOrderJson(status: status)],
          'totalCount': 1,
          'pendingCount': status == 'pending' ? 1 : 0,
          'confirmedCount': status == 'confirmed' ? 1 : 0,
          'totalRevenue': 0,
        },
        'PUT ${ApiEndpoints.vendorOrdersStatus}': (options) {
          putRequest = options;
          status = 'confirmed';
          return _vendorOrderJson(status: status);
        },
      });

      await _pumpReady(tester, [
        authProvider.overrideWith(() => _FakeAuth(_vendor())),
        dioProvider.overrideWithValue(dio),
      ], '920');
      await _settle(tester);

      expect(find.text('Confirm Order'), findsOneWidget);
      await tester.tap(find.text('Confirm Order'));
      await _settle(tester);

      expect(find.text('How will this order be delivered?'), findsOneWidget);
      await tester.tap(find.text('Deliver it myself'));
      await _settle(tester);

      expect(putRequest, isNotNull);
      expect(putRequest!.data, {
        'orderIds': [920],
        'status': 1,
      });
      // Appears twice: the inline _Urgent card's action AND the fixed
      // bottom VendorOrderActionSheet both render the same
      // vendorMarkProcessing string for a confirmed order.
      expect(
        find.text('Mark as Processing'),
        findsWidgets,
        reason: 'a confirmed order moves on to Mark as Processing',
      );
      expect(find.text('Confirm Order'), findsNothing);
    },
  );
}
