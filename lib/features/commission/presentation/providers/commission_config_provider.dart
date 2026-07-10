import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'commission_config_provider.g.dart';

/// Starter flat commission rate (%), applied to every category at launch.
///
/// No backend commission-config endpoint exists yet (see design memory:
/// rates must eventually be server-side, per-category). Until that endpoint
/// is confirmed, this is the single place the rate is defined — swap the
/// body of [commissionRateForCategory] for a real network call once the
/// endpoint exists; call sites already pass `categoryId` for that.
const double kStarterCommissionRatePercent = 2.0;

/// Weekly vendor owed-balance thresholds (EGP), both owner-configurable.
/// Warn: notify the vendor to pay before being blocked. Pause: block new
/// listing publishes until the balance is paid down. See design memory
/// for the full mechanism — no backend config endpoint exists yet, so
/// these are the single source of truth until one does.
const double kCommissionWarnThresholdEgp = 100.0;
const double kCommissionPauseThresholdEgp = 200.0;

@riverpod
double commissionRateForCategory(
  CommissionRateForCategoryRef ref,
  int? categoryId,
) {
  return kStarterCommissionRatePercent;
}
