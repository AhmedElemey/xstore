// Screen-level, LIVE-mode test of the real LoginScreen — a real user
// logging in with phone + password, not fixture data. Matches
// test/profile_verification_screen_live_flow_test.dart's established
// pattern for exercising the real AuthRepositoryImpl ->
// AuthRemoteDataSourceImpl chain: `authRepositoryProvider` is overridden
// with a hand-built REAL `AuthRepositoryImpl`, stubbing only the two
// constructor params (`social`, `firebaseAuth`) nothing in this flow
// reads, per the flutter-review SKILL.md lesson on why faking the whole
// repository there would gut the point of the test.
//
// Login has no user fields on the wire — CONFIRMED live: POST
// /api/auth/login returns only {token, refreshToken}; the repository
// then calls GET get-profile (fetchProfile) to resolve the actual user,
// same endpoint every profile-feature test this session already scripts.
//
// LoginScreen needs a real GoRouter (context.push/go to register,
// forgot-password, and home). A successful login also triggers
// `maybeShowLocationPermissionPrompt`, which shows a one-time rationale
// dialog gated on a SharedPreferences flag — seeding that flag `true`
// skips the extra dialog so the test can focus on the login flow itself.
//
// login()/fetchProfile() have no MockConfig branch... actually login()
// DOES branch (mock-mode fakes the login model) — this test needs the
// usual `skip: MockConfig.useMock`.
//
// Run with: flutter test test/login_screen_live_flow_test.dart
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
import 'package:xstore/core/mock/mock_config.dart';
import 'package:xstore/core/network/api_endpoints.dart';
import 'package:xstore/core/network/dio_provider.dart';
import 'package:xstore/core/router/app_routes.dart';
import 'package:xstore/features/auth/data/datasources/social_auth_datasource.dart';
import 'package:xstore/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:xstore/features/auth/domain/entities/social_auth_result.dart';
import 'package:xstore/features/auth/presentation/providers/auth_provider.dart';
import 'package:xstore/features/auth/presentation/screens/login_screen.dart';
import 'package:xstore/shared/widgets/xstore_button.dart';

/// Routes each request by (method, path) to a scripted response — same
/// technique as profile_verification_screen_live_flow_test.dart's
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

/// Stands in only for the Firebase-touching half of auth — this screen's
/// password-login flow never calls social sign-in.
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
    'fullName': 'Test Buyer',
    'email': 'buyer@test.com',
    'phoneNumber': '01012345678',
  },
  'isEmailVerificationRequired': false,
  'isPhoneVerificationRequired': false,
  'isEmailVerified': true,
  'isPhoneVerified': true,
};

Widget _routedHarness(List<Override> overrides) {
  final router = GoRouter(
    initialLocation: AppRoutes.login,
    routes: [
      GoRoute(path: AppRoutes.login, builder: (_, __) => const LoginScreen()),
      GoRoute(
        path: AppRoutes.home,
        builder: (_, __) => const Scaffold(body: Text('Home Screen')),
      ),
      GoRoute(
        path: AppRoutes.register,
        builder: (_, __) => const Scaffold(body: Text('Register Screen')),
      ),
      GoRoute(
        path: AppRoutes.forgotPassword,
        builder: (_, __) =>
            const Scaffold(body: Text('Forgot Password Screen')),
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
/// established convention from profile_verification_screen_live_flow_test
/// .dart.
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
      // Skips the one-time location-permission rationale dialog that
      // would otherwise block a successful login's navigation to home —
      // unrelated to what this test is verifying. Must be the actual
      // wire key (PrefsKeys' string VALUE), not the Dart constant's
      // name — seeding the wrong string leaves `alreadyShown` false,
      // and the real, un-tappable dialog then hangs the test forever
      // waiting for a choice that never comes (this was a real bug in
      // an earlier version of this test, not a production issue).
      PrefsKeys.locationPermissionRationaleShown: true,
    });
    FlutterSecureStorage.setMockInitialValues({});
  });

  testWidgets(
    'consumer logs in with phone and password via the live wire call',
    skip: MockConfig.useMock,
    (tester) async {
      final dio = _fakeDio({
        'POST ${ApiEndpoints.apiLogin}': (_) => {
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
        ]),
      );
      await _settle(tester);

      final fields = find.byType(TextFormField);
      await tester.enterText(fields.at(0), '01012345678');
      await tester.enterText(fields.at(1), 'Password123');
      await tester.pump();

      await tester.tap(find.widgetWithText(XstoreButton, 'Login'));
      await _settle(tester);

      expect(find.text('Home Screen'), findsOneWidget);
    },
  );

  testWidgets(
    'an invalid password shows the live 401 error and does not navigate',
    skip: MockConfig.useMock,
    (tester) async {
      final dio = _fakeDio({
        'POST ${ApiEndpoints.apiLogin}': (_) => DioException(
          requestOptions: RequestOptions(path: ApiEndpoints.apiLogin),
          response: Response(
            requestOptions: RequestOptions(path: ApiEndpoints.apiLogin),
            statusCode: 401,
            data: {'message': 'Invalid credentials'},
          ),
        ),
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
        ]),
      );
      await _settle(tester);

      final fields = find.byType(TextFormField);
      await tester.enterText(fields.at(0), '01012345678');
      await tester.enterText(fields.at(1), 'WrongPassword1');
      await tester.pump();

      await tester.tap(find.widgetWithText(XstoreButton, 'Login'));
      await _settle(tester);

      expect(find.text('Home Screen'), findsNothing);
      // Still on the login form.
      expect(find.widgetWithText(XstoreButton, 'Login'), findsOneWidget);
    },
  );
}
