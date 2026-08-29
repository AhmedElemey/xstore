// Integration test for the consumer create-order flow (cart -> checkout ->
// place order -> confirmation).
//
// This exercises the REAL provider/repository/datasource/error-mapping
// stack — CheckoutScreen, Checkout notifier, Cart notifier,
// CartRepositoryImpl, OrdersRemoteDataSourceImpl, dio_error_mapper.dart, and
// (for the auth-expiry case) the real TokenRefreshInterceptor — all run
// unmodified. Only the Dio HTTP transport is faked, via a scripted
// HttpClientAdapter (the same technique test/token_refresh_interceptor_test
// .dart already uses), and it is scripted against the CONFIRMED
// `POST /api/orders` wire contract documented in
// .claude/skills/flutter-review/SKILL.md (2026-08-14 "Real Orders/
// Vendor-Orders contract" and "error envelope changed to {isSuccess, data,
// errorEn, errorAr, statusCode}" lessons) — not a hand-rolled shape that
// could drift from what the backend actually returns.
//
// Lives under test/, not integration_test/, on purpose: this repo's CI
// (.github/workflows/ci.yml) only ever runs plain `flutter test`, never
// `flutter test integration_test/...` — and integration_test/
// create_listing_test.dart's own header says it needs a real attached
// device, because it drives native plugins (image picker) that a VM-only
// run can't. This test needs none of that (no app.bootstrap(), no
// Firebase/native plugins), so it belongs where it actually runs today.
//
// A true device-driven end-to-end run against the LIVE backend (matching
// integration_test/create_listing_test.dart's pattern) is intentionally not
// attempted here either: the flutter-review skill's 2026-08-14 "Full order
// lifecycle live-probed" lesson documents that reaching a real order today
// requires an admin-approved listing, and no admin credentials / approved
// listing are available — that live-backend gap is called out separately as
// a product risk rather than papered over with a flaky test. Run with:
//
//   flutter test test/checkout_order_flow_test.dart

import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:xstore/core/analytics/analytics_service.dart';
import 'package:xstore/core/constants/prefs_keys.dart';
import 'package:xstore/core/mock/mock_config.dart';
import 'package:xstore/core/localization/app_localizations.dart';
import 'package:xstore/core/network/api_endpoints.dart';
import 'package:xstore/core/network/app_error_messages.dart';
import 'package:xstore/core/network/dio_provider.dart';
import 'package:xstore/core/network/token_refresh_interceptor.dart';
import 'package:xstore/core/router/app_routes.dart';
import 'package:xstore/features/auth/domain/entities/user_entity.dart';
import 'package:xstore/features/auth/presentation/providers/auth_provider.dart';
import 'package:xstore/features/cart/domain/entities/cart_item_entity.dart';
import 'package:xstore/features/cart/presentation/providers/cart_provider.dart';
import 'package:xstore/features/cart/presentation/providers/cart_state.dart';
import 'package:xstore/features/cart/presentation/providers/checkout_provider.dart';
import 'package:xstore/features/cart/presentation/providers/checkout_state.dart';
import 'package:xstore/features/cart/presentation/screens/checkout_screen.dart';
import 'package:xstore/features/orders/domain/entities/order_entity.dart';
import 'package:xstore/features/profile/domain/entities/profile_entity.dart';
import 'package:xstore/features/profile/presentation/providers/profile_provider.dart';
import 'package:xstore/features/profile/presentation/providers/profile_state.dart';

/// Records every request the app makes and answers with a pre-scripted
/// response or error, keyed by whatever the test's handler wants to check.
class _ScriptedAdapter implements HttpClientAdapter {
  _ScriptedAdapter(this._handler);

  final FutureOr<ResponseBody> Function(RequestOptions options) _handler;
  final List<RequestOptions> requests = [];

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    requests.add(options);
    return _handler(options);
  }

  @override
  void close({bool force = false}) {}
}

ResponseBody _jsonBody(Object data, int statusCode) => ResponseBody.fromString(
      jsonEncode(data),
      statusCode,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );

/// Plain fake transport — no auth header attach, no token refresh. Used for
/// every scenario except the auth-expiry one.
Dio _fakeDio(_ScriptedAdapter adapter) =>
    Dio(BaseOptions(baseUrl: ApiEndpoints.baseUrl))..httpClientAdapter = adapter;

/// Mirrors the two auth-related interceptors dio_provider.dart wires onto
/// the real shared client (X-Auth-Token attach + 401 refresh-and-retry), so
/// the auth-expiry scenario exercises the real TokenRefreshInterceptor
/// rather than a re-implementation of it.
Dio _authAwareFakeDio(
  _ScriptedAdapter adapter, {
  required Future<void> Function() onRefreshFailed,
}) {
  const storage = FlutterSecureStorage();
  final dio = Dio(BaseOptions(baseUrl: ApiEndpoints.baseUrl))
    ..httpClientAdapter = adapter;
  dio.interceptors.add(
    InterceptorsWrapper(
      onRequest: (options, handler) async {
        final token = await storage.read(key: PrefsKeys.authToken);
        if (token != null && token.isNotEmpty) {
          options.headers['X-Auth-Token'] = token;
        }
        handler.next(options);
      },
    ),
  );
  dio.interceptors.add(
    TokenRefreshInterceptor(
      dio: dio,
      secureStorage: storage,
      onRefreshFailed: onRefreshFailed,
    ),
  );
  return dio;
}

UserEntity _consumer() => UserEntity(
      id: 'consumer_1',
      name: 'Test Buyer',
      email: 'buyer@test.com',
      phoneNumber: '01012345678',
    );

CartItemEntity _seedItem() => CartItemEntity(
      id: 'cart_item_1',
      listingId: '501',
      listingName: 'Test Listing',
      listingImage: '',
      vendorId: 'vendor_1',
      vendorName: 'Test Vendor',
      vendorStoreName: 'Test Store',
      price: 100,
      quantity: 1,
      maxQuantity: 5,
      category: 'electronics',
      condition: 'New',
      addedAt: DateTime(2026, 1, 1),
    );

class _FakeAuth extends Auth {
  _FakeAuth(this._user);
  final UserEntity? _user;
  @override
  Future<UserEntity?> build() async => _user;
}

/// Seeds Cart with a fixed item list, already selected — bypasses the real
/// `GET /api/cart` fetch (out of scope for an order-CREATION test) and its
/// auth-driven auto-refetch listener, so only order placement itself talks
/// to the scripted transport.
class _SeededCart extends Cart {
  _SeededCart({this.items = const []});
  final List<CartItemEntity> items;

  @override
  CartState build() {
    final ids = items.map((e) => e.id).toSet();
    final subtotal = items.fold<double>(0, (a, b) => a + b.price * b.quantity);
    return CartState(
      items: items,
      selectedItemIds: ids,
      consumerId: 'consumer_1',
      subtotal: subtotal,
      total: subtotal,
    );
  }
}

/// Seeds Checkout with no saved address, to exercise the "missing address"
/// validation failure. Runs the real `Checkout.build()` first (analytics
/// tracking, default PaymentMethod) and only strips the address afterwards.
class _NoAddressCheckout extends Checkout {
  @override
  CheckoutState build() {
    final s = super.build();
    return s.copyWith(savedAddresses: [], selectedAddressIndex: null);
  }
}

/// Seeds Checkout with one valid saved address synchronously. The real
/// `build()` now loads any saved addresses from local storage
/// asynchronously (there's no backend address book — see
/// checkout_provider.dart), which these order-placement tests don't want to
/// wait on and don't otherwise care about; they're exercising the
/// place-order wire contract, not address persistence (covered by
/// checkout_address_persistence_test.dart).
class _SeededAddressCheckout extends Checkout {
  @override
  CheckoutState build() {
    final s = super.build();
    return s.copyWith(
      savedAddresses: const [
        OrderAddress(
          fullName: 'Test Buyer',
          phone: '01012345678',
          street: '1 Test Street',
          city: 'Cairo',
          wilaya: 'Cairo',
          isDefault: true,
        ),
      ],
      selectedAddressIndex: 0,
    );
  }
}

/// Marks the consumer's phone as already verified so `requirePhoneVerified`
/// (checkout_screen.dart's proactive gate, and the backend's own 400 for an
/// unverified phone) doesn't intercept these order-creation-focused tests —
/// phone verification is a separate, already-covered concern.
class _VerifiedProfile extends ProfileNotifier {
  @override
  ProfileState build() {
    super.build();
    return ProfileState(
      profile: ProfileEntity(user: _consumer(), isPhoneVerified: true),
    );
  }
}

List<Override> _overrides({
  required Dio dio,
  List<CartItemEntity> cartItems = const [],
  Checkout Function()? checkout,
}) =>
    [
      authProvider.overrideWith(() => _FakeAuth(_consumer())),
      dioProvider.overrideWithValue(dio),
      cartProvider.overrideWith(() => _SeededCart(items: cartItems)),
      profileNotifierProvider.overrideWith(() => _VerifiedProfile()),
      if (checkout != null) checkoutProvider.overrideWith(checkout),
    ];

/// Builds a [ProviderContainer] for the provider-level (non-widget) test
/// cases below and waits for `AnalyticsService`'s async init to finish
/// registering its own internal listener. Without this wait, `_init()` can
/// still be mid-flight when the test body returns and `addTearDown` disposes
/// the container, so it resumes on an already-disposed container and throws
/// into whichever test happens to be running next.
Future<ProviderContainer> _buildContainer(List<Override> overrides) async {
  final container = ProviderContainer(overrides: overrides);
  addTearDown(container.dispose);
  container.listen(checkoutProvider, (_, __) {});
  await container.read(analyticsServiceProvider).ready;
  return container;
}

Widget _checkoutHarness(List<Override> overrides) {
  final router = GoRouter(
    initialLocation: AppRoutes.checkout,
    routes: [
      GoRoute(
        path: AppRoutes.checkout,
        builder: (context, state) => const CheckoutScreen(),
      ),
      GoRoute(
        path: AppRoutes.home,
        builder: (context, state) => const Scaffold(body: Text('home-stub')),
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

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    FlutterSecureStorage.setMockInitialValues({});
  });

  testWidgets(
    // Requires MOCK=false (default) — exercises the live Dio wire boundary,
    // not CartRemoteDataSourceImpl.placeOrder's mock branch.
    'happy path: placing an order with a seeded cart succeeds end to end',
    skip: MockConfig.useMock,
    (tester) async {
      final adapter = _ScriptedAdapter((options) async {
        expect(options.method, 'POST');
        expect(options.path, ApiEndpoints.orders);
        expect(
          options.data,
          {'listingId': 501, 'quantity': 1, 'latitude': anything, 'longitude': anything},
        );
        return _jsonBody({'id': 9001, 'status': 'pending'}, 201);
      });

      await tester.pumpWidget(
        _checkoutHarness(
          _overrides(
            dio: _fakeDio(adapter),
            cartItems: [_seedItem()],
            checkout: () => _SeededAddressCheckout(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Continue')); // address step -> payment step
      await tester.pumpAndSettle();
      await tester.tap(find.text('Continue')); // payment step -> review step
      await tester.pumpAndSettle();
      await tester.tap(find.textContaining('Place Order'));
      await tester.pumpAndSettle();

      expect(
        adapter.requests.where((r) => r.path == ApiEndpoints.orders).length,
        1,
        reason: 'exactly one POST /api/orders for the single cart line',
      );
      expect(find.byType(BottomSheet), findsOneWidget);
      expect(find.text('Order #9001'), findsOneWidget);
    },
  );

  test(
    'validation failure: empty cart is rejected before any network call',
    () async {
      final adapter = _ScriptedAdapter(
        (options) => fail('unexpected request for an empty cart: ${options.path}'),
      );
      final container = await _buildContainer(
        _overrides(dio: _fakeDio(adapter), cartItems: const []),
      );

      final order = await container.read(checkoutProvider.notifier).placeOrder();

      expect(order, isNull);
      expect(container.read(checkoutProvider).error, 'noItems');
      expect(adapter.requests, isEmpty);
    },
  );

  test(
    'validation failure: missing delivery address is rejected before any network call',
    () async {
      final adapter = _ScriptedAdapter(
        (options) => fail('unexpected request with no address: ${options.path}'),
      );
      final container = await _buildContainer(
        _overrides(
          dio: _fakeDio(adapter),
          cartItems: [_seedItem()],
          checkout: () => _NoAddressCheckout(),
        ),
      );

      final order = await container.read(checkoutProvider.notifier).placeOrder();

      expect(order, isNull);
      expect(container.read(checkoutProvider).error, 'noAddress');
      expect(adapter.requests, isEmpty);
    },
  );

  test(
    'backend error handling: a network failure surfaces a distinct, non-crashing error',
    skip: MockConfig.useMock ? 'Requires MOCK=false (default) — see the happy-path test above' : false,
    () async {
      final adapter = _ScriptedAdapter(
        (options) => throw DioException(
          requestOptions: options,
          type: DioExceptionType.connectionError,
          error: 'Failed host lookup',
        ),
      );
      final container = await _buildContainer(
        _overrides(
          dio: _fakeDio(adapter),
          cartItems: [_seedItem()],
          checkout: () => _SeededAddressCheckout(),
        ),
      );

      final order = await container.read(checkoutProvider.notifier).placeOrder();

      expect(order, isNull);
      expect(
        container.read(checkoutProvider).error,
        contains('Network unavailable'),
      );
    },
  );

  test(
    'backend error handling: a 400 "phone not verified" response maps to the stable error code',
    skip: MockConfig.useMock ? 'Requires MOCK=false (default) — see the happy-path test above' : false,
    () async {
      final adapter = _ScriptedAdapter(
        (options) async => _jsonBody({
          'isSuccess': false,
          'data': null,
          'errorEn': 'Please verify your phone number before placing an order.',
          'errorAr': 'يرجى التحقق من رقم هاتفك قبل تقديم الطلب.',
          'statusCode': 400,
        }, 400),
      );
      final container = await _buildContainer(
        _overrides(
          dio: _fakeDio(adapter),
          cartItems: [_seedItem()],
          checkout: () => _SeededAddressCheckout(),
        ),
      );

      final order = await container.read(checkoutProvider.notifier).placeOrder();

      expect(order, isNull);
      expect(container.read(checkoutProvider).error, phoneNotVerifiedErrorCode);
    },
  );

  test(
    'backend error handling: a 500 response surfaces the server-provided message',
    skip: MockConfig.useMock ? 'Requires MOCK=false (default) — see the happy-path test above' : false,
    () async {
      final adapter = _ScriptedAdapter(
        (options) async => _jsonBody({
          'isSuccess': false,
          'data': null,
          'errorEn': 'Internal server error. Please try again.',
          'statusCode': 500,
        }, 500),
      );
      final container = await _buildContainer(
        _overrides(
          dio: _fakeDio(adapter),
          cartItems: [_seedItem()],
          checkout: () => _SeededAddressCheckout(),
        ),
      );

      final order = await container.read(checkoutProvider.notifier).placeOrder();

      expect(order, isNull);
      expect(
        container.read(checkoutProvider).error,
        'Internal server error. Please try again.',
      );
    },
  );

  test(
    'backend error handling: auth expiry (401, no refresh token) surfaces a distinct failure, not a generic one',
    skip: MockConfig.useMock ? 'Requires MOCK=false (default) — see the happy-path test above' : false,
    () async {
      FlutterSecureStorage.setMockInitialValues({
        PrefsKeys.authToken: 'expired-token',
      });
      var refreshFailedCalled = false;
      final adapter = _ScriptedAdapter(
        (options) async => _jsonBody({
          'isSuccess': false,
          'data': null,
          'errorEn': 'Your session has expired. Please sign in again.',
          'statusCode': 401,
        }, 401),
      );
      final dio = _authAwareFakeDio(
        adapter,
        onRefreshFailed: () async => refreshFailedCalled = true,
      );
      final container = await _buildContainer(
        _overrides(
          dio: dio,
          cartItems: [_seedItem()],
          checkout: () => _SeededAddressCheckout(),
        ),
      );

      final order = await container.read(checkoutProvider.notifier).placeOrder();

      expect(order, isNull);
      expect(
        refreshFailedCalled,
        isTrue,
        reason: 'no refresh token was stored, so refresh must fail fast',
      );
      expect(
        container.read(checkoutProvider).error,
        'Your session has expired. Please sign in again.',
      );
      // Exactly the original request — no refresh call was attempted, and
      // no retry, matching TokenRefreshInterceptor's own "no refresh token"
      // contract (see test/token_refresh_interceptor_test.dart).
      expect(adapter.requests, hasLength(1));
    },
  );
}
