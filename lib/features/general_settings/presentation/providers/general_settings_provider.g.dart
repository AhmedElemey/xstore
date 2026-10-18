// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'general_settings_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$generalSettingsHash() => r'1f53d77ab7c41dd08a7513b80c09ab34e0f5111b';

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
