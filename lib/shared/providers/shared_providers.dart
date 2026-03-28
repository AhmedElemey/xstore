import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'shared_providers.g.dart';

@Riverpod(keepAlive: true)
Future<SharedPreferences> sharedPreferences(SharedPreferencesRef ref) {
  return SharedPreferences.getInstance();
}

@Riverpod(keepAlive: true)
class AppThemeMode extends _$AppThemeMode {
  @override
  ThemeMode build() {
    final prefsAsync = ref.watch(sharedPreferencesProvider);
    return prefsAsync.when(
      data: (prefs) {
        final name = prefs.getString(_themeModeKey);
        return ThemeMode.values.firstWhere(
          (m) => m.name == name,
          orElse: () => ThemeMode.system,
        );
      },
      loading: () => ThemeMode.system,
      error: (_, __) => ThemeMode.system,
    );
  }

  static const _themeModeKey = 'theme_mode';

  Future<void> setTheme(ThemeMode mode) async {
    final prefs = await ref.read(sharedPreferencesProvider.future);
    await prefs.setString(_themeModeKey, mode.name);
    ref.invalidateSelf();
  }
}
