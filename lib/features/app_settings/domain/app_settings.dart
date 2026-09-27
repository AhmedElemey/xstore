/// Keys the super admin manages in the admin dashboard's General Settings
/// page. Contract: `docs_business/backend/11_APP_SETTINGS_ENDPOINT_HANDOFF.md`.
abstract final class AppSettingKeys {
  static const forceUpdateRequired = 'force_update_required';
  static const softUpdateRequired = 'soft_update_required';
  static const minimumAppVersion = 'minimum_app_version';
  static const androidStoreUrl = 'android_store_url';
  static const iosStoreUrl = 'ios_store_url';
}

enum AppUpdateRequirement { none, optional, required }

/// Remote config from `GET /api/app-settings`: a flat map of already-typed
/// JSON values (bool / int / double / String / List / Map).
class AppSettings {
  const AppSettings(this._values);

  /// Used when the fetch fails or in mock mode — every key falls back.
  static const empty = AppSettings({});

  final Map<String, Object?> _values;

  /// The value for [key] when it exists with type [T], else [fallback].
  /// Admins can delete or retype a key at any time, so every read needs a
  /// built-in default.
  T valueOf<T>(String key, T fallback) {
    final value = _values[key];
    return value is T ? value : fallback;
  }

  /// Only an app older than `minimum_app_version` is ever prompted; the two
  /// flags choose between a blocking and a dismissible prompt. Updating the
  /// app therefore always clears the prompt.
  AppUpdateRequirement updateRequirement(String currentVersion) {
    final minimum = valueOf(AppSettingKeys.minimumAppVersion, '').trim();
    if (minimum.isEmpty || compareVersions(currentVersion, minimum) >= 0) {
      return AppUpdateRequirement.none;
    }
    if (valueOf(AppSettingKeys.forceUpdateRequired, false)) {
      return AppUpdateRequirement.required;
    }
    if (valueOf(AppSettingKeys.softUpdateRequired, false)) {
      return AppUpdateRequirement.optional;
    }
    return AppUpdateRequirement.none;
  }
}

/// Compares dotted versions numerically ("2.0.10" > "2.0.4"), ignoring any
/// `+build` / `-pre` suffix; missing or non-numeric parts count as 0.
int compareVersions(String a, String b) {
  List<int> parts(String v) => v
      .split(RegExp('[+-]'))
      .first
      .trim()
      .split('.')
      .map((p) => int.tryParse(p) ?? 0)
      .toList();
  final x = parts(a);
  final y = parts(b);
  for (var i = 0; i < x.length || i < y.length; i++) {
    final diff = (i < x.length ? x[i] : 0) - (i < y.length ? y[i] : 0);
    if (diff != 0) return diff.sign;
  }
  return 0;
}
