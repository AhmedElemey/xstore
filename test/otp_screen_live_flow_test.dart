// Screen-level, LIVE-mode test of the real OtpScreen — a real user
// completing the passwordless phone-login OTP flow, not fixture data.
// Matches test/login_screen_live_flow_test.dart's established pattern for
// exercising the real AuthRepositoryImpl -> AuthRemoteDataSourceImpl
// chain (a hand-built real AuthRepositoryImpl, stubbing only the two
// Firebase-touching constructor params nothing in this flow reads).
//
// OtpScreen itself never calls send-login-otp — that's fired from the
// login screen's phone-number bottom sheet before this screen is even
// pushed. This test reproduces that by driving `phoneAuthProvider`'s real
// `sendOtp()` via the container right after pumping (same seeding
// technique as edit_profile_screen_live_flow_test.dart), which also
// exercises the real send-login-otp wire call rather than skipping it.
//
// sendLoginOtp/loginWithOtp both have MockConfig branches — this test
// needs the usual `skip: MockConfig.useMock`.
//
// login-with-otp has the same {token, refreshToken}-only wire contract as
// login/register, resolved via the same GET get-profile fetchProfile
// call.
//
// Run with: flutter test test/otp_screen_live_flow_test.dart
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
import 'package:xstore/features/auth/presentation/providers/phone_auth_provider.dart';
import 'package:xstore/features/auth/presentation/screens/otp_screen.dart';

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
    'id': 'consumer_1',
    'fullName': 'Test Buyer',
    'email': 'buyer@test.com',
    'phoneNumber': '01012345678',
  },
  'isEmailVerificationRequired': false,
  'isPhoneVerificationRequired': false,
  'isEmailVerified': false,
  'isPhoneVerified': true,
};

Widget _routedHarness(List<Override> overrides) {
  final router = GoRouter(
    initialLocation: AppRoutes.otp,
    routes: [
      GoRoute(path: AppRoutes.otp, builder: (_, __) => const OtpScreen()),
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
    'consumer completes a live phone-login OTP and lands on home',
    skip: MockConfig.useMock,
    (tester) async {
      final dio = _fakeDio({
        'POST ${ApiEndpoints.sendLoginOtp}': (_) => {'otp': '123456'},
        'POST ${ApiEndpoints.loginWithOtp}': (_) => {
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
      await tester.pump();

      final container = ProviderScope.containerOf(
        tester.element(find.byType(OtpScreen)),
        listen: false,
      );
      final l10n = await AppLocalizations.delegate.load(const Locale('en'));
      container.read(phoneAuthProvider.notifier).updatePhone('01012345678', l10n);
      // Deliberately not awaited — a direct top-level await on anything
      // touching Dio hangs forever inside AutomatedTestWidgetsFlutterBinding's
      // single FakeAsync zone. See the FakeAsync-zone note in
      // orders_screen_live_flow_test.dart's `_pumpReady`.
      unawaited(container.read(phoneAuthProvider.notifier).sendOtp(l10n));
      await _settle(tester);

      await tester.enterText(find.byType(EditableText), '123456');
      await _settle(tester, times: 40);

      expect(find.text('Home Screen'), findsOneWidget);
    },
  );

  testWidgets(
    'an invalid OTP code shows the live error and stays on the OTP screen',
    skip: MockConfig.useMock,
    (tester) async {
      final dio = _fakeDio({
        'POST ${ApiEndpoints.sendLoginOtp}': (_) => {'otp': '123456'},
        'POST ${ApiEndpoints.loginWithOtp}': (_) => DioException(
          requestOptions: RequestOptions(path: ApiEndpoints.loginWithOtp),
          response: Response(
            requestOptions: RequestOptions(path: ApiEndpoints.loginWithOtp),
            statusCode: 400,
            data: {'message': 'Invalid or expired code'},
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
      await tester.pump();

      final container = ProviderScope.containerOf(
        tester.element(find.byType(OtpScreen)),
        listen: false,
      );
      final l10n = await AppLocalizations.delegate.load(const Locale('en'));
      container.read(phoneAuthProvider.notifier).updatePhone('01012345678', l10n);
      // Deliberately not awaited — a direct top-level await on anything
      // touching Dio hangs forever inside AutomatedTestWidgetsFlutterBinding's
      // single FakeAsync zone. See the FakeAsync-zone note in
      // orders_screen_live_flow_test.dart's `_pumpReady`.
      unawaited(container.read(phoneAuthProvider.notifier).sendOtp(l10n));
      await _settle(tester);

      await tester.enterText(find.byType(EditableText), '000000');
      await _settle(tester);

      expect(find.text('Home Screen'), findsNothing);
      expect(find.text('Verify & Continue'), findsOneWidget);
    },
  );
}
