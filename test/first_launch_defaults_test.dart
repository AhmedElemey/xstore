// First launch (nothing saved) opens the app in light mode and Arabic;
// a choice the user saved earlier always wins.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:xstore/core/localization/localization_provider.dart';
import 'package:xstore/shared/providers/shared_providers.dart';

Future<ProviderContainer> _container(Map<String, Object> saved) async {
  SharedPreferences.setMockInitialValues(saved);
  final container = ProviderContainer();
  addTearDown(container.dispose);
  container.read(appThemeModeProvider);
  container.read(appLocaleProvider);
  // Let the saved-value loads finish.
  await container.read(sharedPreferencesProvider.future);
  await Future<void>.delayed(Duration.zero);
  return container;
}

void main() {
  test('first launch defaults to light mode and Arabic', () async {
    final c = await _container({});
    expect(c.read(appThemeModeProvider), ThemeMode.light);
    expect(c.read(appLocaleProvider), AppLanguage.arabic);
    expect(c.read(appIsArabicProvider), isTrue);
  });

  test('a saved dark theme and English language win over the defaults',
      () async {
    final c = await _container({
      'theme_mode': ThemeMode.dark.name,
      'app_language': AppLanguage.english.name,
    });
    expect(c.read(appThemeModeProvider), ThemeMode.dark);
    expect(c.read(appLocaleProvider), AppLanguage.english);
  });
}
