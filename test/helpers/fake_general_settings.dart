import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:xstore/features/general_settings/domain/entities/app_settings.dart';
import 'package:xstore/features/general_settings/presentation/providers/general_settings_provider.dart';

class _ReadySettings extends GeneralSettings {
  _ReadySettings(this._settings);
  final AppSettings _settings;

  @override
  Future<AppSettings> build() async => _settings;
}

/// Overrides the startup settings fetch with an already-ready value, for
/// tests that build the app router or splash.
Override readyGeneralSettings([AppSettings settings = AppSettings.empty]) =>
    generalSettingsProvider.overrideWith(() => _ReadySettings(settings));

/// Live `GET /api/general-settings?page=1&pageSize=20` response (2026-10-18).
const generalSettingsSampleBody = {
  'items': [
    {
      'id': 4,
      'key': 'etisalat_cash_handle',
      'value': '01019816854',
      'dataType': 'String',
      'description': null,
      'createdAt': '2026-10-18T09:12:43.5097189',
      'updatedAt': null,
    },
    {
      'id': 6,
      'key': 'instapay_handle',
      'value': '01019816854',
      'dataType': 'String',
      'description': null,
      'createdAt': '2026-10-18T13:47:10.1176324',
      'updatedAt': null,
    },
    {
      'id': 3,
      'key': 'orange_cash_handle',
      'value': '01019816854',
      'dataType': 'String',
      'description': null,
      'createdAt': '2026-10-18T09:12:28.3549508',
      'updatedAt': null,
    },
    {
      'id': 5,
      'key': 'test',
      'value': 'false',
      'dataType': 'Boolean',
      'description': null,
      'createdAt': '2026-10-18T13:39:32.5756959',
      'updatedAt': null,
    },
    {
      'id': 2,
      'key': 'vodafone_cash_handle',
      'value': '01019816854',
      'dataType': 'String',
      'description': null,
      'createdAt': '2026-10-18T09:12:07.2102185',
      'updatedAt': null,
    },
  ],
  'totalCount': 5,
  'page': 1,
  'pageSize': 20,
  'totalPages': 1,
};
