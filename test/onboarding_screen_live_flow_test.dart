// Screen-level test of the real OnboardingScreen — real navigation and a
// real SharedPreferences write, not fixture data. Unlike every other
// screen this session, OnboardingScreen makes no network call at all (no
// MockConfig branch, no Dio, no AuthRepository) — its only side effect is
// persisting `PrefsKeys.onboardingComplete` via the real
// `sharedPreferencesProvider`, so there's nothing to script here. This
// still follows the session's "real screen, real behavior" standard: a
// real GoRouter, real button taps, and a real SharedPreferences instance
// (mocked at the platform-channel level only, per Flutter's own testing
// convention — see SharedPreferences.setMockInitialValues below).
//
// Run with: flutter test test/onboarding_screen_live_flow_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:xstore/core/constants/prefs_keys.dart';
import 'package:xstore/core/localization/app_localizations.dart';
import 'package:xstore/core/router/app_routes.dart';
import 'package:xstore/features/auth/presentation/screens/onboarding_screen.dart';
import 'package:xstore/shared/widgets/xstore_button.dart';

Widget _routedHarness() {
  final router = GoRouter(
    initialLocation: AppRoutes.onboarding,
    routes: [
      GoRoute(
        path: AppRoutes.onboarding,
        builder: (_, __) => const OnboardingScreen(),
      ),
      GoRoute(
        path: AppRoutes.login,
        builder: (_, __) => const Scaffold(body: Text('Login Screen')),
      ),
    ],
  );
  return ProviderScope(
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
/// established convention from splash_screen_live_flow_test.dart.
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
  });

  testWidgets(
    'tapping Skip persists onboarding-complete and goes to login',
    (tester) async {
      await tester.pumpWidget(_routedHarness());
      await _settle(tester);

      await tester.tap(find.text('Skip'));
      await _settle(tester);

      expect(find.text('Login Screen'), findsOneWidget);
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getBool(PrefsKeys.onboardingComplete), isTrue);
    },
  );

  testWidgets(
    'swiping through all slides to Get Started persists onboarding-complete and goes to login',
    (tester) async {
      await tester.pumpWidget(_routedHarness());
      await _settle(tester);

      // Slide 1 -> 2.
      await tester.tap(find.widgetWithText(XstoreButton, 'Next'));
      await _settle(tester);
      // Slide 2 -> 3.
      await tester.tap(find.widgetWithText(XstoreButton, 'Next'));
      await _settle(tester);

      await tester.tap(find.widgetWithText(XstoreButton, 'Get Started'));
      await _settle(tester);

      expect(find.text('Login Screen'), findsOneWidget);
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getBool(PrefsKeys.onboardingComplete), isTrue);
    },
  );
}
