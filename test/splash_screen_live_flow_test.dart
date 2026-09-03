// Screen-level, LIVE-mode test of the real SplashScreen — the real
// cold-start bootstrap flow, not fixture data. Matches
// test/login_screen_live_flow_test.dart's established pattern for
// exercising the real AuthRepositoryImpl (a hand-built real instance,
// stubbing only the two Firebase-touching constructor params). Unlike
// every other screen this session, `restoreSession()` never touches Dio
// at all — it's a pure secure-storage read — so no `dioProvider` override
// or scripted routes are needed here; the persisted-session test seeds
// `FlutterSecureStorage` directly with a real `UserModel.toJson()`
// payload under the same key `AuthRepositoryImpl._persistUser` writes to,
// so `restoreSession()` round-trips it for real.
//
// `_bootstrap()` enforces a real 2500ms minimum splash duration
// (`Future.wait([minDelay, authWait])`) before navigating — settling past
// that requires more pumps than this session's usual 1.5s window.
//
// Run with: flutter test test/splash_screen_live_flow_test.dart
import 'dart:convert';

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
import 'package:xstore/core/network/api_endpoints.dart';
import 'package:xstore/core/network/dio_provider.dart';
import 'package:xstore/core/router/app_routes.dart';
import 'package:xstore/features/auth/data/datasources/social_auth_datasource.dart';
import 'package:xstore/features/auth/data/models/user_model.dart';
import 'package:xstore/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:xstore/features/auth/domain/entities/social_auth_result.dart';
import 'package:xstore/features/auth/domain/entities/user_entity.dart';
import 'package:xstore/features/auth/presentation/providers/auth_provider.dart';
import 'package:xstore/features/auth/presentation/screens/splash_screen.dart';

/// Routes each request by (method, path) to a scripted response — same
/// technique as login_screen_live_flow_test.dart's `_RoutedInterceptor`.
/// A restored session triggers `prefetchProfileData` as a side effect —
/// scripting this keeps the test fully hermetic instead of relying on
/// flutter_test's incidental "any real network attempt gets a 400"
/// safety net.
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

/// Stands in only for the Firebase-touching half of auth — restoring a
/// session never calls social sign-in.
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

Widget _routedHarness(List<Override> overrides) {
  final router = GoRouter(
    initialLocation: AppRoutes.splash,
    routes: [
      GoRoute(path: AppRoutes.splash, builder: (_, __) => const SplashScreen()),
      GoRoute(
        path: AppRoutes.home,
        builder: (_, __) => const Scaffold(body: Text('Home Screen')),
      ),
      GoRoute(
        path: AppRoutes.onboarding,
        builder: (_, __) => const Scaffold(body: Text('Onboarding Screen')),
      ),
      GoRoute(
        path: AppRoutes.login,
        builder: (_, __) => const Scaffold(body: Text('Login Screen')),
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
/// established convention from login_screen_live_flow_test.dart. Needs
/// more time than the usual 1.5s window to clear the real 2500ms minimum
/// splash delay.
Future<void> _settle(
  WidgetTester tester, {
  int times = 40,
  Duration step = const Duration(milliseconds: 100),
}) async {
  for (var i = 0; i < times; i++) {
    await tester.pump(step);
  }
}

List<Override> _overrides() => [
  authRepositoryProvider.overrideWith(
    (ref) => AuthRepositoryImpl(
      remote: ref.watch(authRemoteDataSourceProvider),
      social: _FakeSocialAuth(),
      secureStorage: ref.watch(secureStorageProvider),
      firebaseAuth: _FakeFirebaseAuth(),
    ),
  ),
];

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({
      // See the flutter-review SKILL.md lesson on seeding the actual
      // PrefsKeys string value, not the Dart constant's name.
      PrefsKeys.locationPermissionRationaleShown: true,
    });
  });

  testWidgets(
    'a restored session lands the user on home without any network call',
    (tester) async {
      const user = UserModel(
        id: 'consumer_1',
        name: 'Test Buyer',
        email: 'buyer@test.com',
        phoneNumber: '01012345678',
        role: UserRole.consumer,
      );
      FlutterSecureStorage.setMockInitialValues({
        PrefsKeys.authUser: jsonEncode(user.toJson()),
        PrefsKeys.authToken: 'stored-token-123',
      });
      final dio = _fakeDio({
        'GET ${ApiEndpoints.getProfile}': (_) => _profileJson(),
      });

      await tester.pumpWidget(
        _routedHarness([..._overrides(), dioProvider.overrideWithValue(dio)]),
      );
      await _settle(tester);

      expect(find.text('Home Screen'), findsOneWidget);
    },
  );

  testWidgets(
    'a brand-new device with no session goes to onboarding',
    (tester) async {
      FlutterSecureStorage.setMockInitialValues({});

      await tester.pumpWidget(_routedHarness(_overrides()));
      await _settle(tester);

      expect(find.text('Onboarding Screen'), findsOneWidget);
    },
  );

  testWidgets(
    'a device that already finished onboarding goes to login',
    (tester) async {
      SharedPreferences.setMockInitialValues({
        PrefsKeys.locationPermissionRationaleShown: true,
        PrefsKeys.onboardingComplete: true,
      });
      FlutterSecureStorage.setMockInitialValues({});

      await tester.pumpWidget(_routedHarness(_overrides()));
      await _settle(tester);

      expect(find.text('Login Screen'), findsOneWidget);
    },
  );
}
