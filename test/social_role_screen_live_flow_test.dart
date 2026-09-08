// Screen-level, LIVE-mode test of the real SocialRoleScreen — a user who
// just finished a new-account Google sign-in picking Buyer/Seller, not
// fixture data. Matches login_screen_live_flow_test.dart's established
// pattern for exercising the real AuthRepositoryImpl -> AuthRemoteDataSourceImpl
// chain (a hand-built real AuthRepositoryImpl, stubbing only the two
// Firebase-touching constructor params).
//
// SocialRoleScreen itself never calls Google sign-in — that fires from the
// login screen's Google button before this screen is even pushed, and the
// resulting `pendingSocialResult`/`needsRoleSelection` state is what routes
// here. This test reproduces that setup by driving `socialAuthProvider`'s
// real `signInWithGoogle()` via the container right after building the
// harness (same seeding technique as otp_screen_live_flow_test.dart),
// backed by a `_FakeSocialAuth` that returns a scripted "new Google user"
// result instead of a real Google popup.
//
// Tapping Continue then exercises `completeSocialRegistration`, which for a
// Google result makes a REAL `POST /auth/google/consumer/login` call
// (resolved via the scripted Dio, same as every other live-mode test this
// session) followed by the usual token-only-response `GET get-profile`
// round trip. `AuthRemoteDataSourceImpl.loginWithGoogle` has a MockConfig
// branch — this test needs the usual `skip: MockConfig.useMock`.
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
import 'package:xstore/features/auth/presentation/providers/auth_provider.dart';
import 'package:xstore/features/auth/presentation/providers/social_auth_provider.dart';
import 'package:xstore/features/auth/presentation/screens/social_role_screen.dart';
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

  testWidgets(
    'a new Google sign-in picks Buyer and lands on home via the live wire call',
    skip: MockConfig.useMock,
    (tester) async {
      final dio = _fakeDio({
        'POST ${ApiEndpoints.googleConsumerLogin}': (_) => {
          'token': 'access-token-123',
          'refreshToken': 'refresh-token-123',
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
                  uid: 'google-uid-1',
                  email: 'newuser@gmail.com',
                  displayName: 'New Googler',
                  idToken: 'google-id-token-123',
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

      // Reproduces the login screen's Google-button tap, which is what
      // actually populates pendingSocialResult/needsRoleSelection before
      // this screen is ever reached. Deliberately not awaited — a direct
      // top-level await on anything touching Dio/Futures hangs forever
      // inside AutomatedTestWidgetsFlutterBinding's single FakeAsync zone.
      unawaited(container.read(socialAuthProvider.notifier).signInWithGoogle());
      await _settle(tester);

      expect(find.text("I'm a Buyer"), findsOneWidget);
      expect(find.textContaining('New Googler'), findsOneWidget);

      await tester.tap(find.text("I'm a Buyer"));
      await tester.pump();

      // The bottom sheet's `ListView` is a real (Sliver-backed) scroll view —
      // "Continue" sits below the fold at this test's viewport size and
      // isn't even mounted until scrolled into view.
      await tester.scrollUntilVisible(
        find.widgetWithText(XstoreButton, 'Continue'),
        300,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.tap(find.widgetWithText(XstoreButton, 'Continue'));
      await _settle(tester);

      expect(find.text('Home Screen'), findsOneWidget);

      // adoptSession starts AnalyticsService's periodic flush timer — await
      // its init so the explicit dispose() below actually cancels it (a
      // still-mid-flight _init() would create the Timer AFTER disposal,
      // leaking it). Dispose explicitly here, not via addTearDown:
      // testWidgets' pending-timer invariant check runs before addTearDown
      // callbacks fire, so a container owned by the test (not a ProviderScope
      // the framework tears down itself) must be disposed before the test
      // body returns, or that check fails on this exact timer.
      await container.read(analyticsServiceProvider).ready;
      container.dispose();
    },
  );

  testWidgets(
    'cancelling a pending Google sign-in returns to login without a session',
    (tester) async {
      final container = ProviderContainer(
        overrides: [
          authRepositoryProvider.overrideWith(
            (ref) => AuthRepositoryImpl(
              remote: ref.watch(authRemoteDataSourceProvider),
              social: _FakeSocialAuth(
                const SocialAuthResult(
                  provider: SocialProvider.google,
                  uid: 'google-uid-2',
                  email: 'anotheruser@gmail.com',
                  displayName: 'Another Googler',
                  idToken: 'google-id-token-456',
                  isNewUser: true,
                ),
              ),
              secureStorage: ref.watch(secureStorageProvider),
              firebaseAuth: _FakeFirebaseAuth(),
            ),
          ),
          dioProvider.overrideWithValue(_fakeDio(const {})),
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

      // "Cancel" sits below the fold of the bottom sheet's real Sliver-backed
      // ListView at this test's viewport size — scroll it into view first.
      await tester.scrollUntilVisible(
        find.text('Cancel'),
        300,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.tap(find.text('Cancel'));
      await _settle(tester);

      expect(find.text('Login Screen'), findsOneWidget);
      expect(container.read(authProvider).valueOrNull, isNull);

      // See the note on the test above — dispose explicitly (not via
      // addTearDown, which fires after testWidgets' pending-timer check)
      // once AnalyticsService's init has actually created its timer.
      await container.read(analyticsServiceProvider).ready;
      container.dispose();
    },
  );
}
