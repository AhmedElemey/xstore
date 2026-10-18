import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:xstore/core/localization/app_localizations.dart';
import 'package:xstore/core/localization/localization_provider.dart';
import 'package:xstore/features/profile/presentation/widgets/language_toggle_tile.dart';
import 'package:xstore/features/profile/presentation/widgets/theme_toggle_tile.dart';
import 'package:xstore/shared/providers/shared_providers.dart';

Future<ProviderContainer> _pump(WidgetTester tester, Locale locale) async {
  SharedPreferences.setMockInitialValues({});
  final container = ProviderContainer();
  addTearDown(container.dispose);
  await tester.pumpWidget(
    UncontrolledProviderScope(
      container: container,
      child: MaterialApp(
        locale: locale,
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: AppLocalizations.supportedLocales,
        home: const Scaffold(
          body: Column(children: [ThemeToggleTile(), LanguageToggleTile()]),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
  return container;
}

void main() {
  for (final locale in const [Locale('en'), Locale('ar')]) {
    group('profile toggle tiles (${locale.languageCode})', () {
      testWidgets('tapping the row text toggles the language', (tester) async {
        final c = await _pump(tester, locale);
        final title = lookupAppLocalizations(locale).languageToggleTitle;
        expect(c.read(appLocaleProvider), AppLanguage.english);

        await tester.tap(find.textContaining(title));
        await tester.pumpAndSettle();

        expect(c.read(appLocaleProvider), AppLanguage.arabic);
      });

      testWidgets('tapping the row text toggles the theme', (tester) async {
        final c = await _pump(tester, locale);
        final l10n = lookupAppLocalizations(locale);
        expect(c.read(appThemeModeProvider), ThemeMode.light);

        await tester.tap(find.text(l10n.lightMode));
        await tester.pumpAndSettle();

        expect(c.read(appThemeModeProvider), ThemeMode.dark);
      });

      testWidgets('the switch is announced with the visible label', (
        tester,
      ) async {
        final handle = tester.ensureSemantics();
        await _pump(tester, locale);
        final l10n = lookupAppLocalizations(locale);

        final theme = tester.getSemantics(find.byType(ThemeToggleTile));
        expect(theme.label, l10n.lightMode);
        expect(theme.flagsCollection.hasToggledState, isTrue);

        final lang = tester.getSemantics(find.byType(LanguageToggleTile));
        expect(lang.label, contains(l10n.languageToggleTitle));
        expect(lang.flagsCollection.hasToggledState, isTrue);
        handle.dispose();
      });
    });
  }
}
