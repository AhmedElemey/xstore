import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/constants/prefs_keys.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/network/dio_provider.dart';
import '../../../../shared/providers/shared_providers.dart';
import '../../data/datasources/general_settings_remote_datasource.dart';
import '../../domain/entities/app_settings.dart';

part 'general_settings_provider.g.dart';

/// How long a first launch (no cache) waits for the settings before showing
/// the splash error + Retry.
const kFirstLaunchSettingsTimeout = Duration(seconds: 10);

/// Minimum gap between two fetch attempts triggered by the app returning to
/// the foreground, so quick app switches don't each hit the backend.
const kSettingsResumeThrottle = Duration(seconds: 60);

/// App-wide General Settings, cached in SharedPreferences.
///
/// - Cache present: ready immediately from the cache; a background fetch
///   replaces the state and the cache only when the values differ, and a
///   failed refresh keeps the cache silently. An empty fetch never replaces a
///   non-empty cache.
/// - No cache (first launch): waits for the fetch (capped at
///   [kFirstLaunchSettingsTimeout]), caches it, then is ready. A failure is
///   an `AsyncError` (splash shows Retry = `ref.invalidate`).
/// - The same background refresh runs when the app resumes (throttled by
///   [kSettingsResumeThrottle]); with no value yet (first launch failed) a
///   resume retries the first-launch fetch instead.
///
/// The settings request is `ApiAuthHeaders.standalone()`: a 5xx never raises
/// the global server-error page, the splash/background handling owns it.
///
/// keepAlive on purpose: it is app-lifetime config that the router gates the
/// splash on and the pay-to screens derive from. Its only resources (the
/// lifecycle listener and the in-flight request) are released in
/// `ref.onDispose`.
@Riverpod(keepAlive: true)
class GeneralSettings extends _$GeneralSettings {
  /// Bumped on every build and on dispose; a fetch that finds a different
  /// value is stale and must not touch the state or the cache.
  int _generation = 0;
  bool _fetching = false;
  DateTime? _lastAttempt;
  late CancelToken _cancel;
  late GeneralSettingsRemoteDataSource _remote;
  late SharedPreferences _prefs;

  @visibleForTesting
  DateTime now() => DateTime.now();

  @override
  Future<AppSettings> build() async {
    final generation = ++_generation;
    _fetching = false;
    final cancel = _cancel = CancelToken();
    final lifecycle = AppLifecycleListener(onStateChange: _onLifecycleChange);
    ref.onDispose(() {
      _generation++;
      cancel.cancel('General settings provider disposed');
      lifecycle.dispose();
    });

    final prefs = _prefs = await ref.watch(sharedPreferencesProvider.future);
    // read, not watch: a rebuilt Dio must not re-run the startup fetch.
    _remote = GeneralSettingsRemoteDataSource(ref.read(dioProvider));

    final cached = AppSettings.tryFromJson(
      prefs.getString(PrefsKeys.generalSettings),
    );
    if (cached != null) {
      unawaited(_refresh(generation, cached));
      return cached;
    }

    _fetching = true;
    _lastAttempt = now();
    try {
      final fetched = await _remote
          .fetchAll(cancelToken: cancel)
          .timeout(kFirstLaunchSettingsTimeout);
      await prefs.setString(PrefsKeys.generalSettings, fetched.toJson());
      return fetched;
    } on TimeoutException {
      cancel.cancel('General settings timed out');
      rethrow;
    } finally {
      if (generation == _generation) _fetching = false;
    }
  }

  void _onLifecycleChange(AppLifecycleState lifecycle) {
    if (lifecycle != AppLifecycleState.resumed || _fetching) return;
    final last = _lastAttempt;
    if (last != null && now().difference(last) < kSettingsResumeThrottle) {
      return;
    }
    final current = state.valueOrNull;
    if (current != null) {
      unawaited(_refresh(_generation, current));
    } else if (state.hasError) {
      // First launch failed: retry it (same as the splash Retry).
      ref.invalidateSelf();
    }
  }

  /// Silent refresh: any failure keeps the current state and cache. [baseline]
  /// is the value to compare against while the state has none yet.
  Future<void> _refresh(int generation, AppSettings baseline) async {
    _fetching = true;
    _lastAttempt = now();
    try {
      // Let build()'s own result land first, or it would overwrite ours.
      await Future<void>.delayed(Duration.zero);
      final fresh = await _remote.fetchAll(cancelToken: _cancel);
      if (generation != _generation) return;
      final current = state.valueOrNull ?? baseline;
      if (fresh == current) return;
      // An empty answer must not wipe a good cache.
      if (fresh.isEmpty && !current.isEmpty) return;
      // Cache first: state never gets ahead of what a restart would load.
      final saved = await _prefs.setString(
        PrefsKeys.generalSettings,
        fresh.toJson(),
      );
      if (!saved || generation != _generation) return;
      state = AsyncData(fresh);
    } on DioException {
      // Offline / server error / cancelled: keep the cache.
    } on AppException {
      // Same, after the datasource mapped the failure.
    } on FormatException {
      // Malformed body: keep the cache.
    } on TimeoutException {
      // Keep the cache.
    } catch (e, st) {
      // A programming error, not an expected failure: don't hide it in debug.
      if (kDebugMode) debugPrint('General settings refresh failed: $e\n$st');
    } finally {
      if (generation == _generation) _fetching = false;
    }
  }
}
