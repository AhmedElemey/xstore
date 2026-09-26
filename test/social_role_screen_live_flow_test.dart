// Screen-level, LIVE-mode test of the real SocialRoleScreen, plus
// provider-level tests of the Google sign-in flow. Matches
// login_screen_live_flow_test.dart's pattern for exercising the real
// AuthRepositoryImpl -> AuthRemoteDataSourceImpl chain (a hand-built real
// AuthRepositoryImpl, stubbing only the two Firebase-touching params).
//
// Google flow: only `checkGoogleUser` decides (Firebase `isNewUser` is
// ignored). A registered identity logs straight in and goes home; any other
// goes to this screen (`needsRoleSelection` + `pendingSocialResult`), and
// picking a type calls the chosen role's Google endpoint, which creates the
// account and logs in.
//
// SocialRoleScreen itself never calls Google sign-in — that fires from the
// login screen's Google button before this screen is even pushed, and the
// resulting `pendingSocialResult`/`needsRoleSelection` state is what routes
// here. The existing-identity test reproduces that setup by driving
// `socialAuthProvider`'s real `signInWithGoogle()` via the container right
// after building the harness (same seeding technique as
// otp_screen_live_flow_test.dart), backed by a `_FakeSocialAuth` that
// returns a scripted Google-sign-in result instead of a real Google popup.
//
// Unlike every other screen this session, there's no on-screen navigation
// target to assert against directly: SocialRoleScreen never calls
// context.go itself — the app's real GoRouter redirect
// (`computeXStoreAuthRedirect`, reached here via the real, keepAlive
// `routerNotifierProvider` exactly as `app_router.dart` wires it) reacts to
// `needsRoleSelection` flipping back to false once `adoptSession` runs, and
// sends the router to the signed-in user's role home. Reusing the real
// redirect function (rather than reimplementing routing logic in the test
// harness) keeps this a genuine test of the production redirect, not a
// guess at what it should do.
//
// Run with: flutter test test/social_role_screen_live_flow_test.dart
import 'dart:async';

import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
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
import 'package:xstore/core/router/router_notifier.dart';
import 'package:xstore/features/auth/data/datasources/social_auth_datasource.dart';
import 'package:xstore/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:xstore/features/auth/domain/entities/social_auth_result.dart';
import 'package:xstore/features/auth/domain/entities/user_entity.dart';
import 'package:xstore/features/auth/presentation/providers/auth_provider.dart';
import 'package:xstore/features/auth/presentation/providers/social_auth_provider.dart';
import 'package:xstore/features/auth/presentation/screens/social_role_screen.dart';

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

/// Stands in for the platform Google/Apple/Facebook popups — returns a
/// scripted "brand-new user" result for Google instead of a real sign-in.
class _FakeSocialAuth implements SocialAuthDatasource {
  _FakeSocialAuth(this._googleResult);

  final SocialAuthResult _googleResult;

  @override
  Future<SocialAuthResult> signInWithGoogle() async => _googleResult;
  @override
  Future<SocialAuthResult> signInWithApple() =>
      throw UnimplementedError('not exercised by this screen');
  @override
  Future<SocialAuthResult> signInWithFacebook() =>
      throw UnimplementedError('not exercised by this screen');
  @override
  Future<void> signOutSocial() async {}
}

/// Stands in for `AuthRepositoryImpl`'s own `firebaseAuth` param. Its
/// `noSuchMethod` throw is swallowed by `_persistSocialCredentials`'s
/// best-effort try/catch (a storage failure must never abort sign-in), so
/// this never surfaces as a test failure.
class _FakeFirebaseAuth implements FirebaseAuth {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

Map<String, dynamic> _profileJson() => {
  'user': {
    'id': 'consumer_1',
    'fullName': 'Test Buyer',
    'email': 'buyer@test.com',
    'phoneNumber': '01012345678',
  },
  'isEmailVerificationRequired': false,
  'isPhoneVerificationRequired': false,
  'isEmailVerified': false,
  'isPhoneVerified': false,
};

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
    SharedPreferences.setMockInitialValues({});
    FlutterSecureStorage.setMockInitialValues({});
  });

  test(
    'a new Google identity goes to the account-type screen, and choosing '
    'seller registers and logs in with the vendor endpoint only',
    skip: MockConfig.useMock,
    () async {
      var consumerLoginCalls = 0;
      var vendorLoginCalls = 0;
      Object? vendorBody;
      final dio = _fakeDio({
        'POST ${ApiEndpoints.googleCheckUser}': (_) => {
          'exists': false,
          'role': null,
        },
        'POST ${ApiEndpoints.googleConsumerLogin}': (_) {
          consumerLoginCalls++;
          return {'token': 'wrong', 'refreshToken': 'wrong'};
        },
        'POST ${ApiEndpoints.googleVendorLogin}': (options) {
          vendorLoginCalls++;
          vendorBody = options.data;
          return {
            'token': 'access-token-new-vendor',
            'refreshToken': 'refresh-token-new-vendor',
          };
        },
        'GET ${ApiEndpoints.getProfile}': (_) => _profileJson(),
      });

      final container = ProviderContainer(
        overrides: [
          authRepositoryProvider.overrideWith(
            (ref) => AuthRepositoryImpl(
              remote: ref.watch(authRemoteDataSourceProvider),
              social: _FakeSocialAuth(
                const SocialAuthResult(
                  provider: SocialProvider.google,
                  uid: 'google-uid-no-account',
                  email: 'noaccount@gmail.com',
                  displayName: 'No Account Googler',
                  idToken: 'google-id-token-no-account',
                  isNewUser: true,
                ),
              ),
              secureStorage: ref.watch(secureStorageProvider),
              firebaseAuth: _FakeFirebaseAuth(),
            ),
          ),
          dioProvider.overrideWithValue(dio),
        ],
      );
      addTearDown(container.dispose);

      // A plain test() doesn't run in FakeAsync, so a direct await is safe.
      await container.read(socialAuthProvider.notifier).signInWithGoogle();

      var social = container.read(socialAuthProvider);
      expect(social.needsRoleSelection, isTrue);
      expect(social.pendingSocialResult?.idToken, 'google-id-token-no-account');
      expect(consumerLoginCalls + vendorLoginCalls, 0,
          reason: 'no account is created before a type is chosen');

      await container
          .read(socialAuthProvider.notifier)
          .completeSocialRegistration(UserRole.vendor);

      social = container.read(socialAuthProvider);
      expect(vendorLoginCalls, 1);
      expect(consumerLoginCalls, 0,
          reason: 'never retried as the other role for a new account');
      expect((vendorBody as Map)['idToken'], 'google-id-token-no-account');
      expect(social.needsRoleSelection, isFalse);
      expect(social.pendingSocialResult, isNull);
      expect(social.error, isNull);
      expect(container.read(authProvider).valueOrNull, isNotNull,
          reason: 'the new account is logged in, so the router goes home');

      await container.read(analyticsServiceProvider).ready;
    },
  );

  test(
    'a returning Firebase identity that check-user does not know still goes '
    'to the account-type screen (isNewUser is ignored)',
    skip: MockConfig.useMock,
    () async {
      var consumerLoginCalls = 0;
      final dio = _fakeDio({
        'POST ${ApiEndpoints.googleCheckUser}': (_) => {
          'exists': false,
          'role': null,
        },
        'POST ${ApiEndpoints.googleConsumerLogin}': (_) {
          consumerLoginCalls++;
          return {
            'token': 'access-token-email-account',
            'refreshToken': 'refresh-token-email-account',
          };
        },
        'GET ${ApiEndpoints.getProfile}': (_) => _profileJson(),
      });

      final container = ProviderContainer(
        overrides: [
          authRepositoryProvider.overrideWith(
            (ref) => AuthRepositoryImpl(
              remote: ref.watch(authRemoteDataSourceProvider),
              social: _FakeSocialAuth(
                const SocialAuthResult(
                  provider: SocialProvider.google,
                  uid: 'google-uid-email-account',
                  email: 'rehab.mhmd2@gmail.com',
                  displayName: 'Existing Email User',
                  idToken: 'google-id-token-email-account',
                  isNewUser: false,
                ),
              ),
              secureStorage: ref.watch(secureStorageProvider),
              firebaseAuth: _FakeFirebaseAuth(),
            ),
          ),
          dioProvider.overrideWithValue(dio),
        ],
      );
      addTearDown(container.dispose);

      await container.read(socialAuthProvider.notifier).signInWithGoogle();

      final social = container.read(socialAuthProvider);
      expect(social.needsRoleSelection, isTrue);
      expect(social.pendingSocialResult, isNotNull);
      expect(consumerLoginCalls, 0,
          reason: 'no login until the user picks an account type');
    },
  );

  test(
    'a registered Google identity with an unreadable role retries vendor '
    'login when consumer returns a different-role conflict',
    skip: MockConfig.useMock,
    () async {
      var vendorLoginCalls = 0;
      final dio = _fakeDio({
        'POST ${ApiEndpoints.googleCheckUser}': (_) => {
          'exists': true,
          'role': null,
        },
        'POST ${ApiEndpoints.googleConsumerLogin}': (options) => DioException(
          requestOptions: options,
          type: DioExceptionType.badResponse,
          response: Response(
            requestOptions: options,
            statusCode: 400,
            data: {
              'isSuccess': false,
              'errorEn':
                  'This email is already registered under a different role.',
            },
          ),
        ),
        'POST ${ApiEndpoints.googleVendorLogin}': (_) {
          vendorLoginCalls++;
          return {
            'isSuccess': true,
            'data': {
              'token': 'access-token-vendor',
              'refreshToken': 'refresh-token-vendor',
            },
          };
        },
        'GET ${ApiEndpoints.getProfile}': (_) => {
          'user': {
            'id': 'vendor_1',
            'fullName': 'Test Seller',
            'email': 'seller@test.com',
            'phoneNumber': '01012345678',
            'roleName': 'Vendor',
          },
          'isEmailVerificationRequired': false,
          'isPhoneVerificationRequired': false,
          'isEmailVerified': false,
          'isPhoneVerified': false,
        },
      });

      final container = ProviderContainer(
        overrides: [
          authRepositoryProvider.overrideWith(
            (ref) => AuthRepositoryImpl(
              remote: ref.watch(authRemoteDataSourceProvider),
              social: _FakeSocialAuth(
                const SocialAuthResult(
                  provider: SocialProvider.google,
                  uid: 'google-uid-vendor-email',
                  email: 'seller@gmail.com',
                  displayName: 'Existing Vendor',
                  idToken: 'google-id-token-vendor-email',
                  isNewUser: false,
                ),
              ),
              secureStorage: ref.watch(secureStorageProvider),
              firebaseAuth: _FakeFirebaseAuth(),
            ),
          ),
          dioProvider.overrideWithValue(dio),
        ],
      );
      addTearDown(container.dispose);

      await container.read(socialAuthProvider.notifier).signInWithGoogle();

      final social = container.read(socialAuthProvider);
      expect(social.error, isNull);
      expect(vendorLoginCalls, 1);

      await container.read(analyticsServiceProvider).ready;
    },
  );

  testWidgets(
    'an existing Google identity skips the picker and lands on home directly',
    skip: MockConfig.useMock,
    (tester) async {
      final dio = _fakeDio({
        // checkGoogleUser reports this identity already has a Consumer
        // account — the picker must never appear; login goes straight
        // through with that role.
        'POST ${ApiEndpoints.googleCheckUser}': (_) => {
          'exists': true,
          'role': 'Consumer',
        },
        'POST ${ApiEndpoints.googleConsumerLogin}': (_) => {
          'token': 'access-token-456',
          'refreshToken': 'refresh-token-456',
        },
        'GET ${ApiEndpoints.getProfile}': (_) => _profileJson(),
      });

      final container = ProviderContainer(
        overrides: [
          authRepositoryProvider.overrideWith(
            (ref) => AuthRepositoryImpl(
              remote: ref.watch(authRemoteDataSourceProvider),
              social: _FakeSocialAuth(
                const SocialAuthResult(
                  provider: SocialProvider.google,
                  uid: 'google-uid-returning',
                  email: 'returning@gmail.com',
                  displayName: 'Returning Googler',
                  idToken: 'google-id-token-returning',
                  isNewUser: false,
                ),
              ),
              secureStorage: ref.watch(secureStorageProvider),
              firebaseAuth: _FakeFirebaseAuth(),
            ),
          ),
          dioProvider.overrideWithValue(dio),
        ],
      );
      final refresh = container.read(routerNotifierProvider);
      final router = GoRouter(
        initialLocation: AppRoutes.socialRoleSelect,
        refreshListenable: refresh,
        redirect: (context, state) => refresh.redirectFor(state.matchedLocation),
        routes: [
          GoRoute(
            path: AppRoutes.socialRoleSelect,
            builder: (_, __) => const SocialRoleScreen(),
          ),
          GoRoute(
            path: AppRoutes.home,
            builder: (_, __) => const Scaffold(body: Text('Home Screen')),
          ),
          GoRoute(
            path: AppRoutes.login,
            builder: (_, __) => const Scaffold(body: Text('Login Screen')),
          ),
        ],
      );
      addTearDown(router.dispose);

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
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

      // Deliberately not awaited — see the FakeAsync-zone note above.
      unawaited(container.read(socialAuthProvider.notifier).signInWithGoogle());
      await _settle(tester);

      // Never shows the picker, and lands straight on home.
      expect(find.text("I'm a Buyer"), findsNothing);
      expect(find.text('Home Screen'), findsOneWidget);
      expect(container.read(socialAuthProvider).needsRoleSelection, isFalse);

      await container.read(analyticsServiceProvider).ready;
      container.dispose();
    },
  );
}
