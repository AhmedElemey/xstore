// Screen-level, LIVE-mode (MOCK=false) test of the real WishlistScreen — a
// real user tapping through the app, not fixture data. Matches
// test/orders_screen_live_flow_test.dart's established pattern: real
// screen + real WishlistRepositoryImpl -> WishlistRemoteDataSourceImpl
// chain (and, for "add to cart", the real CartRepositoryImpl it delegates
// to), only the Dio HTTP transport is scripted.
//
// Unlike OrdersScreen's ConsumerOrdersView/VendorOrdersView, nothing here
// fetches from an initState postFrameCallback at all — WishlistNotifier
// only ever calls fetchWishlist() reactively (via `ref.listen(authProvider,
// ...)`, which fires once auth settles) or from pull-to-refresh / after a
// cart mutation. The `ref.listen` path should fire on its own once
// `_FakeAuth`'s async build() resolves, but the explicit re-fetch below
// mirrors orders_screen_live_flow_test.dart's `_pumpReady` defensively —
// harmless to call twice against a scripted Dio.
//
// Lives under test/ (not integration_test/) so it runs in plain
// `flutter test` like the rest of CI — no device/emulator needed.
//
// Run with: flutter test test/wishlist_screen_live_flow_test.dart
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

Map<String, dynamic> _wishlistItemJson({
  String id = 'wish_1',
  String listingId = '9001',
  bool isAvailable = true,
  bool isInCart = false,
}) => {
  'id': id,
  'listingId': listingId,
  'listingName': 'Wireless Earbuds',
  'listingImages': ['https://example.test/earbuds.jpg'],
  'listingSlug': 'wireless-earbuds',
  'vendorId': 'vendor_1',
  'vendorName': 'Ahmed',
  'vendorStoreName': 'Ahmed Store',
  'vendorAvatar': '',
  'isVendorVerified': true,
  'price': 50000,
  'category': 'Electronics',
  'condition': 'New',
  'reviewCount': 0,
  'stockQuantity': 5,
  'isAvailable': isAvailable,
  'isInCart': isInCart,
  'shippingAvailable': true,
  'shippingCost': 0,
  'addedAt': '2026-08-01T00:00:00.000Z',
  'lastPriceCheckAt': '2026-08-01T00:00:00.000Z',
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
    // WishlistScreen renders its own Scaffold for the consumer role, so no
    // extra Material wrapper is needed here (unlike OrdersScreen).
    home: WishlistScreen(),
  ),
);

/// Pumps the screen, then explicitly (re-)fetches the wishlist once
/// `authProvider` has actually resolved — see the file-level doc comment
/// above for why this is defensive rather than strictly required.
Future<ProviderContainer> _pumpReady(
  WidgetTester tester,
  List<Override> overrides,
) async {
  await tester.pumpWidget(_harness(overrides));
  await tester.pump();
  final container = ProviderScope.containerOf(
    tester.element(find.byType(WishlistScreen)),
    listen: false,
  );
  await container.read(authProvider.future);
  // Deliberately not awaited: AutomatedTestWidgetsFlutterBinding runs each
  // test inside a FakeAsync zone, so a Future chain that hops through a
  // Timer/Future.delayed anywhere in Dio or the repository stack only
  // resolves in response to tester.pump(duration) advancing the fake
  // clock — awaiting it directly here hangs forever (see the 2026-09-02
  // skill lesson on this exact trap in orders_screen_live_flow_test.dart).
  unawaited(container.read(wishlistProvider.notifier).fetchWishlist());
  return container;
}

/// Bounded frame pump instead of `pumpAndSettle()` — matches the
/// established convention from orders_screen_live_flow_test.dart to avoid
/// hanging on any entrance-animation-style widget.
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
/// into whichever test runs next (see the 2026-09-02 skill lesson).
Future<void> _awaitAnalyticsReady(ProviderContainer container) async {
  await container.read(analyticsServiceProvider).ready;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    // Without these, AnalyticsService._init()'s `await
    // _ref.read(sharedPreferencesProvider.future)` hangs the test
    // indefinitely instead of throwing or resolving.
    SharedPreferences.setMockInitialValues({});
    FlutterSecureStorage.setMockInitialValues({});
  });

  testWidgets(
    'consumer removes an item from the wishlist via the live DELETE wire call',
    // Exercises WishlistRemoteDataSourceImpl's LIVE branch (it has no
    // MockConfig.useMock split at all — every wishlist call always hits
    // this same code, but the guard is kept for consistency with the
    // rest of the suite and because "add to cart" below does depend on
    // Cart/Product's own live/mock split).
    skip: MockConfig.useMock,
    (tester) async {
      // Captured and asserted on AFTER the pump loop — an expect()
      // failure thrown from inside a Dio interceptor callback doesn't
      // surface as a normal TestFailure; it hangs the pump loop instead
      // of failing fast (see orders_screen_live_flow_test.dart's note on
      // the same issue).
      RequestOptions? deleteRequest;
      final dio = _fakeDio({
        'GET ${ApiEndpoints.wishlist}/consumer_1': (_) => [
          _wishlistItemJson(),
        ],
        'DELETE ${ApiEndpoints.wishlistItem('consumer_1', '9001')}':
            (options) {
              deleteRequest = options;
              return null;
            },
      });

      final container = await _pumpReady(tester, [
        authProvider.overrideWith(() => _FakeAuth(_consumer())),
        dioProvider.overrideWithValue(dio),
      ]);
      await _settle(tester);

      expect(find.text('My Wishlist (1)'), findsOneWidget);
      expect(find.text('Wireless Earbuds'), findsOneWidget);

      await tester.tap(find.textContaining('Remove'));
      await _settle(tester);

      expect(deleteRequest, isNotNull);
      expect(
        find.text('Your wishlist is empty'),
        findsOneWidget,
        reason: 'the removed item leaves the wishlist empty',
      );
      expect(find.text('Removed from Wishlist'), findsOneWidget);

      await _awaitAnalyticsReady(container);
    },
  );

  testWidgets(
    'consumer adds an available wishlist item to the cart',
    skip: MockConfig.useMock,
    (tester) async {
      RequestOptions? listingRequest;
      final dio = _fakeDio({
        'GET ${ApiEndpoints.wishlist}/consumer_1': (_) => [
          _wishlistItemJson(),
        ],
        // moveListingToCart delegates to CartRepositoryImpl.addFromListing,
        // which GETs the listing before adding it to the (in-memory,
        // live-mode) cart — same wire contract
        // orders_screen_live_flow_test.dart's reorder test exercises.
        'GET ${ApiEndpoints.apiListingDetail('9001')}': (options) {
          listingRequest = options;
          return {
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
          };
        },
      });

      final container = await _pumpReady(tester, [
        authProvider.overrideWith(() => _FakeAuth(_consumer())),
        dioProvider.overrideWithValue(dio),
      ]);
      await _settle(tester);

      expect(find.textContaining('Add to Cart'), findsOneWidget);
      await tester.tap(find.textContaining('Add to Cart'));
      await _settle(tester);

      expect(listingRequest, isNotNull);
      expect(
        find.text('Added to cart'),
        findsOneWidget,
        reason: 'a successful move-to-cart confirms with a snackbar',
      );

      await _awaitAnalyticsReady(container);
    },
  );
}
