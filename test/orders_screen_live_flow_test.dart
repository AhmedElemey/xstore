// Screen-level, LIVE-mode (MOCK=false) test of the real OrdersScreen for
// BOTH roles — a real user tapping through the app, not fixture data.
//
// Unlike test/order_lifecycle_full_app_test.dart (which drives the
// notifier/use-case layer directly against a hand-rolled fake
// OrdersRepository) and the datasource-level `skip: MockConfig.useMock`
// tests, this exercises the actual rendered `OrdersScreen` widget with the
// REAL `ordersRepositoryProvider` -> `OrdersRepositoryImpl` ->
// `OrdersRemoteDataSourceImpl` chain, matching
// test/checkout_order_flow_test.dart's established pattern: only the Dio
// HTTP transport is scripted (against the CONFIRMED wire contracts
// documented in .claude/skills/flutter-review/SKILL.md), everything above
// it is production code, and the "user" interacts by tapping real buttons.
//
// Lives under test/ (not integration_test/) so it runs in plain
// `flutter test` like the rest of CI — no device/emulator needed, since
// only the network boundary is faked, not the widget tree.
//
// Run with: flutter test test/orders_screen_live_flow_test.dart
import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:xstore/core/analytics/analytics_service.dart';
import 'package:xstore/core/localization/app_localizations.dart';
import 'package:xstore/core/mock/mock_config.dart';
import 'package:xstore/core/network/api_endpoints.dart';
import 'package:xstore/core/network/dio_provider.dart';
import 'package:xstore/core/router/app_routes.dart';
import 'package:xstore/features/auth/domain/entities/user_entity.dart';
import 'package:xstore/features/auth/presentation/providers/auth_provider.dart';
import 'package:xstore/features/cart/data/datasources/cart_remote_datasource.dart';
import 'package:xstore/features/orders/presentation/providers/orders_provider.dart';
import 'package:xstore/features/orders/presentation/screens/orders_screen.dart';

/// Routes each request by (method, path) to a scripted response — same
/// technique as home_remote_datasource_test.dart's `_RoutedInterceptor`,
/// extended with the HTTP method since this screen's vendor flow both GETs
/// and PUTs the same order resource under different verbs.
class _RoutedInterceptor extends Interceptor {
  _RoutedInterceptor(this._routes);

  final Map<String, Object? Function(RequestOptions options)> _routes;
  final List<RequestOptions> requests = [];

  String _key(RequestOptions o) => '${o.method} ${o.path}';

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    requests.add(options);
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

/// A scripted-route handler that fails the request with a server error in
/// the CONFIRMED `{isSuccess, data, errorEn, errorAr, statusCode}` envelope
/// `dio_error_mapper.dart` reads — same shape as
/// checkout_order_flow_test.dart's 500 scenario.
DioException _serverErrorResponse(
  RequestOptions options, {
  int statusCode = 500,
  required String errorEn,
}) => DioException(
  requestOptions: options,
  type: DioExceptionType.badResponse,
  response: Response(
    requestOptions: options,
    statusCode: statusCode,
    data: {
      'isSuccess': false,
      'data': null,
      'errorEn': errorEn,
      'statusCode': statusCode,
    },
  ),
);

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
    // OrdersScreen (and the ConsumerOrdersView/VendorOrdersView it
    // dispatches to) is designed to live inside an existing shell Scaffold
    // (the bottom-nav StatefulShellRoute in the real app) — it renders no
    // Scaffold/Material of its own, so a bare `home:` throws "No Material
    // widget found" the moment VendorOrdersView's sort DropdownButton (or
    // any other Material widget) builds.
    home: Scaffold(body: OrdersScreen()),
  ),
);

/// Variant with a real `GoRouter` for the "View Details" flow, which
/// navigates via `context.push(AppRoutes.orderPath(id))` — a plain
/// `MaterialApp` (no router) has no `GoRouter` ancestor for that call to
/// find. Mirrors checkout_order_flow_test.dart's `_checkoutHarness`: a
/// stub destination route is enough to prove the navigation happened.
Widget _routedHarness(List<Override> overrides) {
  final router = GoRouter(
    initialLocation: '/orders-under-test',
    routes: [
      GoRoute(
        path: '/orders-under-test',
        builder: (context, state) => const Scaffold(body: OrdersScreen()),
      ),
      GoRoute(
        path: '${AppRoutes.orderDetail}/:id',
        builder: (context, state) => Scaffold(
          body: Text('order-detail-${state.pathParameters['id']}'),
        ),
      ),
    ],
  );
  return ProviderScope(
    overrides: overrides,
    child: MaterialApp.router(
      routerConfig: router,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
    ),
  );
}

/// Pumps the screen, then explicitly (re-)fetches orders once `authProvider`
/// has actually resolved. `ConsumerOrdersView`/`VendorOrdersView` fire their
/// one-shot `fetchOrders()` from an `initState` postFrameCallback — a
/// single call that bails out silently if `authProvider` is still
/// `AsyncLoading` at that instant (see `OrdersNotifier.fetchOrders`'s `if
/// (_user == null) return;`), and nothing re-triggers it once auth resolves
/// a moment later. Matches the flutter-review skill's "Lazy async providers
/// read as Loading in widget tests" lesson: rather than fight that race
/// with a pre-warmed `ProviderContainer` (which then has to be disposed
/// manually and — verified the hard way — trips flutter_test's "Timer
/// still pending" invariant check on `AnalyticsService`'s periodic flush
/// timer when disposed outside the widget tree's own teardown), let the
/// screen's own `ProviderScope` own the container/timer lifecycle as usual,
/// and just call `fetchOrders()` again afterward — idempotent, and cheap
/// against a scripted Dio.
Future<ProviderContainer> _pumpReady(
  WidgetTester tester,
  List<Override> overrides, {
  Widget Function(List<Override>) harness = _harness,
}) async {
  await tester.pumpWidget(harness(overrides));
  await tester.pump();
  final container = ProviderScope.containerOf(
    tester.element(find.byType(OrdersScreen)),
    listen: false,
  );
  await container.read(authProvider.future);
  // Deliberately not awaited: this suite's AutomatedTestWidgetsFlutterBinding
  // runs each test inside a FakeAsync zone, so a Future chain that hops
  // through a Timer/Future.delayed anywhere in Dio or the repository stack
  // only resolves in response to tester.pump(duration) advancing the fake
  // clock -- awaiting it directly here (outside a pump call) hangs forever.
  // Firing it and letting the caller's _settle pump loop carry it to
  // completion mirrors how the screen's own initState postFrameCallback
  // already does this successfully.
  unawaited(container.read(ordersNotifierProvider.notifier).fetchOrders());
  return container;
}

/// OrderCard's staggered `fadeSlideIn` entrance animation (flutter_animate)
/// never reports a fully idle scheduler to `pumpAndSettle()` — it hangs the
/// test indefinitely instead of throwing, the same class of issue the
/// flutter-review skill's "OtpResendCooldown" lesson already documents for
/// screens with a live Timer. Drive a bounded number of frames instead.
Future<void> _settle(
  WidgetTester tester, {
  int times = 15,
  Duration step = const Duration(milliseconds: 100),
}) async {
  for (var i = 0; i < times; i++) {
    await tester.pump(step);
  }
}

/// AnalyticsService._init() is async and registers a `ref.listen` once it
/// completes; if the container is torn down first, that pending
/// continuation resumes against an already-disposed container and throws
/// into whichever test runs next (see checkout_order_flow_test.dart's
/// `_buildContainer` and the 2026-09-02 skill lesson on the same failure
/// mode for ordersNotifierProvider specifically).
Future<void> _awaitAnalyticsReady(ProviderContainer container) async {
  await container.read(analyticsServiceProvider).ready;
}

Map<String, dynamic> _consumerOrderJson({
  String id = '501',
  String status = 'pending',
  String listingId = '9001',
}) => {
  'id': id,
  'consumerId': 'consumer_1',
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

Map<String, dynamic> _vendorOrderJson({
  String id = '900',
  String status = 'confirmed',
}) => {
  'id': id,
  'consumerId': 'consumer_2',
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

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    // Without these, AnalyticsService._init()'s `await
    // _ref.read(sharedPreferencesProvider.future)` hangs the test
    // indefinitely instead of throwing or resolving — SharedPreferences
    // has no mock handler registered otherwise.
    SharedPreferences.setMockInitialValues({});
    FlutterSecureStorage.setMockInitialValues({});
    // Cart's in-memory _items list is a static field shared across every
    // test in this isolate (see the 2026-09-02 skill lesson on
    // cart_remote_datasource_test.dart) — the reorder test below adds to
    // it, so start each test from a clean slate.
    CartRemoteDataSourceImpl.clearSessionCache();
  });

  testWidgets(
    'consumer taps Cancel Order on OrdersScreen and the live cancel wire call updates the card',
    // Exercises OrdersRemoteDataSourceImpl's LIVE (non-mock) branch.
    skip: MockConfig.useMock,
    (tester) async {
      final dio = _fakeDio({
        'GET ${ApiEndpoints.ordersMe}': (_) => [_consumerOrderJson()],
        'POST ${ApiEndpoints.orderCancel('501')}': (_) =>
            _consumerOrderJson(),
      });

      final container = await _pumpReady(tester, [
        authProvider.overrideWith(() => _FakeAuth(_consumer())),
        dioProvider.overrideWithValue(dio),
      ]);
      await _settle(tester);

      expect(find.text('My Orders'), findsOneWidget);
      expect(find.text('Cancel Order'), findsOneWidget);

      await tester.tap(find.text('Cancel Order'));
      await _settle(tester);

      // The reason dialog (a preset dropdown, "Confirm" to accept the
      // default reason) — a real user picking the fastest path through it.
      expect(find.text('Cancel this order?'), findsOneWidget);
      await tester.tap(find.text('Confirm'));
      await _settle(tester);

      expect(
        find.text('Cancel Order'),
        findsNothing,
        reason: 'a cancelled order no longer offers Cancel Order',
      );
      expect(
        find.text('View Details'),
        findsOneWidget,
        reason: 'cancelled orders fall back to a View Details action',
      );

      await _awaitAnalyticsReady(container);
    },
  );

  testWidgets(
    'vendor taps Mark as Processing on OrdersScreen and the live status wire call updates the card',
    skip: MockConfig.useMock,
    (tester) async {
      // Captured and asserted on AFTER the pump loop rather than inside the
      // interceptor callback itself — an `expect()` failure thrown from
      // inside a Dio interceptor (invoked outside the test's own call
      // stack) doesn't surface as a normal TestFailure; it hangs the
      // pump loop instead of failing fast.
      RequestOptions? putRequest;
      final dio = _fakeDio({
        'GET ${ApiEndpoints.vendorOrders}': (_) => {
          'orders': [_vendorOrderJson()],
          'totalCount': 1,
          'pendingCount': 0,
          'confirmedCount': 1,
          'totalRevenue': 0,
        },
        'PUT ${ApiEndpoints.vendorOrdersStatus}': (options) {
          putRequest = options;
          return _vendorOrderJson(status: 'processing');
        },
      });

      final container = await _pumpReady(tester, [
        authProvider.overrideWith(() => _FakeAuth(_vendor())),
        dioProvider.overrideWithValue(dio),
      ]);
      await _settle(tester);

      expect(find.text('Incoming Orders'), findsOneWidget);
      expect(find.text('Mark as Processing'), findsOneWidget);

      await tester.tap(find.text('Mark as Processing'));
      await _settle(tester);

      expect(putRequest, isNotNull);
      expect(putRequest!.data, {
        'orderIds': [900],
        'status': 'processing',
      });

      expect(
        find.text('Mark as Processing'),
        findsNothing,
        reason: 'a processing order no longer offers Mark as Processing',
      );
      expect(
        find.text('Mark as Shipped'),
        findsOneWidget,
        reason: 'a processing order moves on to Mark as Shipped',
      );

      await _awaitAnalyticsReady(container);
    },
  );

  testWidgets(
    'vendor confirms a pending order after choosing a delivery method',
    skip: MockConfig.useMock,
    (tester) async {
      // Captured and asserted on AFTER the pump loop — see the note on the
      // "Mark as Processing" test above about expect() inside a Dio
      // interceptor hanging the test instead of failing it.
      RequestOptions? putRequest;
      final dio = _fakeDio({
        'GET ${ApiEndpoints.vendorOrders}': (_) => {
          'orders': [_vendorOrderJson(id: '901', status: 'pending')],
          'totalCount': 1,
          'pendingCount': 1,
          'confirmedCount': 0,
          'totalRevenue': 0,
        },
        'PUT ${ApiEndpoints.vendorOrdersStatus}': (options) {
          putRequest = options;
          return _vendorOrderJson(id: '901', status: 'confirmed');
        },
      });

      final container = await _pumpReady(tester, [
        authProvider.overrideWith(() => _FakeAuth(_vendor())),
        dioProvider.overrideWithValue(dio),
      ]);
      await _settle(tester);

      expect(find.text('Incoming Orders'), findsOneWidget);
      // The button label carries a leading checkmark glyph ("✓ Confirm
      // Order") — match on the stable substring rather than the exact
      // string, same as create_listing_test.dart's `textContaining` use.
      expect(find.textContaining('Confirm Order'), findsOneWidget);

      await tester.tap(find.textContaining('Confirm Order'));
      await _settle(tester);

      // Accepting a pending order first asks the vendor how it'll be
      // delivered — a real user picking "self" here.
      expect(find.text('How will this order be delivered?'), findsOneWidget);
      await tester.tap(find.text('Deliver it myself'));
      await _settle(tester);

      expect(putRequest, isNotNull);
      expect(putRequest!.data, {
        'orderIds': [901],
        'status': 'confirmed',
      });

      expect(
        find.textContaining('Confirm Order'),
        findsNothing,
        reason: 'a confirmed order no longer offers Confirm Order',
      );
      expect(
        find.text('Mark as Processing'),
        findsOneWidget,
        reason: 'a confirmed order moves on to Mark as Processing',
      );

      await _awaitAnalyticsReady(container);
    },
  );

  testWidgets(
    'vendor rejects a pending order with a reason',
    skip: MockConfig.useMock,
    (tester) async {
      // Captured and asserted on AFTER the pump loop — see the note on the
      // "Mark as Processing" test above about expect() inside a Dio
      // interceptor hanging the test instead of failing it.
      RequestOptions? putRequest;
      final dio = _fakeDio({
        'GET ${ApiEndpoints.vendorOrders}': (_) => {
          'orders': [_vendorOrderJson(id: '902', status: 'pending')],
          'totalCount': 1,
          'pendingCount': 1,
          'confirmedCount': 0,
          'totalRevenue': 0,
        },
        'PUT ${ApiEndpoints.vendorOrdersStatus}': (options) {
          putRequest = options;
          return _vendorOrderJson(id: '902', status: 'cancelled');
        },
      });

      final container = await _pumpReady(tester, [
        authProvider.overrideWith(() => _FakeAuth(_vendor())),
        dioProvider.overrideWithValue(dio),
      ]);
      await _settle(tester);

      expect(find.text('Incoming Orders'), findsOneWidget);
      expect(find.text('Reject'), findsOneWidget);

      await tester.tap(find.text('Reject'));
      await _settle(tester);

      expect(find.text('Reject order'), findsOneWidget);
      await tester.enterText(find.byType(TextField), 'Out of stock');
      await tester.tap(find.text('Confirm'));
      await _settle(tester);

      expect(putRequest, isNotNull);
      expect(putRequest!.data, {
        'orderIds': [902],
        'status': 'cancelled',
      });

      expect(
        find.text('Reject'),
        findsNothing,
        reason: 'a rejected (cancelled) order no longer offers Reject',
      );
      expect(
        find.text('View Details'),
        findsOneWidget,
        reason: 'cancelled orders fall back to a View Details action',
      );

      await _awaitAnalyticsReady(container);
    },
  );

  testWidgets(
    'vendor ships a processing order with tracking info',
    skip: MockConfig.useMock,
    (tester) async {
      // Captured and asserted on AFTER the pump loop — see the note on the
      // "Mark as Processing" test above about expect() inside a Dio
      // interceptor hanging the test instead of failing it.
      RequestOptions? putRequest;
      final dio = _fakeDio({
        'GET ${ApiEndpoints.vendorOrders}': (_) => {
          'orders': [_vendorOrderJson(id: '903', status: 'processing')],
          'totalCount': 1,
          'pendingCount': 0,
          'confirmedCount': 1,
          'totalRevenue': 0,
        },
        'PUT ${ApiEndpoints.vendorOrdersStatus}': (options) {
          putRequest = options;
          return _vendorOrderJson(id: '903', status: 'shipped');
        },
      });

      final container = await _pumpReady(tester, [
        authProvider.overrideWith(() => _FakeAuth(_vendor())),
        dioProvider.overrideWithValue(dio),
      ]);
      await _settle(tester);

      expect(find.text('Incoming Orders'), findsOneWidget);
      expect(find.text('Mark as Shipped'), findsOneWidget);

      await tester.tap(find.text('Mark as Shipped'));
      await _settle(tester);

      // The "Add Tracking Info" sheet — a real user filling in the
      // tracking number and courier before confirming the shipment.
      expect(find.text('Add Tracking Info'), findsOneWidget);
      final textFields = find.byType(TextField);
      expect(textFields, findsNWidgets(2));
      await tester.enterText(textFields.at(0), 'XS-TRACK-903');
      await tester.enterText(textFields.at(1), 'xStore Logistics');
      await tester.tap(find.text('Confirm Shipment'));
      await _settle(tester);

      expect(putRequest, isNotNull);
      expect(putRequest!.data, {
        'orderIds': [903],
        'status': 'shipped',
      });

      expect(
        find.text('Mark as Shipped'),
        findsNothing,
        reason: 'a shipped order no longer offers Mark as Shipped',
      );
      expect(
        find.text('View Tracking'),
        findsOneWidget,
        reason: 'a shipped order moves on to View Tracking',
      );

      await _awaitAnalyticsReady(container);
    },
  );

  testWidgets(
    'consumer taps View Details on a processing order and navigates to order detail',
    skip: MockConfig.useMock,
    (tester) async {
      final dio = _fakeDio({
        'GET ${ApiEndpoints.ordersMe}': (_) => [
          _consumerOrderJson(id: '504', status: 'processing'),
        ],
      });

      final container = await _pumpReady(
        tester,
        [
          authProvider.overrideWith(() => _FakeAuth(_consumer())),
          dioProvider.overrideWithValue(dio),
        ],
        harness: _routedHarness,
      );
      await _settle(tester);

      expect(find.text('My Orders'), findsOneWidget);
      expect(find.text('View Details'), findsOneWidget);

      await tester.tap(find.text('View Details'));
      await _settle(tester);

      expect(
        find.text('order-detail-504'),
        findsOneWidget,
        reason: 'View Details should push AppRoutes.orderPath(order.id)',
      );

      await _awaitAnalyticsReady(container);
    },
  );

  testWidgets(
    'consumer reorders a delivered order, adding its listing back to the live cart',
    skip: MockConfig.useMock,
    (tester) async {
      final dio = _fakeDio({
        'GET ${ApiEndpoints.ordersMe}': (_) => [
          _consumerOrderJson(id: '505', status: 'delivered'),
        ],
        // The reorder flow re-adds each order line by calling
        // CartRepositoryImpl.addFromListing, which GETs the listing before
        // adding it to the (in-memory, live-mode) cart.
        'GET ${ApiEndpoints.apiListingDetail('9001')}': (_) => {
          'id': '9001',
          'title': 'Wireless Earbuds',
          'price': 50000,
          'imageUrl': 'https://example.test/earbuds.jpg',
          'category': 'Electronics',
          'condition': 'New',
          'seller': {
            'id': 'vendor_1',
            'name': 'Ahmed',
            'storeName': 'Ahmed Store',
            'rating': 4.8,
            'verified': true,
          },
        },
      });

      final container = await _pumpReady(tester, [
        authProvider.overrideWith(() => _FakeAuth(_consumer())),
        dioProvider.overrideWithValue(dio),
      ]);
      await _settle(tester);

      expect(find.text('My Orders'), findsOneWidget);
      expect(find.text('Reorder'), findsOneWidget);

      await tester.tap(find.text('Reorder'));
      await _settle(tester);

      expect(
        find.text('Added to cart!'),
        findsOneWidget,
        reason: 'a successful reorder confirms with the addedToCart snackbar',
      );

      await _awaitAnalyticsReady(container);
    },
  );

  testWidgets(
    'consumer leaves a review from a delivered order',
    skip: MockConfig.useMock,
    (tester) async {
      // Captured and asserted on AFTER the pump loop — see the note on the
      // "Mark as Processing" test above about expect() inside a Dio
      // interceptor hanging the test instead of failing it.
      RequestOptions? postRequest;
      final dio = _fakeDio({
        'GET ${ApiEndpoints.ordersMe}': (_) => [
          _consumerOrderJson(id: '506', status: 'delivered', listingId: '9003'),
        ],
        // _reviewSheet posts through the same product-review endpoint the
        // product detail screen uses (ProductRemoteDataSourceImpl.createReview),
        // keyed off the order's (single) listing.
        'POST ${ApiEndpoints.apiListingReviews('9003')}': (options) {
          postRequest = options;
          return {
            'id': 'review_1',
            'userId': 'consumer_1',
            'userName': 'Test Buyer',
            'rating': 5,
            'comment': 'Great product, fast delivery!',
          };
        },
      });

      final container = await _pumpReady(tester, [
        authProvider.overrideWith(() => _FakeAuth(_consumer())),
        dioProvider.overrideWithValue(dio),
      ]);
      await _settle(tester);

      expect(find.text('My Orders'), findsOneWidget);
      expect(find.text('Leave Review'), findsOneWidget);

      await tester.tap(find.text('Leave Review'));
      await _settle(tester);

      // The review sheet — a real user rating it and typing a comment
      // before submitting.
      expect(find.text('Leave a review'), findsOneWidget);
      await tester.enterText(
        find.byType(TextField),
        'Great product, fast delivery!',
      );
      await tester.tap(find.text('Submit Review'));
      await _settle(tester);

      expect(postRequest, isNotNull);
      expect(postRequest!.data, {
        'rating': 5.0,
        'comment': 'Great product, fast delivery!',
      });
      expect(find.text('Thanks for your review!'), findsOneWidget);

      await _awaitAnalyticsReady(container);
    },
  );

  testWidgets(
    'consumer sees the server error when submitting a review fails',
    skip: MockConfig.useMock,
    (tester) async {
      final dio = _fakeDio({
        'GET ${ApiEndpoints.ordersMe}': (_) => [
          _consumerOrderJson(id: '507', status: 'delivered', listingId: '9004'),
        ],
        'POST ${ApiEndpoints.apiListingReviews('9004')}': (options) =>
            _serverErrorResponse(
              options,
              errorEn: 'Failed to submit review. Please try again.',
            ),
      });

      final container = await _pumpReady(tester, [
        authProvider.overrideWith(() => _FakeAuth(_consumer())),
        dioProvider.overrideWithValue(dio),
      ]);
      await _settle(tester);

      expect(find.text('Leave Review'), findsOneWidget);
      await tester.tap(find.text('Leave Review'));
      await _settle(tester);

      expect(find.text('Leave a review'), findsOneWidget);
      await tester.enterText(
        find.byType(TextField),
        'Great product, fast delivery!',
      );
      await tester.tap(find.text('Submit Review'));
      await _settle(tester);

      expect(
        find.text('Failed to submit review. Please try again.'),
        findsOneWidget,
        reason: 'a failed review submission surfaces the server error, '
            'not the success snackbar',
      );
      expect(find.text('Thanks for your review!'), findsNothing);

      await _awaitAnalyticsReady(container);
    },
  );

  testWidgets(
    'submitting a review with an empty comment is a no-op — no request, sheet stays open',
    skip: MockConfig.useMock,
    (tester) async {
      // Deliberately no POST route scripted for the reviews endpoint: if
      // the empty-comment guard in _reviewSheet ever regressed and let a
      // blank review through, the request would hit _RoutedInterceptor's
      // "unscripted request" rejection instead of silently succeeding.
      final dio = _fakeDio({
        'GET ${ApiEndpoints.ordersMe}': (_) => [
          _consumerOrderJson(id: '508', status: 'delivered'),
        ],
      });

      final container = await _pumpReady(tester, [
        authProvider.overrideWith(() => _FakeAuth(_consumer())),
        dioProvider.overrideWithValue(dio),
      ]);
      await _settle(tester);

      expect(find.text('Leave Review'), findsOneWidget);
      await tester.tap(find.text('Leave Review'));
      await _settle(tester);

      expect(find.text('Leave a review'), findsOneWidget);
      // Leaves the comment field empty and taps Submit directly.
      await tester.tap(find.text('Submit Review'));
      await _settle(tester);

      expect(
        find.text('Leave a review'),
        findsOneWidget,
        reason: 'an empty comment should block submission and keep the '
            'sheet open, matching product_reviews_screen.dart\'s own rule',
      );
      expect(find.text('Thanks for your review!'), findsNothing);

      await _awaitAnalyticsReady(container);
    },
  );
}
