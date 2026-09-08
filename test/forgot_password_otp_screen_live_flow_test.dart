// Screen-level, LIVE-mode test of the real ForgotPasswordOtpScreen — a real
// resend triggers the real forgot-password wire call, replacing the
// hand-rolled `StubAuthRepository` fixture the original test/features/auth/
// presentation/forgot_password_otp_screen_test.dart used. Matches
// login_screen_live_flow_test.dart's established pattern for exercising the
// real repository (a hand-built real AuthRepositoryImpl, stubbing only the
// two Firebase/social-touching constructor params nothing in this flow
// reads).
//
// This screen itself never calls verify-forgot-password-otp on Continue —
// per its own doc comment, that needs the new password too, so Continue
// only forwards email + OTP to ResetPasswordScreen via `context.push`. The
// only live wire call this screen makes is forgotPassword, fired from
// Resend — which has no MockConfig branch (confirmed via grep), so this
// test needs no `skip:` flag.
//
// Run with: flutter test test/forgot_password_otp_screen_live_flow_test.dart
import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import 'package:xstore/core/localization/app_localizations.dart';
import 'package:xstore/core/network/api_endpoints.dart';
import 'package:xstore/core/network/dio_provider.dart';
import 'package:xstore/core/router/app_routes.dart';
import 'package:xstore/features/auth/data/datasources/social_auth_datasource.dart';
import 'package:xstore/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:xstore/features/auth/domain/entities/social_auth_result.dart';
import 'package:xstore/features/auth/presentation/providers/auth_provider.dart';
import 'package:xstore/features/auth/presentation/screens/forgot_password_otp_screen.dart';
import 'package:xstore/features/auth/presentation/screens/reset_password_screen.dart';

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

/// This screen's flow never calls social sign-in.
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

Widget _otpHarness(Dio dio) {
  final router = GoRouter(
    initialLocation: AppRoutes.forgotPasswordOtp,
    routes: [
      GoRoute(
        path: AppRoutes.forgotPasswordOtp,
        builder: (_, __) => const ForgotPasswordOtpScreen(email: 'jane@test.com'),
      ),
      GoRoute(
        path: AppRoutes.resetPassword,
        builder: (_, state) {
          final args = state.extra as ResetPasswordArgs;
          return Scaffold(body: Text('reset:${args.email}:${args.otpToken}'));
        },
      ),
    ],
  );
  return ProviderScope(
    overrides: [
      authRepositoryProvider.overrideWith(
        (ref) => AuthRepositoryImpl(
          remote: ref.watch(authRemoteDataSourceProvider),
          social: _FakeSocialAuth(),
          secureStorage: ref.watch(secureStorageProvider),
          firebaseAuth: _FakeFirebaseAuth(),
        ),
      ),
      dioProvider.overrideWithValue(dio),
    ],
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
  testWidgets(
    'completing a 6-digit OTP forwards it (unverified) to the new-password screen',
    (tester) async {
      await tester.pumpWidget(_otpHarness(_fakeDio(const {})));
      // OtpResendCooldown's periodic timer never lets pumpAndSettle complete.
      await tester.pump();

      expect(find.textContaining('jane@test.com'), findsOneWidget);

      await tester.enterText(find.byType(EditableText), '483921');
      await tester.pump();
      await tester.pump();

      expect(find.text('reset:jane@test.com:483921'), findsOneWidget);
    },
  );

  testWidgets(
    'resend fires the live forgot-password wire call and surfaces its debug OTP',
    (tester) async {
      final dio = _fakeDio({
        'POST ${ApiEndpoints.forgotPassword}': (_) => {'otp': '111222'},
      });
      await tester.pumpWidget(_otpHarness(dio));
      await tester.pump();

      // Resend is gated behind a 60s cooldown that starts on open — advance
      // past it before tapping.
      await tester.pump(const Duration(seconds: 61));

      await tester.tap(find.textContaining('Resend'));
      for (var i = 0; i < 15; i++) {
        await tester.pump(const Duration(milliseconds: 100));
      }

      expect(find.textContaining('Debug OTP: 111222'), findsOneWidget);
    },
  );
}
