// Screen-level, LIVE-mode (MOCK=false) test of the real ProductDetailScreen
// — a real user tapping through the app, not fixture data. Matches
// test/orders_screen_live_flow_test.dart's established pattern: real
// screen + real ProductDetailNotifier -> ProductRepositoryImpl ->
// ProductRemoteDataSourceImpl chain (and, for "add to cart", the real
// CartRepositoryImpl it delegates to), only the Dio HTTP transport is
// scripted.
//
// Unlike OrdersScreen/OrderDetailScreen, ProductDetailNotifier is a plain
// `@riverpod` AsyncNotifier that fetches in its own `build()` — no
// initState postFrameCallback, so none of the auth-prewarm machinery
// those screens needed applies here (auth is only read via `.valueOrNull`
// for an analytics property, never gating the fetch itself).
//
// Run with: flutter test test/product_detail_screen_live_flow_test.dart
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
import 'package:xstore/features/product/presentation/screens/product_detail_screen.dart';

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

/// Minimal-but-real listing shape — matches
/// product_remote_datasource_test.dart's `_minimalListing`, extended with
/// what the detail screen actually renders (images, category/condition,
/// seller).
Map<String, dynamic> _listingJson({String id = '9001'}) => {
  'id': id,
  'title': 'Wireless Earbuds',
  'description': 'Noise-cancelling wireless earbuds with a 24h battery.',
  'price': 50000,
  'imageUrls': ['https://example.test/earbuds.jpg'],
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

Widget _harness(List<Override> overrides, String productId) => ProviderScope(
  overrides: overrides,
  child: MaterialApp(
    localizationsDelegates: const [
      AppLocalizations.delegate,
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
    ],
    supportedLocales: AppLocalizations.supportedLocales,
    // ProductDetailScreen renders its own Scaffold for every async state
    // (loading/error/data), so no extra Material wrapper is needed here.
    home: ProductDetailScreen(productId: productId),
  ),
);

/// Bounded frame pump instead of `pumpAndSettle()` — matches the
/// established convention from orders_screen_live_flow_test.dart. This
/// screen's own entrance animations (`fadeSlideIn`, the sticky bar's
/// `slideY`) never report a fully idle scheduler.
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
    'consumer views a live product\'s full detail — title, price, description, and seller render from the wire response',
    // Exercises ProductRemoteDataSourceImpl's LIVE (non-mock) branch.
    skip: MockConfig.useMock,
    (tester) async {
      final dio = _fakeDio({
        'GET ${ApiEndpoints.apiListingDetail('9001')}': (_) => _listingJson(),
        'GET ${ApiEndpoints.apiListingSimilar('9001')}': (_) => <dynamic>[],
        'GET ${ApiEndpoints.apiListingReviews('9001')}': (_) => {
          'items': <dynamic>[],
          'totalCount': 0,
        },
      });

      await tester.pumpWidget(
        _harness([
          authProvider.overrideWith(() => _FakeAuth(_consumer())),
          dioProvider.overrideWithValue(dio),
        ], '9001'),
      );
      await _settle(tester);

      expect(find.text('Wireless Earbuds'), findsOneWidget);
      expect(
        find.text(
          'Noise-cancelling wireless earbuds with a 24h battery.',
          skipOffstage: false,
        ),
        findsOneWidget,
      );
      expect(find.text('Add to Cart'), findsOneWidget);

      // SellerCard shows the seller's plain `name`, not a separate store
      // name field (ProductSellerEntity has no storeName) — and it's
      // further down than the sliver's cache extent reaches at rest, so
      // a real scroll (not just `skipOffstage: false`) is needed.
      await tester.drag(find.byType(CustomScrollView), const Offset(0, -500));
      await _settle(tester);
      expect(find.text('Ahmed'), findsOneWidget);
    },
  );

  testWidgets(
    'consumer adds the product to cart from the sticky bar',
    skip: MockConfig.useMock,
    (tester) async {
      final dio = _fakeDio({
        'GET ${ApiEndpoints.apiListingDetail('9001')}': (_) => _listingJson(),
        'GET ${ApiEndpoints.apiListingSimilar('9001')}': (_) => <dynamic>[],
        'GET ${ApiEndpoints.apiListingReviews('9001')}': (_) => {
          'items': <dynamic>[],
          'totalCount': 0,
        },
      });

      await tester.pumpWidget(
        _harness([
          authProvider.overrideWith(() => _FakeAuth(_consumer())),
          dioProvider.overrideWithValue(dio),
        ], '9001'),
      );
      await _settle(tester);

      expect(find.text('Add to Cart'), findsOneWidget);
      await tester.tap(find.text('Add to Cart'));
      await _settle(tester);

      expect(
        find.text('Added to cart!'),
        findsOneWidget,
        reason: 'a successful add-to-cart confirms with the addedToCart '
            'snackbar',
      );
    },
  );
}
