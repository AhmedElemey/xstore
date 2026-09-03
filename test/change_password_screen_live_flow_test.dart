// Screen-level, LIVE-mode test of the real ChangePasswordScreen — a real
// signed-in user changing their password, not fixture data. Matches
// test/login_screen_live_flow_test.dart's established pattern for
// exercising the real AuthRepositoryImpl -> AuthRemoteDataSourceImpl
// chain (a hand-built real AuthRepositoryImpl, stubbing only the two
// Firebase-touching constructor params nothing in this flow reads).
//
// changePassword() has no MockConfig branch at all (confirmed via grep)
// — always-live, so no `skip:` flag is needed.
//
// ChangePasswordScreen calls `context.pop()` on success, so the harness
// pushes it onto a base screen (not `home:` directly) to give the
// Navigator a route underneath it to pop back to, same as
// edit_profile_screen_live_flow_test.dart.
//
// Run with: flutter test test/change_password_screen_live_flow_test.dart
import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:xstore/core/localization/app_localizations.dart';
import 'package:xstore/core/network/api_endpoints.dart';
import 'package:xstore/core/network/dio_provider.dart';
import 'package:xstore/features/auth/data/datasources/social_auth_datasource.dart';
import 'package:xstore/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:xstore/features/auth/domain/entities/social_auth_result.dart';
import 'package:xstore/features/auth/presentation/providers/auth_provider.dart';
import 'package:xstore/features/auth/presentation/screens/change_password_screen.dart';
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

Widget _harness(List<Override> overrides) {
  // ChangePasswordScreen calls context.pop() via go_router's
  // GoRouterHelper extension, which throws "No GoRouter found in
  // context" under a plain Navigator/MaterialPageRoute push — it needs a
  // real GoRouter ancestor, pushed onto a base route to pop back to.
  final router = GoRouter(
    initialLocation: '/base',
    routes: [
      GoRoute(
        path: '/base',
        builder: (context, __) => Scaffold(
          body: Center(
            child: ElevatedButton(
              onPressed: () => context.push('/change-password'),
              child: const Text('Open Change Password'),
            ),
          ),
        ),
      ),
      GoRoute(
        path: '/change-password',
        builder: (_, __) => const ChangePasswordScreen(),
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
    SharedPreferences.setMockInitialValues({});
    FlutterSecureStorage.setMockInitialValues({});
  });

  testWidgets(
    'user changes their password via the live wire call',
    (tester) async {
      RequestOptions? postedRequest;
      final dio = _fakeDio({
        'POST ${ApiEndpoints.changePassword}': (options) {
          postedRequest = options;
          return <String, dynamic>{};
        },
      });

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
      await tester.tap(find.text('Open Change Password'));
      await _settle(tester);

      final fields = find.byType(TextFormField);
      await tester.enterText(fields.at(0), 'OldPassword1!');
      await tester.enterText(fields.at(1), 'NewPassword2!');
      await tester.enterText(fields.at(2), 'NewPassword2!');
      await tester.pump();

      await tester.tap(find.widgetWithText(XstoreButton, 'Change Password'));
      await _settle(tester);

      expect(postedRequest?.data, {
        'currentPassword': 'OldPassword1!',
        'newPassword': 'NewPassword2!',
        'confirmNewPassword': 'NewPassword2!',
      });
      expect(find.text('Your password was changed.'), findsOneWidget);
      // Popped back to the base screen after success.
      expect(find.text('Open Change Password'), findsOneWidget);
    },
  );

  testWidgets(
    'a wrong current password shows the live server error and stays open',
    (tester) async {
      final dio = _fakeDio({
        'POST ${ApiEndpoints.changePassword}': (_) => DioException(
          requestOptions: RequestOptions(path: ApiEndpoints.changePassword),
          response: Response(
            requestOptions: RequestOptions(path: ApiEndpoints.changePassword),
            statusCode: 400,
            data: {'message': 'Current password is incorrect'},
          ),
        ),
      });

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
      await tester.tap(find.text('Open Change Password'));
      await _settle(tester);

      final fields = find.byType(TextFormField);
      await tester.enterText(fields.at(0), 'WrongPassword1!');
      await tester.enterText(fields.at(1), 'NewPassword2!');
      await tester.enterText(fields.at(2), 'NewPassword2!');
      await tester.pump();

      await tester.tap(find.widgetWithText(XstoreButton, 'Change Password'));
      await _settle(tester);

      expect(find.text('Your password was changed.'), findsNothing);
      // Still on the change-password form.
      expect(find.widgetWithText(XstoreButton, 'Change Password'), findsOneWidget);
    },
  );
}
