import '../../features/general_settings/domain/entities/app_settings.dart';

/// General Settings for MOCK=true runs: the four commission pay-to handles.
final mockAppSettings = AppSettings.fromItems(const [
  {'key': 'instapay_handle', 'value': 'xstore@instapay'},
  {'key': 'vodafone_cash_handle', 'value': '01000000000'},
  {'key': 'orange_cash_handle', 'value': '01200000000'},
  {'key': 'etisalat_cash_handle', 'value': '01100000000'},
]);
