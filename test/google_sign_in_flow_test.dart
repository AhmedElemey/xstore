// Provider-level tests of the Google sign-in flow (socialAuthProvider ->
// the real AuthRepositoryImpl -> AuthRemoteDataSourceImpl chain, with only
// the Dio transport and the two Firebase-touching constructor params
// stubbed).
//
// Google is a login-only shortcut: `checkGoogleUser` alone decides whether
// to log in (one `/api/auth/google/login` call, role taken from the
// profile) or to send the user to Register via
// `SocialAuthState.needsRegistration` (Firebase `isNewUser` is ignored).
// The login/register screens react to `needsRegistration`; see
// login_screen_live_flow_test.dart for that half.

import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:xstore/core/analytics/analytics_service.dart';
import 'package:xstore/core/firebase/firebase_options.dart';
import 'package:xstore/core/mock/mock_config.dart';
import 'package:xstore/core/network/api_endpoints.dart';
import 'package:xstore/core/network/dio_provider.dart';
import 'package:xstore/features/auth/data/datasources/social_auth_datasource.dart';
import 'package:xstore/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:xstore/features/auth/domain/entities/social_auth_result.dart';
import 'package:xstore/features/auth/domain/entities/user_entity.dart';
import 'package:xstore/features/auth/presentation/providers/auth_provider.dart';
import 'package:xstore/features/auth/presentation/providers/social_auth_provider.dart';

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

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    FlutterSecureStorage.setMockInitialValues({});
  });

  test(
    'a Google identity with no matching account sets needsRegistration and '
    'never calls the auto-create login endpoint',
    () async {
      // Deliberately no googleLogin route scripted
      // — if the app still tried to auto-create an account here, the
      // interceptor would reject the unscripted request and this test would
      // fail with a clear signal rather than silently passing.
      final dio = _fakeDio({
        'POST ${ApiEndpoints.googleCheckUser}': (_) => {
          'exists': false,
          'role': null,
        },
      });

      final container = ProviderContainer(
        overrides: [
          authRepositoryProvider.overrideWith(
            (ref) => AuthRepositoryImpl(
              remote: ref.watch(authRemoteDataSourceProvider),
              social: _FakeSocialAuth(
                const SocialAuthResult(
                  provider: SocialProvider.google,
                  uid: 'google-uid-no-account',
                  email: 'noaccount@gmail.com',
                  displayName: 'No Account Googler',
                  idToken: 'google-id-token-no-account',
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
      addTearDown(container.dispose);

      // A plain test() (unlike testWidgets) doesn't run inside
      // AutomatedTestWidgetsFlutterBinding's FakeAsync zone, so a direct
      // await here is safe — no unawaited/pump dance needed.
      await container.read(socialAuthProvider.notifier).signInWithGoogle();

      final social = container.read(socialAuthProvider);
      expect(social.needsRegistration, isTrue);
      expect(social.googleRegistration?.email, 'noaccount@gmail.com');
      expect(social.googleRegistration?.displayName, 'No Account Googler');
      // Carried to the register request as `idToken`.
      expect(social.googleRegistration?.idToken, 'google-id-token-no-account');
    },
  );

  test(
    'a returning Firebase Google identity with no backend account goes to '
    'register instead of being logged in',
    skip: MockConfig.useMock,
    () async {
      // No Google login route scripted: an auto-creating login call would
      // be rejected as unscripted and surface as an error.
      final dio = _fakeDio({
        'POST ${ApiEndpoints.googleCheckUser}': (_) => {
          'exists': false,
          'role': null,
        },
      });

      final container = ProviderContainer(
        overrides: [
          authRepositoryProvider.overrideWith(
            (ref) => AuthRepositoryImpl(
              remote: ref.watch(authRemoteDataSourceProvider),
              social: _FakeSocialAuth(
                const SocialAuthResult(
                  provider: SocialProvider.google,
                  uid: 'google-uid-email-account',
                  email: 'rehab.mhmd2@gmail.com',
                  displayName: 'Existing Email User',
                  idToken: 'google-id-token-email-account',
                  isNewUser: false,
                ),
              ),
              secureStorage: ref.watch(secureStorageProvider),
              firebaseAuth: _FakeFirebaseAuth(),
            ),
          ),
          dioProvider.overrideWithValue(dio),
        ],
      );
      addTearDown(container.dispose);

      await container.read(socialAuthProvider.notifier).signInWithGoogle();

      final social = container.read(socialAuthProvider);
      expect(social.needsRegistration, isTrue);
      expect(social.googleRegistration?.email, 'rehab.mhmd2@gmail.com');
      expect(social.error, isNull);
    },
  );

  test(
    'a registered Google identity with an unreadable role logs in once via '
    'the single google/login endpoint and takes its role from the profile',
    skip: MockConfig.useMock,
    () async {
      var googleLoginCalls = 0;
      Object? googleLoginBody;
      final dio = _fakeDio({
        'POST ${ApiEndpoints.googleCheckUser}': (_) => {
          'exists': true,
          'role': null,
        },
        'POST ${ApiEndpoints.googleLogin}': (options) {
          googleLoginCalls++;
          googleLoginBody = options.data;
          return {
            'isSuccess': true,
            'data': {
              'token': 'access-token-vendor',
              'refreshToken': 'refresh-token-vendor',
            },
          };
        },
        'GET ${ApiEndpoints.getProfile}': (_) => {
          'user': {
            'id': 'vendor_1',
            'fullName': 'Test Seller',
            'email': 'seller@test.com',
            'phoneNumber': '01012345678',
            'roleName': 'Vendor',
          },
          'isEmailVerificationRequired': false,
          'isPhoneVerificationRequired': false,
          'isEmailVerified': false,
          'isPhoneVerified': false,
        },
      });

      final container = ProviderContainer(
        overrides: [
          authRepositoryProvider.overrideWith(
            (ref) => AuthRepositoryImpl(
              remote: ref.watch(authRemoteDataSourceProvider),
              social: _FakeSocialAuth(
                const SocialAuthResult(
                  provider: SocialProvider.google,
                  uid: 'google-uid-vendor-email',
                  email: 'seller@gmail.com',
                  displayName: 'Existing Vendor',
                  idToken: 'google-id-token-vendor-email',
                  isNewUser: false,
                ),
              ),
              secureStorage: ref.watch(secureStorageProvider),
              firebaseAuth: _FakeFirebaseAuth(),
            ),
          ),
          dioProvider.overrideWithValue(dio),
        ],
      );
      addTearDown(container.dispose);

      await container.read(socialAuthProvider.notifier).signInWithGoogle();

      final social = container.read(socialAuthProvider);
      expect(social.needsRegistration, isFalse);
      expect(social.error, isNull);
      expect(googleLoginCalls, 1);
      expect(googleLoginBody, {
        'idToken': 'google-id-token-vendor-email',
        'clientId': DefaultFirebaseOptions.googleWebClientId,
      });
      expect(container.read(authProvider).valueOrNull?.role, UserRole.vendor);

      await container.read(analyticsServiceProvider).ready;
    },
  );
}
