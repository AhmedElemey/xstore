// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'general_settings_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$generalSettingsHash() => r'4309fab65e0a01d52352430527fec574a8e09e2a';

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
///
/// Copied from [GeneralSettings].
@ProviderFor(GeneralSettings)
final generalSettingsProvider =
    AsyncNotifierProvider<GeneralSettings, AppSettings>.internal(
  GeneralSettings.new,
  name: r'generalSettingsProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$generalSettingsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$GeneralSettings = AsyncNotifier<AppSettings>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
