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
  static const _key = 'theme_mode';

  @override
  ThemeMode build() {
    _loadSavedTheme();
    return ThemeMode.light;
  }

  Future<void> _loadSavedTheme() async {
    try {
      final prefs = await ref.read(sharedPreferencesProvider.future);
      final name = prefs.getString(_key);
      if (name == null) return;

      final saved = ThemeMode.values.firstWhere(
        (mode) => mode.name == name,
        orElse: () => ThemeMode.light,
      );
      if (state != saved) {
        state = saved;
      }
    } catch (_) {
      // Ignore storage read failures and keep light mode.
    }
  }

  Future<void> setTheme(ThemeMode mode) async {
    final prefs = await ref.read(sharedPreferencesProvider.future);
    await prefs.setString(_key, mode.name);
    state = mode;
  }

  Future<void> toggleDarkMode() async {
    final next = isDark ? ThemeMode.light : ThemeMode.dark;
    await setTheme(next);
  }

  bool get isDark {
    if (state == ThemeMode.dark) return true;
    if (state == ThemeMode.light) return false;
    return WidgetsBinding.instance.platformDispatcher.platformBrightness ==
        Brightness.dark;
  }
}
