// Screen-level, LIVE-mode (MOCK=false) test of the real, standalone
// VendorOrdersScreen — a real vendor tapping through the app, not
// fixture data. Matches test/orders_screen_live_flow_test.dart's
// established pattern: real screen + real OrdersRepositoryImpl ->
// OrdersRemoteDataSourceImpl chain, only the Dio HTTP transport is
// scripted.
//
// VendorOrdersScreen (routed at AppRoutes.vendorOrders, the vendor shell's
// own tab) is a COMPLETELY SEPARATE implementation from OrdersScreen's
// VendorOrdersView — its own `VendorOrdersNotifier`
// (vendor_orders_provider.dart, a plain StateNotifier, not @riverpod) and
// its own `VendorOrderCard`/`RejectOrderSheet` widgets — even though both
// ultimately call the same confirm/reject/markProcessing use cases and
// therefore hit the same PUT /api/vendor/orders/status wire contract
// orders_screen_live_flow_test.dart already confirmed. Testing this
// screen is NOT redundant with that file: it's genuinely different code
// that happened to be completely uncovered.
//
// Run with: flutter test test/vendor_orders_screen_live_flow_test.dart
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
import 'package:xstore/features/orders/presentation/providers/vendor_orders_provider.dart';
import 'package:xstore/features/orders/presentation/screens/vendor_orders_screen.dart';

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
  String id = '900',
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
    // VendorOrdersScreen renders its own Scaffold, so no extra Material
    // wrapper is needed here.
    home: VendorOrdersScreen(),
  ),
);

/// Pumps the screen, then explicitly (re-)fetches once `authProvider` has
/// actually resolved. `VendorOrdersScreen` fires its one-shot
/// `fetchOrders()` from an `initState` postFrameCallback — same race
/// orders_screen_live_flow_test.dart's `_pumpReady` works around, since
/// `VendorOrdersNotifier._vendorId` reads `authProvider` synchronously.
Future<ProviderContainer> _pumpReady(
  WidgetTester tester,
  List<Override> overrides,
) async {
  await tester.pumpWidget(_harness(overrides));
  await tester.pump();
  final container = ProviderScope.containerOf(
    tester.element(find.byType(VendorOrdersScreen)),
    listen: false,
  );
  await container.read(authProvider.future);
  // Deliberately not awaited — see the FakeAsync-zone note in
  // orders_screen_live_flow_test.dart's `_pumpReady`.
  unawaited(container.read(vendorOrdersProvider.notifier).fetchOrders());
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
    'vendor confirms a pending order after choosing a delivery method',
    // Exercises OrdersRemoteDataSourceImpl's LIVE (non-mock) branch.
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
          'orders': [_vendorOrderJson(id: '910', status: 'pending')],
          'totalCount': 1,
          'pendingCount': 1,
          'confirmedCount': 0,
          'totalRevenue': 0,
        },
        'PUT ${ApiEndpoints.vendorOrdersStatus}': (options) {
          putRequest = options;
          return _vendorOrderJson(id: '910', status: 'confirmed');
        },
      });

      await _pumpReady(tester, [
        authProvider.overrideWith(() => _FakeAuth(_vendor())),
        dioProvider.overrideWithValue(dio),
      ]);
      await _settle(tester);

      expect(find.text('Incoming Orders'), findsOneWidget);
      expect(find.text('Confirm Order'), findsOneWidget);

      await tester.tap(find.text('Confirm Order'));
      await _settle(tester);

      expect(find.text('How will this order be delivered?'), findsOneWidget);
      await tester.tap(find.text('Deliver it myself'));
      await _settle(tester);

      expect(putRequest, isNotNull);
      expect(putRequest!.data, {
        'orderIds': [910],
        'status': 1,
      });
      expect(find.text('Order confirmed'), findsOneWidget);
      expect(
        find.text('Confirm Order'),
        findsNothing,
        reason: 'a confirmed order no longer offers Confirm Order',
      );
    },
  );

  testWidgets(
    'vendor rejects a pending order with a preset reason',
    skip: MockConfig.useMock,
    (tester) async {
      RequestOptions? putRequest;
      final dio = _fakeDio({
        'GET ${ApiEndpoints.vendorOrders}': (_) => {
          'orders': [_vendorOrderJson(id: '911', status: 'pending')],
          'totalCount': 1,
          'pendingCount': 1,
          'confirmedCount': 0,
          'totalRevenue': 0,
        },
        'PUT ${ApiEndpoints.vendorOrdersStatus}': (options) {
          putRequest = options;
          return _vendorOrderJson(id: '911', status: 'cancelled');
        },
      });

      await _pumpReady(tester, [
        authProvider.overrideWith(() => _FakeAuth(_vendor())),
        dioProvider.overrideWithValue(dio),
      ]);
      await _settle(tester);

      expect(find.text('Reject Order'), findsOneWidget);
      await tester.tap(find.text('Reject Order'));
      await _settle(tester);

      // A real vendor picking the first preset reason (no default
      // selection — the Confirm Rejection button starts disabled until
      // one is chosen).
      expect(find.text('Item no longer available'), findsOneWidget);
      await tester.tap(find.text('Item no longer available'));
      await _settle(tester);
      await tester.tap(find.text('Confirm Rejection'));
      await _settle(tester);

      expect(putRequest, isNotNull);
      expect(putRequest!.data, {
        'orderIds': [911],
        'status': 5,
      });
      expect(find.text('Order rejected. Buyer notified.'), findsOneWidget);
    },
  );
}
