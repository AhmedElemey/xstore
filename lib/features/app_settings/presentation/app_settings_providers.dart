import 'package:flutter/foundation.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/error/exceptions.dart';
import '../../../core/mock/mock_config.dart';
import '../../../core/network/dio_provider.dart';
import '../data/app_settings_remote_datasource.dart';
import '../domain/app_settings.dart';

part 'app_settings_providers.g.dart';

@Riverpod(keepAlive: true)
AppSettingsRemoteDataSource appSettingsRemoteDataSource(
  AppSettingsRemoteDataSourceRef ref,
) {
  return AppSettingsRemoteDataSource(ref.watch(dioProvider));
}

/// Fetched once per launch and kept alive on purpose: it is app-wide config
/// read by the root [AppUpdateGate], not screen state. A failed fetch (API
/// down, endpoint not deployed yet) yields [AppSettings.empty] so every key
/// uses its built-in default and the app is never blocked by an outage.
@Riverpod(keepAlive: true)
Future<AppSettings> appSettings(AppSettingsRef ref) async {
  if (MockConfig.useMock) return AppSettings.empty;
  try {
    return AppSettings(
      await ref.watch(appSettingsRemoteDataSourceProvider).fetchAll(),
    );
  } on AppException catch (e) {
    debugPrint('app-settings unavailable, using defaults: $e');
    return AppSettings.empty;
  }
}

/// Installed app version (e.g. "1.0.0"), without the build number.
@Riverpod(keepAlive: true)
Future<String> appVersion(AppVersionRef ref) async {
  return (await PackageInfo.fromPlatform()).version;
}

/// [AppUpdateRequirement.none] until both the settings and the installed
/// version are known, so nothing flashes on screen while loading.
@riverpod
AppUpdateRequirement appUpdateRequirement(AppUpdateRequirementRef ref) {
  final settings = ref.watch(appSettingsProvider).valueOrNull;
  final version = ref.watch(appVersionProvider).valueOrNull;
  if (settings == null || version == null) return AppUpdateRequirement.none;
  return settings.updateRequirement(version);
}
