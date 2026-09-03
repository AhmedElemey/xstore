// Screen-level, LIVE-mode test of the real ForgotPasswordScreen — a real
// email submission through the real AuthRepositoryImpl ->
// AuthRemoteDataSourceImpl chain, not the hand-rolled `StubAuthRepository`
// fixture the original test/features/auth/presentation/
// forgot_password_screen_test.dart used. Matches
// login_screen_live_flow_test.dart's established pattern for exercising the
// real repository (a hand-built real AuthRepositoryImpl, stubbing only the
// two Firebase/social-touching constructor params nothing in this flow
// reads — forgotPassword never calls either).
//
// AuthRemoteDataSourceImpl.forgotPassword has NO MockConfig branch
// (confirmed via grep) — genuinely always-live, so this test needs no
// `skip:` flag and runs identically in both modes.
//
// Run with: flutter test test/forgot_password_screen_live_flow_test.dart
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
import 'package:xstore/features/auth/presentation/screens/forgot_password_screen.dart';

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

Widget _harness(List<Override> overrides) {
  final router = GoRouter(
    initialLocation: AppRoutes.forgotPassword,
    routes: [
      GoRoute(
        path: AppRoutes.forgotPassword,
        builder: (_, __) => const ForgotPasswordScreen(),
      ),
      GoRoute(
        path: AppRoutes.forgotPasswordOtp,
        builder: (_, state) =>
            Scaffold(body: Text('forgot-otp:${state.extra}')),
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

List<Override> _overrides(Dio dio) => [
  authRepositoryProvider.overrideWith(
    (ref) => AuthRepositoryImpl(
      remote: ref.watch(authRemoteDataSourceProvider),
      social: _FakeSocialAuth(),
      secureStorage: ref.watch(secureStorageProvider),
      firebaseAuth: _FakeFirebaseAuth(),
    ),
  ),
  dioProvider.overrideWithValue(dio),
];

Future<void> _submitEmail(WidgetTester tester) async {
  await tester.enterText(find.byType(TextField), 'jane@test.com');
  await tester.tap(find.text('Send Reset Code'));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets(
    'does not show a debug OTP snackbar when the live API omits otp',
    (tester) async {
      final dio = _fakeDio({
        'POST ${ApiEndpoints.forgotPassword}': (_) => <String, dynamic>{},
      });
      await tester.pumpWidget(_harness(_overrides(dio)));
      await tester.pumpAndSettle();
      await _submitEmail(tester);

      expect(find.textContaining('Debug OTP'), findsNothing);
      expect(find.text('forgot-otp:jane@test.com'), findsOneWidget);
    },
  );

  testWidgets(
    'shows a debug OTP snackbar only when the live API returned otp',
    (tester) async {
      final dio = _fakeDio({
        'POST ${ApiEndpoints.forgotPassword}': (_) => {'otp': '654321'},
      });
      await tester.pumpWidget(_harness(_overrides(dio)));
      await tester.pumpAndSettle();
      await _submitEmail(tester);

      expect(find.textContaining('Debug OTP: 654321'), findsOneWidget);
    },
  );
}
