import 'dart:ui';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../shared/providers/shared_providers.dart';

enum AppLanguage { english, arabic }

class AppLocaleNotifier extends StateNotifier<AppLanguage> {
  AppLocaleNotifier(this.ref) : super(AppLanguage.english) {
    _loadSavedLanguage();
  }

  static const _key = 'app_language';
  final Ref ref;

  Future<void> _loadSavedLanguage() async {
    final prefs = await ref.read(sharedPreferencesProvider.future);
    final saved = prefs.getString(_key);
    if (saved == null) return;
    state = AppLanguage.values.firstWhere(
      (e) => e.name == saved,
      orElse: () => AppLanguage.english,
    );
  }

  Future<void> setLanguage(AppLanguage lang) async {
    state = lang;
    final prefs = await ref.read(sharedPreferencesProvider.future);
    await prefs.setString(_key, lang.name);
  }

  Future<void> toggleLanguage() async {
    await setLanguage(
      state == AppLanguage.english ? AppLanguage.arabic : AppLanguage.english,
    );
  }

  Locale get locale => switch (state) {
        AppLanguage.english => const Locale('en'),
        AppLanguage.arabic => const Locale('ar'),
      };

  bool get isArabic => state == AppLanguage.arabic;
  bool get isEnglish => state == AppLanguage.english;
}

final appLocaleProvider =
    StateNotifierProvider<AppLocaleNotifier, AppLanguage>(
  (ref) => AppLocaleNotifier(ref),
);
