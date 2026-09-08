// Screen-level, LIVE-mode (MOCK=false) test of the real HomeScreen — a
// real user opening the app, not fixture data. Matches
// test/orders_screen_live_flow_test.dart's established pattern: real
// screen + real Banners/Categories/HotDeals/NewArrivals/Recommended
// notifiers -> HomeRepositoryImpl -> HomeRemoteDataSourceImpl chain, only
// the Dio HTTP transport is scripted.
//
// Unlike OrdersScreen/OrderDetailScreen, every data provider here is a
// plain `@riverpod` AsyncNotifier that fetches in its own `build()` — no
// initState postFrameCallback, so none of the auth-prewarm machinery
// those screens needed applies (auth only gates the cart icon's tap
// target, never the data fetch itself).
//
// Run with: flutter test test/home_screen_live_flow_test.dart
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
import 'package:xstore/core/network/dio_provider.dart';
import 'package:xstore/core/router/app_routes.dart';
import 'package:xstore/features/auth/domain/entities/user_entity.dart';
import 'package:xstore/features/auth/presentation/providers/auth_provider.dart';
import 'package:xstore/features/home/presentation/screens/home_screen.dart';

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

Map<String, dynamic> _bannerJson() => {
  'id': 'b1',
  'nameEn': 'Summer Sale',
  'imageUrl': 'https://example.test/banner.jpg',
};

Map<String, dynamic> _categoryJson() => {
  'id': 'c1',
  'nameEn': 'Electronics',
};

/// A listing-shaped tile, as `_dealFromListing` expects — used for both
/// the hotDeals and newArrivals sections of the `/api/home` aggregate.
Map<String, dynamic> _dealListingJson({
  required String id,
  required String title,
  required num price,
  num? compareAtPrice,
}) => {
  'id': id,
  'title': title,
  'price': price,
  if (compareAtPrice != null) 'compareAtPrice': compareAtPrice,
  'imageUrls': ['https://example.test/$id.jpg'],
};

/// GET /api/home — CONFIRMED aggregate shape feeding HotDeals, NewArrivals,
/// and Recommended all at once (each provider calls `fetchHomeAggregate()`
/// independently, so this single scripted route serves all three fetches).
Map<String, dynamic> _homeAggregateJson() => {
  'banners': <dynamic>[],
  'hotDeals': [
    _dealListingJson(
      id: '9001',
      title: 'Wireless Earbuds',
      price: 50000,
      compareAtPrice: 70000,
    ),
  ],
  'newArrivals': [
    _dealListingJson(id: '9002', title: 'Bluetooth Speaker', price: 30000),
  ],
  'recommendedForYou': <dynamic>[],
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
    // HomeScreen renders its own Scaffold, so no extra Material wrapper
    // is needed here.
    home: HomeScreen(),
  ),
);

/// Variant with a real `GoRouter` for the "open a deal" flow, which
/// navigates via `context.push('${AppRoutes.product}/$id')` — a plain
/// `MaterialApp` (no router) has no `GoRouter` ancestor for that call to
/// find. Mirrors orders_screen_live_flow_test.dart's `_routedHarness`.
Widget _routedHarness(List<Override> overrides) {
  final router = GoRouter(
    initialLocation: '/home-under-test',
    routes: [
      GoRoute(
        path: '/home-under-test',
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        path: '${AppRoutes.product}/:id',
        builder: (context, state) => Scaffold(
          body: Text('product-detail-${state.pathParameters['id']}'),
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

/// Bounded frame pump instead of `pumpAndSettle()` — matches the
/// established convention from orders_screen_live_flow_test.dart; several
/// home widgets (`fadeSlideIn`, `HeroBannerCarousel`'s auto-scroll) never
/// report a fully idle scheduler.
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
    'consumer opens the app and sees live banners, categories, hot deals, and new arrivals',
    // Exercises HomeRemoteDataSourceImpl's LIVE (non-mock) branch.
    skip: MockConfig.useMock,
    (tester) async {
      final dio = _fakeDio({
        'GET ${ApiEndpoints.banners}': (_) => [_bannerJson()],
        'GET ${ApiEndpoints.catalogCategories}': (_) => [_categoryJson()],
        'GET ${ApiEndpoints.home}': (_) => _homeAggregateJson(),
      });

      await tester.pumpWidget(
        _harness([
          authProvider.overrideWith(() => _FakeAuth(_consumer())),
          dioProvider.overrideWithValue(dio),
        ]),
      );
      await _settle(tester);

      expect(find.text('Summer Sale'), findsOneWidget);
      expect(find.text('Electronics'), findsOneWidget);
      expect(
        find.text('Wireless Earbuds', skipOffstage: false),
        findsOneWidget,
      );

      // New Arrivals renders further down than the sliver's cache extent
      // reaches at rest — that Element isn't built at all yet, so a real
      // scroll (not just `skipOffstage: false`) is needed to reach it.
      await tester.drag(find.byType(CustomScrollView), const Offset(0, -600));
      await _settle(tester);

      expect(find.text('Bluetooth Speaker'), findsOneWidget);
    },
  );

  testWidgets(
    'consumer taps a hot deal and navigates to its product detail',
    skip: MockConfig.useMock,
    (tester) async {
      final dio = _fakeDio({
        'GET ${ApiEndpoints.banners}': (_) => [_bannerJson()],
        'GET ${ApiEndpoints.catalogCategories}': (_) => [_categoryJson()],
        'GET ${ApiEndpoints.home}': (_) => _homeAggregateJson(),
      });

      await tester.pumpWidget(
        _routedHarness([
          authProvider.overrideWith(() => _FakeAuth(_consumer())),
          dioProvider.overrideWithValue(dio),
        ]),
      );
      await _settle(tester);

      // The hot-deal tile is within the sliver's cache extent (so
      // `find.text` locates it) but below the physical test viewport, so
      // `tester.tap`'s computed offset falls outside the root render
      // view's bounds — scroll it fully into view first.
      expect(find.text('Wireless Earbuds', skipOffstage: false), findsOneWidget);
      await tester.drag(find.byType(CustomScrollView), const Offset(0, -400));
      await _settle(tester);

      expect(find.text('Wireless Earbuds'), findsOneWidget);
      await tester.tap(find.text('Wireless Earbuds'));
      await _settle(tester);

      expect(
        find.text('product-detail-9001'),
        findsOneWidget,
        reason: 'tapping a hot deal should push AppRoutes.product/{id}',
      );
    },
  );
}
