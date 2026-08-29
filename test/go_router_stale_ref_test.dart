import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:xstore/core/analytics/analytics_service.dart';
import 'package:xstore/core/router/app_router.dart';
import 'package:xstore/core/router/app_routes.dart';
import 'package:xstore/features/auth/domain/entities/user_entity.dart';
import 'package:xstore/features/auth/presentation/providers/auth_provider.dart';
import 'package:xstore/features/notifications/presentation/providers/fcm_device_token_sync_provider.dart';
import 'package:xstore/features/notifications/presentation/providers/fcm_push_handling_provider.dart';

import 'helpers/fake_async_auth_notifier.dart';

const _vendor = UserEntity(
  id: 'v1',
  name: 'Ven',
  email: 'v@test.com',
  phoneNumber: '01099999999',
  role: UserRole.vendor,
);

/// Lets the test adopt a session without Auth's FCM/profile side effects.
class _AuthThatCanAdopt extends FakeAuth {
  _AuthThatCanAdopt() : super(null);

  @override
  void adoptSession(UserEntity user) {
    state = AsyncData(user);
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    FlutterSecureStorage.setMockInitialValues({});
  });

  testWidgets(
    'role-changing login then go() does not assert on an outdated goRouter ref',
    (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            authProvider.overrideWith(_AuthThatCanAdopt.new),
            fcmDeviceTokenSyncProvider.overrideWith((ref) {}),
            fcmPushHandlingProvider.overrideWith((ref) {}),
          ],
          child: Consumer(
            builder: (context, ref, _) {
              final router = ref.watch(goRouterProvider);
              return MaterialApp.router(
                key: ObjectKey(router),
                routerConfig: router,
              );
            },
          ),
        ),
      );
      await tester.pump();

      final container = ProviderScope.containerOf(
        tester.element(find.byType(MaterialApp)),
      );
      await container.read(authProvider.future);
      await container.read(analyticsServiceProvider).ready;

      // Capture the live GoRouter *before* the role change. Login's
      // context.go uses this same instance in the same frame, not a
      // freshly-read provider (which would flush/rebuild first).
      final router = container.read(goRouterProvider);

      container.read(authProvider.notifier).adoptSession(_vendor);

      expect(() => router.go(AppRoutes.home), returnsNormally);

      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pump(const Duration(milliseconds: 2600));
    },
  );

  test('vendor logout does not recreate GoRouter', () async {
    final container = ProviderContainer(
      overrides: [
        authProvider.overrideWith(
          () => _AuthThatCanLogout(_vendor),
        ),
        fcmDeviceTokenSyncProvider.overrideWith((ref) {}),
        fcmPushHandlingProvider.overrideWith((ref) {}),
      ],
    );
    addTearDown(container.dispose);
    await container.read(analyticsServiceProvider).ready;
    await container.read(authProvider.future);

    final router = container.read(goRouterProvider);
    await container.read(authProvider.notifier).logout();

    expect(
      identical(router, container.read(goRouterProvider)),
      isTrue,
      reason: 'logout must not recreate GoRouter (that remounts splash)',
    );
  });
}

/// Clears the session without Auth's FCM/profile/storage side effects.
class _AuthThatCanLogout extends FakeAuth {
  _AuthThatCanLogout(super.user);

  @override
  Future<void> logout() async {
    state = const AsyncData(null);
  }
}
