// Screen-level, LIVE-mode test of the real RegisterScreen — a real
// consumer completing the 3-step registration wizard, not fixture data.
// Matches test/login_screen_live_flow_test.dart's established pattern for
// exercising the real AuthRepositoryImpl -> AuthRemoteDataSourceImpl
// chain (a hand-built real AuthRepositoryImpl, stubbing only the two
// Firebase-touching constructor params nothing in this flow reads).
//
// registerConsumer() has no MockConfig branch at all (confirmed via
// grep) — always-live, and this test's only other providers
// (allGovernmentsProvider/allCitiesProvider, overridden below with
// static data to skip the location-picker bottom sheets) don't touch
// MockConfig either, so no `skip:` flag is needed — verified to pass
// identically under both `flutter test` and `flutter test
// --dart-define=MOCK=true`.
//
// Register has no user fields on the wire either — same
// {token, refreshToken}-only contract as login, resolved via the same
// GET get-profile fetchProfile call.
//
// Unlike LoginScreen/ProfileVerificationScreen, a successful CONSUMER
// registration has NO explicit in-screen navigation — `_executeRegister`
// only shows the vendor-only success overlay + "Go to My Store" button
// for a vendor session; a consumer is expected to be redirected off
// /register by the app-wide GoRouter `redirect:` (reacting to
// authProvider), which lives outside this screen and isn't part of this
// test's minimal router. The real, verifiable signal this test checks is
// that `authProvider` now holds the newly registered user — the same
// thing the app-wide redirect itself would react to.
//
// The location cascade (LocationCascadeField) is a required field on
// step 2, fed by its own governorate/city bottom-sheet pickers — this
// test sets `storeCityId`/`storeGovernmentId` directly via the
// container (like AddListingScreen's editingListing prefill) rather
// than driving those extra bottom sheets, since they're tangential to
// what this test verifies.
//
// Run with: flutter test test/register_screen_live_flow_test.dart
import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:xstore/core/constants/prefs_keys.dart';
import 'package:xstore/core/localization/app_localizations.dart';
import 'package:xstore/core/localization/localized_text.dart';
import 'package:xstore/core/network/api_endpoints.dart';
import 'package:xstore/core/network/dio_provider.dart';
import 'package:xstore/core/router/app_routes.dart';
import 'package:xstore/features/auth/data/datasources/social_auth_datasource.dart';
import 'package:xstore/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:xstore/features/auth/domain/entities/social_auth_result.dart';
import 'package:xstore/features/auth/presentation/providers/auth_provider.dart';
import 'package:xstore/features/auth/presentation/screens/register_screen.dart';
import 'package:xstore/features/cities/domain/entities/city_entity.dart';
import 'package:xstore/features/cities/presentation/providers/city_dependencies.dart';
import 'package:xstore/features/governments/domain/entities/government_entity.dart';
import 'package:xstore/features/governments/presentation/providers/government_dependencies.dart';
import 'package:xstore/shared/widgets/xstore_button.dart';

/// Routes each request by (method, path) to a scripted response — same
/// technique as login_screen_live_flow_test.dart's `_RoutedInterceptor`.
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

/// Stands in only for the Firebase-touching half of auth — this screen's
/// password-registration flow never calls social sign-in.
class _FakeSocialAuth implements SocialAuthDatasource {
  @override
  Future<SocialAuthResult> signInWithGoogle() =>
      throw UnimplementedError('not exercised by this screen');
  @override
  Future<SocialAuthResult> signInWithApple() =>
      throw UnimplementedError('not exercised by this screen');
  @override
  Future<SocialAuthResult> signInWithFacebook() =>
      throw UnimplementedError('not exercised by this screen');
  @override
  Future<void> signOutSocial() async {}
}

/// Stands in for `AuthRepositoryImpl`'s own `firebaseAuth` param — never
/// called by this screen's flow.
class _FakeFirebaseAuth implements FirebaseAuth {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

Map<String, dynamic> _profileJson() => {
  'user': {
    'id': 'consumer_1',
    'fullName': 'Test User',
    'email': 'newuser@test.com',
    'phoneNumber': '01012345678',
  },
  'isEmailVerificationRequired': false,
  'isPhoneVerificationRequired': false,
  'isEmailVerified': false,
  'isPhoneVerified': false,
};

Widget _routedHarness(List<Override> overrides) {
  final router = GoRouter(
    initialLocation: AppRoutes.register,
    routes: [
      GoRoute(
        path: AppRoutes.register,
        builder: (_, __) => const RegisterScreen(),
      ),
      GoRoute(
        path: AppRoutes.home,
        builder: (_, __) => const Scaffold(body: Text('Home Screen')),
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
/// established convention from login_screen_live_flow_test.dart.
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
    SharedPreferences.setMockInitialValues({
      // See the flutter-review SKILL.md lesson on seeding the actual
      // PrefsKeys string value, not the Dart constant's name.
      PrefsKeys.locationPermissionRationaleShown: true,
    });
    FlutterSecureStorage.setMockInitialValues({});
  });

  testWidgets(
    'consumer completes registration via the live wire call',
    (tester) async {
      final dio = _fakeDio({
        'POST ${ApiEndpoints.consumerRegister}': (_) => {
          'token': 'access-token-123',
          'refreshToken': 'refresh-token-123',
        },
        'GET ${ApiEndpoints.getProfile}': (_) => _profileJson(),
      });

      await tester.pumpWidget(
        _routedHarness([
          authRepositoryProvider.overrideWith(
            (ref) => AuthRepositoryImpl(
              remote: ref.watch(authRemoteDataSourceProvider),
              social: _FakeSocialAuth(),
              secureStorage: ref.watch(secureStorageProvider),
              firebaseAuth: _FakeFirebaseAuth(),
            ),
          ),
          dioProvider.overrideWithValue(dio),
          allGovernmentsProvider.overrideWith(
            (ref) async => const [
              GovernmentEntity(id: 1, name: LocalizedText(en: 'Cairo', ar: 'القاهرة')),
            ],
          ),
          allCitiesProvider.overrideWith(
            (ref) async => const [
              CityEntity(
                id: 1,
                name: LocalizedText(en: 'Nasr City', ar: 'مدينة نصر'),
                governorateId: 1,
              ),
            ],
          ),
        ]),
      );
      await _settle(tester);

      final container = ProviderScope.containerOf(
        tester.element(find.byType(RegisterScreen)),
        listen: false,
      );

      // Step 1: role.
      await tester.tap(find.text("I'm a Buyer"));
      await tester.pump();
      await tester.tap(find.widgetWithText(XstoreButton, 'Continue'));
      await _settle(tester);

      // Step 2: personal info. The location cascade is seeded directly
      // (see file-level comment) rather than driving its picker sheets.
      var fields = find.byType(TextFormField);
      await tester.enterText(fields.at(0), 'Test User');
      await tester.enterText(fields.at(1), 'newuser@test.com');
      await tester.enterText(fields.at(2), '01012345678');
      container
          .read(registerNotifierProvider.notifier)
          .updateStoreLocation(storeCityId: 1, storeGovernmentId: 1);
      await tester.pump();
      await tester.tap(find.widgetWithText(XstoreButton, 'Continue'));
      await _settle(tester);

      // Step 3: security. The terms checkbox sits below the fold once
      // the password-strength bar and both fields are rendered.
      fields = find.byType(TextFormField);
      await tester.enterText(fields.at(0), 'Password123!');
      await tester.enterText(fields.at(1), 'Password123!');
      await tester.pump();
      await tester.scrollUntilVisible(
        find.byType(Checkbox),
        200,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.tap(find.byType(Checkbox));
      await tester.pump();
      await tester.tap(find.widgetWithText(XstoreButton, 'Continue'));
      await _settle(tester);

      expect(
        container.read(authProvider).valueOrNull?.id,
        'consumer_1',
      );
    },
  );
}
