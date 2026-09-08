// Screen-level, LIVE-mode test of the real ResetPasswordScreen — a real
// `POST verify-forget-password-otp` wire call, replacing the hand-rolled
// `StubAuthRepository` fixture the original test/features/auth/presentation/
// reset_password_screen_test.dart used. Matches
// login_screen_live_flow_test.dart's established pattern for exercising the
// real repository (a hand-built real AuthRepositoryImpl, stubbing only the
// two Firebase/social-touching constructor params nothing in this flow
// reads).
//
// AuthRemoteDataSourceImpl.verifyForgotPasswordOtp has NO MockConfig branch
// (confirmed via grep) — genuinely always-live, so this test needs no
// `skip:` flag and runs identically in both modes.
//
// Run with: flutter test test/reset_password_screen_live_flow_test.dart
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
import 'package:xstore/features/auth/presentation/screens/reset_password_screen.dart';
import 'package:xstore/shared/widgets/xstore_button.dart';

/// Routes each request by (method, path) to a scripted response, and
/// records the last request body — same technique as
/// login_screen_live_flow_test.dart's `_RoutedInterceptor`, extended to
/// capture the payload so the test can assert on it (matching what the
/// old `StubAuthRepository` fixture's `lastVerifyForgot*` fields checked).
class _RoutedInterceptor extends Interceptor {
  _RoutedInterceptor(this._routes, this._onRequest);

  final Map<String, Object? Function(RequestOptions options)> _routes;
  final void Function(RequestOptions options) _onRequest;

  String _key(RequestOptions o) => '${o.method} ${o.path}';

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    _onRequest(options);
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

Widget _harness(List<Override> overrides) {
  final router = GoRouter(
    initialLocation: AppRoutes.resetPassword,
    routes: [
      GoRoute(
        path: AppRoutes.resetPassword,
        builder: (_, __) => const ResetPasswordScreen(
          args: ResetPasswordArgs(email: 'consumer@test.com', otpToken: '483921'),
        ),
      ),
      GoRoute(
        path: AppRoutes.login,
        builder: (_, __) => const Scaffold(body: Text('login')),
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
  testWidgets(
    'submits email, otpToken, newPassword, confirmNewPassword then goes to login',
    (tester) async {
      RequestOptions? captured;
      final dio = Dio(BaseOptions(baseUrl: ApiEndpoints.baseUrl));
      dio.interceptors.add(
        _RoutedInterceptor(
          {'POST ${ApiEndpoints.verifyForgotPasswordOtp}': (_) => null},
          (options) => captured = options,
        ),
      );

      await tester.pumpWidget(
        _harness([
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
      await tester.pumpAndSettle();

      final fields = find.byType(TextField);
      await tester.enterText(fields.at(0), 'NewPass1!');
      await tester.enterText(fields.at(1), 'NewPass1!');
      await tester.tap(find.widgetWithText(XstoreButton, 'Reset Password'));
      await tester.pumpAndSettle();

      final body = captured!.data as Map<String, dynamic>;
      expect(body['email'], 'consumer@test.com');
      expect(body['otpToken'], '483921');
      expect(body['newPassword'], 'NewPass1!');
      expect(body['confirmNewPassword'], 'NewPass1!');
      expect(find.text('login'), findsOneWidget);
    },
  );
}
