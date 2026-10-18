import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/constants/prefs_keys.dart';
import '../../../../core/network/dio_provider.dart';
import '../../../../shared/providers/shared_providers.dart';
import '../../data/datasources/general_settings_remote_datasource.dart';
import '../../domain/entities/app_settings.dart';

part 'general_settings_provider.g.dart';

/// How long a first launch (no cache) waits for the settings before showing
/// the splash error + Retry.
const kFirstLaunchSettingsTimeout = Duration(seconds: 10);

/// App-wide General Settings, cached in SharedPreferences.
///
/// - Cache present: ready immediately from the cache; a background fetch
///   replaces the state and the cache only when the values differ, and a
///   failed refresh keeps the cache silently.
/// - No cache (first launch): waits for the fetch (capped at
///   [kFirstLaunchSettingsTimeout]), caches it, then is ready. A failure is
///   an `AsyncError` (splash shows Retry = `ref.invalidate`).
///
/// keepAlive on purpose: it is app-lifetime config that the router gates the
/// splash on and the pay-to screens derive from; it holds no resources.
@Riverpod(keepAlive: true)
class GeneralSettings extends _$GeneralSettings {
  @override
  Future<AppSettings> build() async {
    final prefs = await ref.watch(sharedPreferencesProvider.future);
    // read, not watch: a rebuilt Dio must not re-run the startup fetch.
    final remote = GeneralSettingsRemoteDataSource(ref.read(dioProvider));

    final cached = AppSettings.tryFromJson(
      prefs.getString(PrefsKeys.generalSettings),
    );
    if (cached != null) {
      unawaited(_refreshInBackground(remote, prefs, cached));
      return cached;
    }

    final fetched = await remote.fetchAll().timeout(
      kFirstLaunchSettingsTimeout,
    );
    await prefs.setString(PrefsKeys.generalSettings, fetched.toJson());
    return fetched;
  }

  Future<void> _refreshInBackground(
    GeneralSettingsRemoteDataSource remote,
    SharedPreferences prefs,
    AppSettings cached,
  ) async {
    try {
      // Let build()'s own result land first, or it would overwrite ours.
      await Future<void>.delayed(Duration.zero);
      final fresh = await remote.fetchAll();
      if (fresh == cached) return;
      state = AsyncData(fresh);
      await prefs.setString(PrefsKeys.generalSettings, fresh.toJson());
    } catch (_) {
      // Offline/server error (or the container was disposed): keep the cache.
    }
  }
}
