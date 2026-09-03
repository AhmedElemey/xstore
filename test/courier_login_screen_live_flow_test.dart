// Screen-level, LIVE-mode test of the real CourierLoginScreen — a real
// courier signing in with phone + password, not fixture data. Matches
// test/login_screen_live_flow_test.dart's established pattern for
// exercising the real AuthRepositoryImpl -> AuthRemoteDataSourceImpl
// chain (a hand-built real AuthRepositoryImpl, stubbing only the two
// Firebase-touching constructor params nothing in this flow reads) —
// this screen reuses the exact same `LoginNotifier.login()` flow as
// LoginScreen, just from a dedicated courier-branded form.
//
// The screen's OTP mode is MOCK-ONLY by explicit design (`if
// (!MockConfig.useMock) { AppSnackbar.error(...); return; }` — no backend
// courier accounts or courier OTP route exist yet, per the source
// comment), so a live-mode test can only exercise the password path for
// a successful login; the second test locks in that OTP mode correctly
// refuses under live mode instead of silently doing nothing.
//
// login() has a MockConfig branch — this test needs the usual
// `skip: MockConfig.useMock`.
//
// Run with: flutter test test/courier_login_screen_live_flow_test.dart
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
import 'package:xstore/features/auth/presentation/screens/courier_login_screen.dart';
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
/// flow never calls social sign-in.
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
    'id': 'courier_1',
    'fullName': 'Test Courier',
    'email': 'courier@test.com',
    'phoneNumber': '01012345678',
  },
  'isEmailVerificationRequired': false,
  'isPhoneVerificationRequired': false,
  'isEmailVerified': false,
  'isPhoneVerified': true,
};

Widget _routedHarness(List<Override> overrides) {
  final router = GoRouter(
    initialLocation: AppRoutes.courierLogin,
    routes: [
      GoRoute(
        path: AppRoutes.courierLogin,
        builder: (_, __) => const CourierLoginScreen(),
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
    'courier logs in with phone and password via the live wire call',
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
    'OTP mode refuses under live mode instead of silently doing nothing',
    skip: MockConfig.useMock,
    (tester) async {
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
          dioProvider.overrideWithValue(_fakeDio(const {})),
        ]),
      );
      await _settle(tester);

      await tester.tap(find.text('OTP'));
      await tester.pump();

      final fields = find.byType(TextFormField);
      await tester.enterText(fields.at(0), '01012345678');
      await tester.pump();

      await tester.tap(find.text('Send code'));
      await _settle(tester);

      expect(
        find.text(
          'OTP sign-in becomes available once delivery accounts go live on the backend.',
        ),
        findsOneWidget,
      );
      // Never advanced to the OTP-entry state.
      expect(find.text('Verify & sign in'), findsNothing);
    },
  );
}
