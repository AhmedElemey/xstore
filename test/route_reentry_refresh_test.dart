// Verifies the actual production navigation graph — a real
// StatefulShellRoute.indexedStack with two branches, driven with
// `shell.goBranch(...)` exactly like `XstoreBottomNav` does — refetches
// each screen's data when the user switches away and back to its tab,
// via the `RouteReentryRefresh` widget wired into Home, Wishlist,
// MyListings, VendorWallet, CourierDeliveries, and CourierCash.
//
// Mirrors the existing "leaving and returning to the orders tab
// refetches the list" test in orders_screen_live_flow_test.dart — same
// shell-branch harness shape, same convention of counting scripted-Dio
// hits before/after a `nav-away` + `nav-back` tap sequence. Only the Dio
// HTTP transport is scripted; every notifier/repository/datasource in
// between is the real production code.
//
// Run with: flutter test test/route_reentry_refresh_test.dart
import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:xstore/core/localization/app_localizations.dart';
import 'package:xstore/core/mock/mock_config.dart';
import 'package:xstore/core/network/api_endpoints.dart';
import 'package:xstore/core/network/delivery_api_endpoints.dart';
import 'package:xstore/core/network/dio_provider.dart';
import 'package:xstore/core/router/app_routes.dart';
import 'package:xstore/features/auth/domain/entities/user_entity.dart';
import 'package:xstore/features/auth/presentation/providers/auth_provider.dart';
import 'package:xstore/features/commission/presentation/screens/vendor_wallet_screen.dart';
import 'package:xstore/features/delivery/data/delivery_dio_provider.dart';
import 'package:xstore/features/delivery/presentation/screens/courier_cash_screen.dart';
import 'package:xstore/features/delivery/presentation/screens/courier_deliveries_screen.dart';
import 'package:xstore/features/home/presentation/screens/home_screen.dart';
import 'package:xstore/features/listing/presentation/screens/my_listings_screen.dart';
import 'package:xstore/features/wishlist/presentation/providers/wishlist_provider.dart';
import 'package:xstore/features/wishlist/presentation/screens/wishlist_screen.dart';

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

UserEntity _courier() => const UserEntity(
  id: 'courier_1',
  name: 'Test Courier',
  email: 'courier@test.com',
  phoneNumber: '01088888888',
  role: UserRole.courier,
);

/// A placeholder branch 0 path distinct from every real `AppRoutes` value
/// (including `AppRoutes.home`, which is itself a target screen below) so
/// it never collides with the branch-1 target path under test.
const _kOtherTabPath = '/route-reentry-test-other-tab';

/// Pumps [targetScreen] as branch 1 of a real two-branch shell (branch 0
/// is a plain placeholder tab, active at first pump — matching how a real
/// app starts on one shell tab and the user switches to another), with
/// [overrides] applied, and returns the shell's `ProviderContainer`.
Future<ProviderContainer> _pumpShell(
  WidgetTester tester,
  String targetPath,
  Widget targetScreen,
  List<Override> overrides,
) async {
  final router = GoRouter(
    initialLocation: _kOtherTabPath,
    routes: [
      StatefulShellRoute.indexedStack(
        builder: (context, state, shell) => Scaffold(
          body: shell,
          bottomNavigationBar: Row(
            children: [
              TextButton(
                onPressed: () => shell.goBranch(0),
                child: const Text('nav-other'),
              ),
              TextButton(
                onPressed: () => shell.goBranch(1),
                child: const Text('nav-target'),
              ),
            ],
          ),
        ),
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: _kOtherTabPath,
                builder: (_, __) => const Text('other-tab'),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(path: targetPath, builder: (_, __) => targetScreen),
            ],
          ),
        ],
      ),
    ],
  );

  await tester.pumpWidget(
    ProviderScope(
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
    ),
  );
  await tester.pump();
  final container = ProviderScope.containerOf(
    tester.element(find.byType(MaterialApp)),
    listen: false,
  );
  await container.read(authProvider.future);
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

/// Switches from the placeholder branch 0 into the target branch 1 for
/// the first time — branch 1 is built lazily by
/// `StatefulShellRoute.indexedStack`, so this is what actually mounts the
/// target screen and fires its first fetch.
Future<void> _firstVisit(WidgetTester tester) async {
  await tester.tap(find.text('nav-target'));
  await _settle(tester);
}

/// Switches away to the other tab and back to the target tab, settling
/// after each hop — the exact sequence a user performs switching
/// bottom-nav tabs away and back once both branches are already built.
Future<void> _leaveAndReturn(WidgetTester tester) async {
  await tester.tap(find.text('nav-other'));
  await tester.pump();
  await tester.tap(find.text('nav-target'));
  await _settle(tester);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    FlutterSecureStorage.setMockInitialValues({});
  });

  testWidgets(
    'leaving and returning to the Home tab refetches banners/deals/categories',
    skip: MockConfig.useMock,
    (tester) async {
      var homeGets = 0;
      final dio = _fakeDio(ApiEndpoints.baseUrl, {
        'GET ${ApiEndpoints.banners}': (_) => <dynamic>[],
        'GET ${ApiEndpoints.catalogCategories}': (_) => <dynamic>[],
        'GET ${ApiEndpoints.home}': (_) {
          homeGets++;
          return {
            'banners': <dynamic>[],
            'hotDeals': <dynamic>[],
            'newArrivals': <dynamic>[],
            'recommendedForYou': <dynamic>[],
          };
        },
      });

      await _pumpShell(tester, AppRoutes.home, const HomeScreen(), [
        authProvider.overrideWith(() => _FakeAuth(_consumer())),
        dioProvider.overrideWithValue(dio),
      ]);
      await _firstVisit(tester);
      final afterFirst = homeGets;
      expect(afterFirst, greaterThan(0));

      await _leaveAndReturn(tester);

      expect(
        homeGets,
        greaterThan(afterFirst),
        reason: 'IndexedStack keeps HomeScreen alive; coming back to the '
            'tab must refetch the home aggregate again',
      );
    },
  );

  testWidgets(
    'leaving and returning to the Wishlist tab refetches the list',
    skip: MockConfig.useMock,
    (tester) async {
      var wishlistGets = 0;
      final dio = _fakeDio(ApiEndpoints.baseUrl, {
        'GET ${ApiEndpoints.wishlist}/consumer_1': (_) {
          wishlistGets++;
          return <dynamic>[];
        },
      });

      final container = await _pumpShell(
        tester,
        AppRoutes.wishlist,
        const WishlistScreen(),
        [
          authProvider.overrideWith(() => _FakeAuth(_consumer())),
          dioProvider.overrideWithValue(dio),
        ],
      );
      await _firstVisit(tester);
      // WishlistNotifier fetches reactively off an authProvider listener
      // registered in its own build() — seed it defensively in case that
      // listener's first tick raced this container's auth resolution
      // (harmless no-op against a scripted Dio either way).
      unawaited(container.read(wishlistProvider.notifier).fetchWishlist());
      await _settle(tester);
      final afterFirst = wishlistGets;
      expect(afterFirst, greaterThan(0));

      await _leaveAndReturn(tester);

      expect(
        wishlistGets,
        greaterThan(afterFirst),
        reason: 'IndexedStack keeps WishlistScreen alive; coming back to '
            'the tab must hit GET /api/wishlist/{id} again',
      );
    },
  );

  testWidgets(
    'leaving and returning to the My Listings tab refetches the list',
    (tester) async {
      var listingsGets = 0;
      final dio = _fakeDio(ApiEndpoints.baseUrl, {
        'GET ${ApiEndpoints.apiMyListings}': (_) {
          listingsGets++;
          return <dynamic>[];
        },
      });

      await _pumpShell(
        tester,
        AppRoutes.listingMy,
        const MyListingsScreen(),
        [
          authProvider.overrideWith(() => _FakeAuth(_vendor())),
          dioProvider.overrideWithValue(dio),
        ],
      );
      await _firstVisit(tester);
      final afterFirst = listingsGets;
      expect(afterFirst, greaterThan(0));

      await _leaveAndReturn(tester);

      expect(
        listingsGets,
        greaterThan(afterFirst),
        reason: 'IndexedStack keeps MyListingsScreen alive; coming back to '
            'the tab must hit GET /api/listings/my-listings again',
      );
    },
  );

  testWidgets(
    'leaving and returning to the Vendor Wallet tab refetches the stats',
    skip: MockConfig.useMock,
    (tester) async {
      var vendorOrdersGets = 0;
      final dio = _fakeDio(ApiEndpoints.baseUrl, {
        'GET ${ApiEndpoints.vendorOrders}': (_) {
          vendorOrdersGets++;
          return {
            'orders': <Map<String, dynamic>>[],
            'totalCount': 3,
            'pendingCount': 0,
            'confirmedCount': 0,
            'totalRevenue': 1500,
            'warnThresholdEgp': 100,
            'pauseThresholdEgp': 200,
            'exceedsWarnThreshold': false,
            'exceedsPauseThreshold': false,
            'commissionValueOnOrder': 2,
          };
        },
      });

      await _pumpShell(
        tester,
        AppRoutes.vendorWallet,
        const VendorWalletScreen(),
        [
          authProvider.overrideWith(() => _FakeAuth(_vendor())),
          dioProvider.overrideWithValue(dio),
        ],
      );
      await _firstVisit(tester);
      final afterFirst = vendorOrdersGets;
      expect(afterFirst, greaterThan(0));

      await _leaveAndReturn(tester);

      expect(
        vendorOrdersGets,
        greaterThan(afterFirst),
        reason: 'IndexedStack keeps VendorWalletScreen alive; coming back '
            'to the tab must hit GET /api/vendor/orders again',
      );
    },
  );

  testWidgets(
    'leaving and returning to the Courier Deliveries tab refetches orders',
    skip: MockConfig.useMock,
    (tester) async {
      var courierOrdersGets = 0;
      final ordersDio = _fakeDio(ApiEndpoints.baseUrl, {
        'GET ${ApiEndpoints.ordersCourier('courier_1')}': (_) {
          courierOrdersGets++;
          return <dynamic>[];
        },
      });
      final deliveryDio = _fakeDio(DeliveryApiEndpoints.baseUrl, {
        'GET ${DeliveryApiEndpoints.deliveryRequestsCourierMine}': (_) => [],
      });

      await _pumpShell(
        tester,
        AppRoutes.deliveries,
        const CourierDeliveriesScreen(),
        [
          authProvider.overrideWith(() => _FakeAuth(_courier())),
          dioProvider.overrideWithValue(ordersDio),
          deliveryDioProvider.overrideWithValue(deliveryDio),
        ],
      );
      await _firstVisit(tester);
      final afterFirst = courierOrdersGets;
      expect(afterFirst, greaterThan(0));

      await _leaveAndReturn(tester);

      expect(
        courierOrdersGets,
        greaterThan(afterFirst),
        reason: 'IndexedStack keeps CourierDeliveriesScreen alive; coming '
            'back to the tab must hit GET /orders/courier/{id} again',
      );
    },
  );

  testWidgets(
    'leaving and returning to the Courier Cash tab refetches the wallet',
    skip: MockConfig.useMock,
    (tester) async {
      var courierOrdersGets = 0;
      final dio = _fakeDio(ApiEndpoints.baseUrl, {
        'GET ${ApiEndpoints.ordersCourier('courier_1')}': (_) {
          courierOrdersGets++;
          return <dynamic>[];
        },
      });

      await _pumpShell(
        tester,
        AppRoutes.courierCash,
        const CourierCashScreen(),
        [
          authProvider.overrideWith(() => _FakeAuth(_courier())),
          dioProvider.overrideWithValue(dio),
        ],
      );
      await _firstVisit(tester);
      final afterFirst = courierOrdersGets;
      expect(afterFirst, greaterThan(0));

      await _leaveAndReturn(tester);

      expect(
        courierOrdersGets,
        greaterThan(afterFirst),
        reason: 'IndexedStack keeps CourierCashScreen alive; coming back '
            'to the tab must hit GET /orders/courier/{id} again',
      );
    },
  );
}
