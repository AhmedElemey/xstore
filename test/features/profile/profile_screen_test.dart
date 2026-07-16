import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:xstore/core/localization/app_localizations.dart';
import 'package:xstore/features/auth/domain/entities/user_entity.dart';
import 'package:xstore/features/auth/presentation/providers/auth_provider.dart';
import 'package:xstore/features/profile/presentation/providers/profile_provider.dart';
import 'package:xstore/features/profile/presentation/providers/profile_state.dart';
import 'package:xstore/features/profile/presentation/screens/profile_screen.dart';
import 'package:xstore/features/store/presentation/providers/store_hours_provider.dart';
import 'package:xstore/shared/widgets/error_state_widget.dart';

import '../../helpers/fake_async_auth_notifier.dart';

const _sessionUser = UserEntity(
  id: '9',
  name: 'Test User',
  email: 'user@test.com',
  phoneNumber: '01084108663',
);

class _ErrorProfileNotifier extends ProfileNotifier {
  @override
  ProfileState build() =>
      const ProfileState(error: 'Network unavailable. Please check your connection and try again.');
}

class _EmptyIdentityAuth extends Auth {
  @override
  Future<UserEntity?> build() async => const UserEntity(
        id: '',
        name: '',
        email: 'stub@test.com',
        phoneNumber: '',
      );
}

class _NoOpStoreHours extends StoreHoursNotifier {
  @override
  StoreHoursState build() => const StoreHoursState(original: null, current: null);

  @override
  Future<void> fetchStoreHours() async {}
}

Widget _harness({
  required Auth authOverride,
  ProfileNotifier Function()? profileOverride,
}) {
  return ProviderScope(
    overrides: [
      authProvider.overrideWith(() => authOverride),
      if (profileOverride != null)
        profileNotifierProvider.overrideWith(profileOverride),
      storeHoursNotifierProvider.overrideWith(_NoOpStoreHours.new),
    ],
    child: MaterialApp(
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      home: const ProfileScreen(),
    ),
  );
}

void main() {
  testWidgets(
    'shows inline retry when enriched profile fails but auth session has identity',
    (tester) async {
      await tester.pumpWidget(
        _harness(
          authOverride: FakeAuth(_sessionUser),
          profileOverride: _ErrorProfileNotifier.new,
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(ErrorStateWidget), findsNothing);
      expect(find.text(_sessionUser.name), findsOneWidget);
      expect(find.text('Retry'), findsOneWidget);
    },
  );

  testWidgets(
    'shows full-page error when enriched profile fails and auth user is a stub',
    (tester) async {
      await tester.pumpWidget(
        _harness(
          authOverride: _EmptyIdentityAuth(),
          profileOverride: _ErrorProfileNotifier.new,
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(ErrorStateWidget), findsOneWidget);
    },
  );
}
