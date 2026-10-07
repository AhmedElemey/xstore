import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:xstore/core/localization/app_localizations.dart';
import 'package:xstore/features/auth/domain/entities/user_entity.dart';
import 'package:xstore/features/auth/presentation/widgets/auth_text_field.dart';
import 'package:xstore/features/cities/presentation/providers/city_dependencies.dart';
import 'package:xstore/features/governments/presentation/providers/government_dependencies.dart';
import 'package:xstore/features/store_categories/presentation/providers/store_category_dependencies.dart';
import 'package:xstore/features/profile/domain/entities/profile_entity.dart';
import 'package:xstore/features/profile/presentation/providers/profile_provider.dart';
import 'package:xstore/features/profile/presentation/providers/profile_state.dart';
import 'package:xstore/features/profile/presentation/screens/edit_profile_screen.dart';
import 'package:xstore/shared/widgets/error_state_widget.dart';

class _FailedProfile extends ProfileNotifier {
  static var refreshCalls = 0;
  static var forced = false;

  @override
  ProfileState build() => const ProfileState(
    error: 'Something went wrong. Please try again later.',
  );

  @override
  Future<void> refreshProfileData({
    UserEntity? user,
    bool force = false,
    bool preserveEdits = false,
    bool alreadyFresh = false,
  }) async {
    refreshCalls++;
    forced = force;
  }
}

class _BlankNameProfile extends ProfileNotifier {
  @override
  ProfileState build() => ProfileState(
    profile: const ProfileEntity(
      user: UserEntity(
        id: '9',
        name: 'Test User',
        email: 'user@test.com',
        phoneNumber: '01084108663',
      ),
    ),
  );
}

Widget _host(ProfileNotifier Function() notifier) => ProviderScope(
  overrides: [
    profileNotifierProvider.overrideWith(notifier),
    // Keep reference-list fetches off the real network.
    allCitiesProvider.overrideWith((ref) async => []),
    allGovernmentsProvider.overrideWith((ref) async => []),
    allStoreCategoriesProvider.overrideWith((ref) async => []),
  ],
  child: const MaterialApp(
    localizationsDelegates: [
      AppLocalizations.delegate,
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
    ],
    supportedLocales: AppLocalizations.supportedLocales,
    home: EditProfileScreen(),
  ),
);

void main() {
  setUp(() {
    _FailedProfile.refreshCalls = 0;
    _FailedProfile.forced = false;
  });

  testWidgets('failed get-profile shows error + retry, not an empty form', (
    tester,
  ) async {
    await tester.pumpWidget(_host(_FailedProfile.new));
    await tester.pumpAndSettle();

    expect(find.byType(ErrorStateWidget), findsOneWidget);
    expect(find.byType(AuthTextField), findsNothing);

    await tester.tap(find.text('Retry'));
    await tester.pump();
    expect(_FailedProfile.refreshCalls, 1);
    expect(_FailedProfile.forced, isTrue);
  });

  testWidgets('a name that fails the register rule blocks save inline', (
    tester,
  ) async {
    await tester.pumpWidget(_host(_BlankNameProfile.new));
    await tester.pumpAndSettle();

    final nameField = find.descendant(
      of: find.widgetWithText(AuthTextField, 'FULL NAME'),
      matching: find.byType(TextField),
    );
    await tester.enterText(nameField, 'a1');
    await tester.pump();
    await tester.tap(find.text('Save'));
    await tester.pump();

    expect(
      find.text('Enter your full name (letters only, min 3 chars)'),
      findsOneWidget,
    );
  });
}
