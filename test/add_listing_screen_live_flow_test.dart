// Screen-level, LIVE-mode test of the real AddListingScreen — a real
// vendor editing and re-publishing an existing listing, not fixture data.
// Matches test/edit_profile_screen_live_flow_test.dart's established
// pattern: real screen + real ListingRepositoryImpl ->
// ListingRemoteDataSourceImpl chain, only the Dio HTTP transport is
// scripted.
//
// This deliberately covers the EDIT path (editingListing: _existingListing,
// same fixture as test/add_listing_screen_edit_prefill_test.dart), not
// creating a brand-new listing — a new listing needs at least one photo
// (Validators.listingFormHasErrors requires photoPaths.isNotEmpty OR
// existingPhotoCount > 0), and picking one for real would need the
// image_picker platform channel, which isn't available under
// flutter_test. Editing a listing that already has a hosted image
// satisfies that requirement via existingPhotoCount without ever calling
// the picker, letting the rest of the flow — validation, category/
// condition already hydrated from the listing, and the real PUT
// update-listing wire call — run genuinely live.
//
// ListingRemoteDataSourceImpl.updateListing/createListing have no
// MockConfig branch at all (confirmed via grep) — always-live. However,
// submitting first calls `requirePhoneVerified`, which reads
// `profileNotifierProvider` (a provider AddListingScreen never fetches
// itself) — the harness seeds it verified before tapping Save, same
// seeding technique as edit_profile_screen_live_flow_test.dart. Under
// MOCK=true, ProfileRemoteDataSourceImpl.getProfile short-circuits to
// mock fixture data BEFORE this test's scripted Dio route ever runs, and
// that mock vendor profile isn't pre-verified — so requirePhoneVerified
// escalates to the email-OTP sheet, which touches Firebase the same way
// documented in profile_verification_screen_live_flow_test.dart. This
// screen's overall flow is therefore not mode-agnostic (unlike
// Notifications/MyListings/StoreHours), so this test carries the usual
// `skip: MockConfig.useMock`. A successful update also `context.go`es to
// AppRoutes.listingMy, so this needs a real GoRouter harness (like
// explore_screen_live_flow_test.dart) with a placeholder destination
// route to land on.
//
// Run with: flutter test test/add_listing_screen_live_flow_test.dart
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
import 'package:xstore/core/localization/localized_text.dart';
import 'package:xstore/core/mock/mock_config.dart';
import 'package:xstore/core/network/api_endpoints.dart';
import 'package:xstore/core/network/dio_provider.dart';
import 'package:xstore/core/router/app_routes.dart';
import 'package:xstore/features/auth/domain/entities/user_entity.dart';
import 'package:xstore/features/auth/presentation/providers/auth_provider.dart';
import 'package:xstore/features/catalog_categories/domain/entities/catalog_category_entity.dart';
import 'package:xstore/features/catalog_categories/presentation/providers/catalog_category_dependencies.dart';
import 'package:xstore/features/commission/domain/entities/vendor_commission_wallet.dart';
import 'package:xstore/features/commission/presentation/providers/commission_config_provider.dart';
import 'package:xstore/features/commission/presentation/providers/vendor_commission_wallet_provider.dart';
import 'package:xstore/features/listing/domain/entities/listing_entity.dart';
import 'package:xstore/features/listing/presentation/screens/add_listing_screen.dart';
import 'package:xstore/features/profile/presentation/providers/profile_provider.dart';

import 'helpers/fake_async_auth_notifier.dart';

/// Routes each request by (method, path) to a scripted response — same
/// technique as edit_profile_screen_live_flow_test.dart's
/// `_RoutedInterceptor`.
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

UserEntity _vendor() => const UserEntity(
  id: 'vendor_1',
  name: 'Test Vendor',
  email: 'vendor@test.com',
  phoneNumber: '01012345678',
  role: UserRole.vendor,
);

Map<String, dynamic> _profileJson() => {
  'user': {
    'id': 'vendor_1',
    'fullName': 'Test Vendor',
    'email': 'vendor@test.com',
    'phoneNumber': '01012345678',
  },
  'isEmailVerificationRequired': false,
  'isPhoneVerificationRequired': false,
  'isEmailVerified': true,
  'isPhoneVerified': true,
};

const _automotive = CatalogCategoryEntity(
  id: 7,
  name: LocalizedText(en: 'Automotive', ar: 'السيارات'),
  children: [
    CatalogCategoryEntity(
      id: 32,
      name: LocalizedText(en: 'Parts', ar: 'قطع غيار'),
      parentId: 7,
    ),
  ],
);

const _emptyWallet = VendorCommissionWallet(
  exceedsWarnThreshold: false,
  exceedsPauseThreshold: false,
  warnThresholdEgp: 100,
  pauseThresholdEgp: 200,
);

const _existingListing = ListingEntity(
  id: '42',
  title: 'Old Title',
  description: 'Old description',
  price: 199.5,
  status: ListingStatus.paused,
  titleEn: 'Wireless Mouse',
  descriptionEn: 'A great wireless mouse',
  imageUrls: ['https://example.com/a.jpg'],
  categoryId: 7,
  subcategoryId: 32,
  condition: ListingCondition.likeNew,
  brand: 'Logitech',
  stockQuantity: 3,
  shippingAvailable: true,
  shippingCost: 25,
  location: 'Cairo',
  attributes: {'Color': 'Black'},
);

Widget _routedHarness(List<Override> overrides) {
  final router = GoRouter(
    initialLocation: '/add-listing',
    routes: [
      GoRoute(
        path: '/add-listing',
        builder: (_, __) =>
            const AddListingScreen(editingListing: _existingListing),
      ),
      GoRoute(
        path: AppRoutes.listingMy,
        builder: (_, __) => const Scaffold(body: Text('My Listings Screen')),
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
/// established convention from edit_profile_screen_live_flow_test.dart.
Future<void> _settle(
  WidgetTester tester, {
  int times = 15,
  Duration step = const Duration(milliseconds: 100),
}) async {
  for (var i = 0; i < times; i++) {
    await tester.pump(step);
  }
}

/// Pumps the screen, then explicitly seeds `profileNotifierProvider` as
/// verified once `authProvider` has resolved — `requirePhoneVerified`
/// (called at the top of `_publish()`) reads that provider directly, and
/// AddListingScreen never fetches it itself.
Future<ProviderContainer> _pumpReady(
  WidgetTester tester,
  List<Override> overrides,
) async {
  await tester.pumpWidget(_routedHarness(overrides));
  await tester.pump();
  final container = ProviderScope.containerOf(
    tester.element(find.byType(AddListingScreen)),
    listen: false,
  );
  await container.read(authProvider.future);
  // Deliberately not awaited — see the FakeAsync-zone note in
  // orders_screen_live_flow_test.dart's `_pumpReady`.
  unawaited(
    container.read(profileNotifierProvider.notifier).refreshProfileData(),
  );
  return container;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    FlutterSecureStorage.setMockInitialValues({});
  });

  testWidgets(
    'vendor edits and re-publishes a listing via the live PUT wire call',
    // The requirePhoneVerified gate reads a profile that's mock-fixture
    // data under MOCK=true (see the file-level comment) — this test only
    // runs against the live backend.
    skip: MockConfig.useMock,
    (tester) async {
      final dio = _fakeDio({
        'GET ${ApiEndpoints.getProfile}': (_) => _profileJson(),
        'PUT ${ApiEndpoints.apiListings}': (_) => {
          'id': 42,
          'titleEn': 'Wireless Mouse',
          'title': 'Wireless Mouse',
          'description': 'A great wireless mouse',
          'price': 199.5,
        },
      });

      await _pumpReady(tester, [
        authProvider.overrideWith(() => FakeAuth(_vendor())),
        dioProvider.overrideWithValue(dio),
        allCatalogCategoriesProvider.overrideWith((ref) async => [_automotive]),
        vendorCommissionWalletProvider.overrideWith((ref) async => _emptyWallet),
        // Never let the real (mock-datasource) order-stats path run under
        // flutter_test — see the 2026-07-19 lesson in flutter-review/SKILL.md.
        vendorCommissionSnapshotProvider.overrideWith((ref) async => null),
      ]);
      await _settle(tester);

      expect(find.text('Update Listing'), findsOneWidget);

      await tester.tap(find.text('Update Listing'));
      await _settle(tester);

      expect(find.text('Listing updated successfully'), findsOneWidget);
      // Navigated to My Listings after a successful update.
      expect(find.text('My Listings Screen'), findsOneWidget);
    },
  );
}
