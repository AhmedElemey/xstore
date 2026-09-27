// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_settings_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$appSettingsRemoteDataSourceHash() =>
    r'3b9fac8889e50fb7e64db65c0c32d54f96b150be';

/// See also [appSettingsRemoteDataSource].
@ProviderFor(appSettingsRemoteDataSource)
final appSettingsRemoteDataSourceProvider =
    Provider<AppSettingsRemoteDataSource>.internal(
  appSettingsRemoteDataSource,
  name: r'appSettingsRemoteDataSourceProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$appSettingsRemoteDataSourceHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef AppSettingsRemoteDataSourceRef
    = ProviderRef<AppSettingsRemoteDataSource>;
String _$appSettingsHash() => r'df4f7d704ddc857aa26e1e3a8a5b0b66461a473f';

/// Fetched once per launch and kept alive on purpose: it is app-wide config
/// read by the root [AppUpdateGate], not screen state. A failed fetch (API
/// down, endpoint not deployed yet) yields [AppSettings.empty] so every key
/// uses its built-in default and the app is never blocked by an outage.
///
/// Copied from [appSettings].
@ProviderFor(appSettings)
final appSettingsProvider = FutureProvider<AppSettings>.internal(
  appSettings,
  name: r'appSettingsProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$appSettingsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef AppSettingsRef = FutureProviderRef<AppSettings>;
String _$appVersionHash() => r'e04a547018b2f377bb7339b124952bad76fc956e';

/// Installed app version (e.g. "1.0.0"), without the build number.
///
/// Copied from [appVersion].
@ProviderFor(appVersion)
final appVersionProvider = FutureProvider<String>.internal(
  appVersion,
  name: r'appVersionProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$appVersionHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef AppVersionRef = FutureProviderRef<String>;
String _$appUpdateRequirementHash() =>
    r'd811c8a7c2c5ba5c6398986535da07c39c95f2fd';

/// [AppUpdateRequirement.none] until both the settings and the installed
/// version are known, so nothing flashes on screen while loading.
///
/// Copied from [appUpdateRequirement].
@ProviderFor(appUpdateRequirement)
final appUpdateRequirementProvider =
    AutoDisposeProvider<AppUpdateRequirement>.internal(
  appUpdateRequirement,
  name: r'appUpdateRequirementProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$appUpdateRequirementHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef AppUpdateRequirementRef = AutoDisposeProviderRef<AppUpdateRequirement>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
