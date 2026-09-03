// Screen-level, LIVE-mode (MOCK=false) test of the real EditProfileScreen —
// a real user editing their profile, not fixture data. Matches
// test/profile_screen_live_flow_test.dart's established pattern: real
// screen + real ProfileRepositoryImpl -> ProfileRemoteDataSourceImpl chain,
// only the Dio HTTP transport is scripted.
//
// EditProfileScreen deliberately does NOT fetch the profile itself on
// mount ("Profile data is prefetched on login/restore... no mount-time
// get-profile here (429 risk)") — it only reads whatever
// `profileNotifierProvider` already holds. So the harness must explicitly
// drive a `refreshProfileData()` call before/while the screen is mounted,
// same as seeding cart state in cart_screen_live_flow_test.dart, rather
// than relying on the screen's own initState.
//
// EditProfileScreen also calls `Navigator.of(context).pop()` on a
// successful save, so the harness pushes it onto a base screen (not
// `home:` directly) to give the Navigator a route underneath to pop back
// to.
//
// Run with: flutter test test/edit_profile_screen_live_flow_test.dart
import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:xstore/core/error/failures.dart';
import 'package:xstore/core/localization/app_localizations.dart';
import 'package:xstore/core/mock/mock_config.dart';
import 'package:xstore/core/network/api_endpoints.dart';
import 'package:xstore/core/network/dio_provider.dart';
import 'package:xstore/features/auth/domain/entities/user_entity.dart';
import 'package:xstore/features/auth/domain/repositories/auth_repository.dart';
import 'package:xstore/features/auth/presentation/providers/auth_provider.dart';
import 'package:xstore/features/profile/presentation/providers/profile_provider.dart';
import 'package:xstore/features/profile/presentation/screens/edit_profile_screen.dart';

/// Routes each request by (method, path) to a scripted response — same
/// technique as profile_screen_live_flow_test.dart's `_RoutedInterceptor`.
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

/// `ProfileNotifier.saveProfile()` reads `authRepositoryProvider` directly
/// to call `persistSessionUser` after a successful save. The real
/// `AuthRepositoryImpl` eagerly constructs `SocialAuthDatasourceImpl` in
/// its dependency chain, which calls `FirebaseAuth.instance` and throws
/// `[core/no-app]` outside a real app — overriding `authProvider` alone
/// (as every other screen test does) doesn't avoid this, since it's a
/// separate provider. A `Fake` standing in for just the one method this
/// path actually calls sidesteps the whole Firebase chain, same pattern
/// as test/features/profile/profile_prefetch_test.dart.
class _FakeAuthRepo extends Fake implements AuthRepository {
  @override
  Future<Either<Failure, Unit>> persistSessionUser(UserEntity user) async =>
      const Right(unit);
}

UserEntity _consumer() => const UserEntity(
  id: 'consumer_1',
  name: 'Test Buyer',
  email: 'buyer@test.com',
  phoneNumber: '01012345678',
);

/// Both GET get-profile and PUT update-profile return the same
/// `{"user": {...}}` wire shape (CONFIRMED via
/// profile_remote_datasource.dart's comment on both).
Map<String, dynamic> _profileJson({String name = 'Test Buyer'}) => {
  'user': {
    'id': 'consumer_1',
    'fullName': name,
    'email': 'buyer@test.com',
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
    // EditProfileScreen calls Navigator.of(context).pop() on a successful
    // save — it needs a route underneath it to pop back to, so it's
    // pushed rather than set as `home:` directly.
    home: Builder(
      builder: (context) => Scaffold(
        body: Center(
          child: ElevatedButton(
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => const EditProfileScreen(),
              ),
            ),
            child: const Text('Open Edit Profile'),
          ),
        ),
      ),
    ),
  ),
);

/// Bounded frame pump instead of `pumpAndSettle()` — matches the
/// established convention from profile_screen_live_flow_test.dart.
Future<void> _settle(
  WidgetTester tester, {
  int times = 15,
  Duration step = const Duration(milliseconds: 100),
}) async {
  for (var i = 0; i < times; i++) {
    await tester.pump(step);
  }
}

/// Pushes EditProfileScreen, then explicitly drives a profile fetch —
/// EditProfileScreen has no mount-time get-profile of its own (see the
/// file-level comment), so the harness must seed
/// `profileNotifierProvider` itself, the same way
/// cart_screen_live_flow_test.dart seeds cart state via a direct notifier
/// call before assertions.
Future<ProviderContainer> _pumpReady(
  WidgetTester tester,
  List<Override> overrides,
) async {
  await tester.pumpWidget(_harness(overrides));
  await tester.tap(find.text('Open Edit Profile'));
  await _settle(tester);
  final container = ProviderScope.containerOf(
    tester.element(find.byType(EditProfileScreen)),
    listen: false,
  );
  await container.read(authProvider.future);
  // Deliberately not awaited — see the FakeAsync-zone note in
  // orders_screen_live_flow_test.dart's `_pumpReady`.
  unawaited(
    container.read(profileNotifierProvider.notifier).refreshProfileData(),
  );
  return container;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    FlutterSecureStorage.setMockInitialValues({});
  });

  testWidgets(
    'consumer opens Edit Profile and sees their live prefilled name',
    // Exercises ProfileRemoteDataSourceImpl's LIVE (non-mock) branch.
    skip: MockConfig.useMock,
    (tester) async {
      final dio = _fakeDio({
        'GET ${ApiEndpoints.getProfile}': (_) => _profileJson(),
      });

      await _pumpReady(tester, [
        authProvider.overrideWith(() => _FakeAuth(_consumer())),
        dioProvider.overrideWithValue(dio),
      ]);
      await _settle(tester);

      expect(find.text('Test Buyer'), findsWidgets);
    },
  );

  testWidgets(
    'consumer edits their name and the live save wire call persists it',
    skip: MockConfig.useMock,
    (tester) async {
      var name = 'Test Buyer';
      final dio = _fakeDio({
        'GET ${ApiEndpoints.getProfile}': (_) => _profileJson(name: name),
        'PUT ${ApiEndpoints.updateProfile}': (_) {
          name = 'Updated Buyer';
          return _profileJson(name: name);
        },
      });

      await _pumpReady(tester, [
        authProvider.overrideWith(() => _FakeAuth(_consumer())),
        authRepositoryProvider.overrideWith((ref) => _FakeAuthRepo()),
        dioProvider.overrideWithValue(dio),
      ]);
      await _settle(tester);

      await tester.enterText(find.byType(TextField).first, 'Updated Buyer');
      await tester.pump();

      await tester.tap(find.text('Save'));
      await _settle(tester);

      expect(find.text('Profile updated'), findsOneWidget);
    },
  );
}
