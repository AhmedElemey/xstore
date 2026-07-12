import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:xstore/core/error/failures.dart';
import 'package:xstore/core/mock/mock_config.dart';
import 'package:xstore/features/auth/domain/entities/user_entity.dart';
import 'package:xstore/features/auth/domain/repositories/auth_repository.dart';
import 'package:xstore/features/auth/presentation/providers/auth_provider.dart';
import 'package:xstore/features/profile/domain/usecases/update_profile_usecase.dart';
import 'package:xstore/features/profile/presentation/providers/profile_dependencies.dart';
import 'package:xstore/features/profile/presentation/providers/profile_provider.dart';

const _user = UserEntity(
  id: 'vendor_1',
  name: 'Test Vendor',
  email: 'vendor@test.com',
  phoneNumber: '01012345678',
  role: UserRole.vendor,
);

/// Cold-start stand-in: a persisted session exists, so restoreSession
/// returns a user. Everything else is unused by Auth.build().
class _RestoredSessionAuthRepo extends Fake implements AuthRepository {
  @override
  Future<Either<Failure, UserEntity?>> restoreSession() async =>
      const Right(_user);
}

/// Delays update-profile so tests can invalidate mid-save (logout reset).
class _DelayedUpdateProfileUseCase extends UpdateProfileUseCase {
  _DelayedUpdateProfileUseCase(super.repository);

  @override
  Future<Either<Failure, UserEntity>> call(UserEntity updated) async {
    await Future<void>.delayed(const Duration(milliseconds: 500));
    return super.call(updated);
  }
}

/// Run with `--dart-define=MOCK=true` so get-profile uses mock data.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const skipReason = 'Requires --dart-define=MOCK=true for mock get-profile';

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test(
    'prefetch after adoptSession populates profileNotifierProvider before any screen mounts',
    () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      container.read(authProvider.notifier).adoptSession(_user);

      // Allow mock get-profile delay (MockConfig.mockDelay) to complete.
      await Future<void>.delayed(const Duration(milliseconds: 900));

      final profileState = container.read(profileNotifierProvider);
      expect(profileState.profile, isNotNull);
      expect(profileState.profile!.user.id, _user.id);
      expect(profileState.error, isNull);
    },
    skip: MockConfig.useMock ? false : skipReason,
  );

  test(
    'prefetch sets isLoading before profile arrives (ProfileScreen skeleton gate)',
    () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      container.read(authProvider.notifier).adoptSession(_user);
      await Future<void>.delayed(Duration.zero);

      final profileState = container.read(profileNotifierProvider);
      expect(profileState.isLoading, isTrue);
      expect(profileState.profile, isNull);
    },
    skip: MockConfig.useMock ? false : skipReason,
  );

  test(
    'cold start with persisted session prefetches the profile (restore path, not adoptSession)',
    () async {
      final container = ProviderContainer(
        overrides: [
          authRepositoryProvider.overrideWith(
            (ref) => _RestoredSessionAuthRepo(),
          ),
        ],
      );
      addTearDown(container.dispose);

      // First-ever read of authProvider = app cold start restoring a session.
      final restored = await container.read(authProvider.future);
      expect(restored?.id, _user.id);

      await Future<void>.delayed(const Duration(milliseconds: 900));

      final profileState = container.read(profileNotifierProvider);
      expect(
        profileState.profile,
        isNotNull,
        reason: 'restore-path prefetch must populate the profile — '
            'authProvider reads as Loading inside its own build(), so the '
            'user has to be passed into the refresh explicitly',
      );
      expect(profileState.profile!.user.id, _user.id);
      expect(profileState.error, isNull);
    },
    skip: MockConfig.useMock ? false : skipReason,
  );

  test(
    'invalidating profileNotifierProvider mid-refresh drops the in-flight result',
    () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      container.read(authProvider.notifier).adoptSession(_user);
      // Let the prefetch start its mock get-profile, then log-out style reset
      // while it is still in flight.
      await Future<void>.delayed(const Duration(milliseconds: 50));
      container.invalidate(profileNotifierProvider);
      expect(container.read(profileNotifierProvider).profile, isNull);

      // Wait past the mock delay: the stale fetch must not write into the
      // fresh session state (epoch guard) nor throw.
      await Future<void>.delayed(const Duration(milliseconds: 900));

      final profileState = container.read(profileNotifierProvider);
      expect(profileState.profile, isNull);
      expect(profileState.isLoading, isFalse);
      expect(profileState.error, isNull);
    },
    skip: MockConfig.useMock ? false : skipReason,
  );

  test(
    'invalidating profileNotifierProvider mid-save drops stale post-await writes',
    () async {
      final container = ProviderContainer(
        overrides: [
          updateProfileUseCaseProvider.overrideWith(
            (ref) => _DelayedUpdateProfileUseCase(
              ref.watch(profileRepositoryProvider),
            ),
          ),
        ],
      );
      addTearDown(container.dispose);

      container.read(authProvider.notifier).adoptSession(_user);
      await Future<void>.delayed(const Duration(milliseconds: 900));
      expect(container.read(profileNotifierProvider).profile, isNotNull);

      unawaited(
        container.read(profileNotifierProvider.notifier).saveProfile(),
      );
      await Future<void>.delayed(const Duration(milliseconds: 50));
      container.invalidate(profileNotifierProvider);
      expect(container.read(profileNotifierProvider).profile, isNull);

      await Future<void>.delayed(const Duration(milliseconds: 900));

      final profileState = container.read(profileNotifierProvider);
      expect(profileState.profile, isNull);
      expect(profileState.isUpdating, isFalse);
      expect(profileState.error, isNull);
    },
    skip: MockConfig.useMock ? false : skipReason,
  );
}
