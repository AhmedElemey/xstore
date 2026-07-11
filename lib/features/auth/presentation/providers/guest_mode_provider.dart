import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/constants/prefs_keys.dart';
import '../../../../shared/providers/shared_providers.dart';

part 'guest_mode_provider.g.dart';

/// Whether the user chose "Continue as Guest" instead of signing in.
///
/// Guests can browse (home, explore, product, seller pages) but every
/// account-bound route or action requires login — enforced centrally in
/// `computeXStoreAuthRedirect` and at action sites via `requireLogin`.
/// The flag persists across launches (same lazy-load pattern as
/// [AppThemeMode]) and is cleared as soon as a real session is adopted.
@Riverpod(keepAlive: true)
class GuestMode extends _$GuestMode {
  @override
  bool build() {
    _loadSaved();
    return false;
  }

  Future<void> _loadSaved() async {
    try {
      final prefs = await ref.read(sharedPreferencesProvider.future);
      final saved = prefs.getBool(PrefsKeys.guestMode) ?? false;
      if (state != saved) {
        state = saved;
      }
    } catch (_) {
      // Storage read failure — stay non-guest; the login screen still works.
    }
  }

  Future<void> enable() => _set(true);

  Future<void> disable() => _set(false);

  Future<void> _set(bool value) async {
    state = value;
    try {
      final prefs = await ref.read(sharedPreferencesProvider.future);
      await prefs.setBool(PrefsKeys.guestMode, value);
    } catch (_) {
      // Persistence failure only loses the flag across restarts.
    }
  }
}
