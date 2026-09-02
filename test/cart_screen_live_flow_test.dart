// Screen-level, LIVE-mode (MOCK=false) test of the real CartScreen — a
// real user tapping through the app, not fixture data. Matches
// test/orders_screen_live_flow_test.dart's established pattern: real
// screen + real CartRepositoryImpl -> CartRemoteDataSourceImpl chain,
// only the Dio HTTP transport is scripted.
//
// The live cart itself has no backend API at all (CONFIRMED: GET/POST
// /cart 404s) — CartRemoteDataSourceImpl keeps it entirely in an
// in-memory `_items` list, in both mock and live mode. The only live Dio
// call anywhere in this flow is the listing-detail GET that
// `addFromListing`/`buildLineFromListing` makes when a line is first
// added — the same wire contract test/checkout_order_flow_test.dart's
// reorder-style tests already exercise. So this test seeds the cart via
// that real `addFromListing` call (as a real "add to cart" action would),
// then drives the screen's own remove/coupon actions purely against
// in-memory state.
//
// Run with: flutter test test/cart_screen_live_flow_test.dart
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
import 'package:xstore/features/cart/data/datasources/cart_remote_datasource.dart';
import 'package:xstore/features/cart/presentation/providers/cart_provider.dart';
import 'package:xstore/features/cart/presentation/screens/cart_screen.dart';

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

Map<String, dynamic> _listingJson({String id = '9001'}) => {
  'id': id,
  'title': 'Wireless Earbuds',
  'price': 50000,
  'imageUrl': 'https://example.test/earbuds.jpg',
  'category': 'Electronics',
  'condition': 'New',
  'stockQuantity': 5,
  'seller': {
    'id': 'vendor_1',
    'name': 'Ahmed',
    'storeName': 'Ahmed Store',
    'rating': 4.8,
    'verified': true,
  },
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
    // CartScreen renders its own Scaffold, so no extra Material wrapper
    // is needed here.
    home: CartScreen(),
  ),
);

/// Pumps the screen, then seeds the (in-memory) live cart with one line
/// via the real `addFromListing` call — the same GET-listing-then-add
/// wire contract a real "Add to Cart" tap anywhere else in the app goes
/// through. Awaits `authProvider` first since `addFromListing` reads
/// `_consumerId` synchronously off it.
Future<ProviderContainer> _pumpWithSeededItem(
  WidgetTester tester,
  List<Override> overrides,
) async {
  await tester.pumpWidget(_harness(overrides));
  await tester.pump();
  final container = ProviderScope.containerOf(
    tester.element(find.byType(CartScreen)),
    listen: false,
  );
  await container.read(authProvider.future);
  // Deliberately not awaited: AutomatedTestWidgetsFlutterBinding runs
  // this test inside a FakeAsync zone, so a Future chain that hops
  // through a Timer/Future.delayed anywhere in Dio's call graph only
  // resolves in response to tester.pump(duration) advancing the fake
  // clock — awaiting it directly here (outside a pump) hangs forever
  // (see the 2026-09-02 skill lesson on this exact trap).
  unawaited(
    container
        .read(cartProvider.notifier)
        .addFromListing(listingId: '9001', quantity: 1),
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
    // Cart's in-memory _items list is a static field shared across every
    // test in this isolate (see the 2026-09-02 skill lesson on
    // cart_remote_datasource_test.dart) — start each test from a clean
    // slate.
    CartRemoteDataSourceImpl.clearSessionCache();
  });

  testWidgets(
    'consumer removes an item from the live cart',
    // Exercises CartRemoteDataSourceImpl's LIVE (non-mock) listing-detail
    // fetch that seeds the line — the remove itself is in-memory in both
    // modes, but MOCK=true's own seeded cart would collide with this
    // test's assumption of starting empty.
    skip: MockConfig.useMock,
    (tester) async {
      final dio = _fakeDio({
        'GET ${ApiEndpoints.apiListingDetail('9001')}': (_) => _listingJson(),
      });

      await _pumpWithSeededItem(tester, [
        authProvider.overrideWith(() => _FakeAuth(_consumer())),
        dioProvider.overrideWithValue(dio),
      ]);
      await _settle(tester);

      expect(find.text('My Cart (1 items)'), findsOneWidget);
      expect(find.text('Wireless Earbuds'), findsOneWidget);

      await tester.tap(find.textContaining('Remove'));
      await _settle(tester);

      expect(
        find.text('Your cart is empty'),
        findsOneWidget,
        reason: 'removing the only item leaves the cart empty',
      );
    },
  );

  testWidgets(
    'consumer sees coupons are unavailable in live mode',
    skip: MockConfig.useMock,
    (tester) async {
      final dio = _fakeDio({
        'GET ${ApiEndpoints.apiListingDetail('9001')}': (_) => _listingJson(),
      });

      await _pumpWithSeededItem(tester, [
        authProvider.overrideWith(() => _FakeAuth(_consumer())),
        dioProvider.overrideWithValue(dio),
      ]);
      await _settle(tester);

      expect(find.text('Wireless Earbuds'), findsOneWidget);

      // With only one item, the coupon row's layout position (inside the
      // CustomScrollView, whose `cacheExtent: 1000` lays it out even past
      // the scrollview's own clipped viewport) coincides with the fixed
      // CartCheckoutBar footer's on-screen rect — `find.text('Apply')`
      // reports it as found, but tapping there actually hits the footer
      // underneath the (clipped, not actually visible) coupon row. Scroll
      // it further up first so it's genuinely on screen before tapping.
      await tester.drag(find.byType(CustomScrollView), const Offset(0, -150));
      await _settle(tester);

      await tester.enterText(
        find.widgetWithText(TextField, 'Enter coupon code…'),
        'SAVE10',
      );
      // The Apply button's `onPressed` is only non-null once the entered
      // text has actually rebuilt the widget — without this pump the
      // button is still disabled from the pre-entry build and the tap
      // below is a silent no-op.
      await tester.pump();
      await tester.tap(find.text('Apply'));
      await _settle(tester);

      expect(
        find.text('Coupons aren\'t available yet'),
        findsOneWidget,
        reason: 'CartRemoteDataSourceImpl.applyCoupon always throws '
            "CouponException('unavailable') in live mode — there is no "
            'backend coupon endpoint yet',
      );
    },
  );
}
