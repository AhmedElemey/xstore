import 'package:flutter/foundation.dart';

import 'app_flavor.dart';

/// Initialized once at app startup from the flavor entry point ([main_dev.dart],
/// [main_prod.dart], or the default [main]).
abstract final class AppConfig {
  static AppFlavor? _flavor;

  static AppFlavor get flavor {
    assert(
      _flavor != null,
      'AppConfig.init must be called from bootstrap() before reading flavor.',
    );
    return _flavor!;
  }

  /// Null in unit tests that never call [init] — callers must not assume a
  /// flavor exists (Amplitude falls back to dart-define / off).
  static AppFlavor? get maybeFlavor => _flavor;

  static void init(AppFlavor flavor) {
    _flavor = flavor;
  }

  @visibleForTesting
  static void debugReset() {
    _flavor = null;
  }
}
