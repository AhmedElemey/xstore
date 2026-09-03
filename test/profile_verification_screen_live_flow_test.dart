// Screen-level, LIVE-mode test of the real ProfileVerificationScreen — a
// real user completing an email OTP challenge, not fixture data. Matches
// test/edit_profile_screen_live_flow_test.dart's established pattern:
// real screen + real AuthRepositoryImpl -> AuthRemoteDataSourceImpl chain,
// only the Dio HTTP transport is scripted.
//
// AuthRepositoryImpl itself (not just the SocialAuthDatasource it takes as
// a constructor arg) defaults its OWN `firebaseAuth` param to
// `FirebaseAuth.instance` when not supplied — and the `authRepository`
// riverpod provider never supplies one — so overriding only
// `socialAuthDatasourceProvider` still throws `[core/no-app]` the instant
// anything reads `authRepositoryProvider` (see the flutter-review
// SKILL.md lesson from this file). Since this screen's ENTIRE flow
// (sendEmailOtp/verifyEmailOtp) lives on that provider, faking the whole
// repository would gut the "live" test's purpose — so instead this
// overrides `authRepositoryProvider` with a REAL `AuthRepositoryImpl`,
// built by hand with the real `AuthRemoteDataSourceImpl` (wired to the
// scripted Dio) but a fake `FirebaseAuth`/`SocialAuthDatasource` standing
// in for the two params only social sign-in ever touches — same
// diagnostic technique as test/auth_repository_impl_test.dart's
// `_FakeFirebaseAuth`.
//
// sendEmailOtp/verifyEmailOtp have no MockConfig branch at all (confirmed
// via grep) — this screen's flow is always-live, so no `skip:` flag is
// needed on either test.
//
// Run with: flutter test test/profile_verification_screen_live_flow_test.dart
import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:xstore/core/localization/app_localizations.dart';
import 'package:xstore/core/network/api_endpoints.dart';
import 'package:xstore/core/network/dio_provider.dart';
import 'package:xstore/features/auth/data/datasources/social_auth_datasource.dart';
import 'package:xstore/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:xstore/features/auth/domain/entities/social_auth_result.dart';
import 'package:xstore/features/auth/domain/entities/user_entity.dart';
import 'package:xstore/features/auth/presentation/providers/auth_provider.dart';
import 'package:xstore/features/profile/presentation/providers/profile_verification_provider.dart';
import 'package:xstore/features/profile/presentation/screens/profile_verification_screen.dart';

/// Routes each request by (method, path) to a scripted response — same
/// technique as edit_profile_screen_live_flow_test.dart's
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

class _FakeAuth extends Auth {
  _FakeAuth(this._user);
  final UserEntity? _user;
  @override
  Future<UserEntity?> build() async => _user;
}

/// Stands in only for the Firebase-touching half of auth — nothing in
/// this screen's flow calls social sign-in, so every method here is
/// unreachable and can safely throw if it ever were.
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

/// Stands in for `AuthRepositoryImpl`'s own `firebaseAuth` param (separate
/// from the `SocialAuthDatasource` it's also given) — never called by
/// this screen's flow, so `noSuchMethod` throwing is enough.
class _FakeFirebaseAuth implements FirebaseAuth {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

UserEntity _consumer() => const UserEntity(
  id: 'consumer_1',
  name: 'Test Buyer',
  email: 'buyer@test.com',
  phoneNumber: '01012345678',
);

Map<String, dynamic> _profileJson({String email = 'new@test.com'}) => {
  'user': {
    'id': 'consumer_1',
    'fullName': 'Test Buyer',
    'email': email,
    'phoneNumber': '01012345678',
  },
  'isEmailVerificationRequired': false,
  'isPhoneVerificationRequired': false,
  'isEmailVerified': true,
  'isPhoneVerified': true,
};

Widget _harness(List<Override> overrides) => ProviderScope(
  overrides: overrides,
  child: MaterialApp(
    localizationsDelegates: const [
      AppLocalizations.delegate,
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
    ],
    supportedLocales: AppLocalizations.supportedLocales,
    // ProfileVerificationScreen pops(true) on success — it needs a route
    // underneath it to pop back to, same as
    // edit_profile_screen_live_flow_test.dart's harness.
    home: Builder(
      builder: (context) => Scaffold(
        body: Center(
          child: ElevatedButton(
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => const ProfileVerificationScreen(
                  args: ProfileVerificationArgs(
                    target: ProfileVerificationTarget.email,
                    contactValue: 'new@test.com',
                  ),
                ),
              ),
            ),
            child: const Text('Open Verification'),
          ),
        ),
      ),
    ),
  ),
);

/// Bounded frame pump instead of `pumpAndSettle()` — matches the
/// established convention from edit_profile_screen_live_flow_test.dart.
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
    'consumer completes a live email OTP and sees the verified success state',
    (tester) async {
      final dio = _fakeDio({
        'POST ${ApiEndpoints.sendEmailOtp}': (_) => {'otp': '123456'},
        'POST ${ApiEndpoints.verifyEmail}': (_) => <String, dynamic>{},
        'GET ${ApiEndpoints.getProfile}': (_) => _profileJson(),
      });

      await tester.pumpWidget(
        _harness([
          authProvider.overrideWith(() => _FakeAuth(_consumer())),
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
      await tester.tap(find.text('Open Verification'));
      await _settle(tester);

      expect(find.textContaining('new@test.com'), findsOneWidget);

      await tester.enterText(find.byType(EditableText), '123456');
      // The kDebugMode "Debug OTP: 123456" snackbar (shown right after
      // sendCode() succeeds, during the first _settle above) queues ahead
      // of the "Email verified" success snackbar on the same
      // ScaffoldMessenger — SnackBars display one at a time, so the
      // second doesn't render until the first's full 3-second default
      // duration elapses. A longer settle than everywhere else in this
      // session is needed here specifically to clear that queue.
      await _settle(tester, times: 40);

      expect(find.text('Email verified'), findsOneWidget);
      // Popped back to the base screen after success.
      expect(find.text('Open Verification'), findsOneWidget);
    },
  );

  testWidgets(
    'an invalid OTP shows an error and does not verify',
    (tester) async {
      final dio = _fakeDio({
        'POST ${ApiEndpoints.sendEmailOtp}': (_) => {'otp': '123456'},
        'POST ${ApiEndpoints.verifyEmail}': (_) => DioException(
          requestOptions: RequestOptions(path: ApiEndpoints.verifyEmail),
          response: Response(
            requestOptions: RequestOptions(path: ApiEndpoints.verifyEmail),
            statusCode: 400,
            data: {'message': 'Invalid code'},
          ),
        ),
      });

      await tester.pumpWidget(
        _harness([
          authProvider.overrideWith(() => _FakeAuth(_consumer())),
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
      await tester.tap(find.text('Open Verification'));
      await _settle(tester);

      await tester.enterText(find.byType(EditableText), '000000');
      await _settle(tester);

      expect(find.text('Incorrect code. Please try again.'), findsOneWidget);
      // Still on the verification screen — not popped.
      expect(find.text('Open Verification'), findsNothing);
    },
  );
}
