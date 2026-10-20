/// Starter/fallback commission fee per order (EGP).
///
/// The admin-configured source of truth is `SystemSetting.commissionValueOnOrder`,
/// exposed via `GET /api/vendor/orders` in `OrderStatsEntity.commissionValueOnOrder`.
/// The backend echoes `0` until an admin sets a positive value in SystemSettings,
/// which is why this fallback exists — a positive admin value always wins.
const double kStarterCommissionFeeEgp = 2.0;

/// Fallback weekly vendor owed-balance thresholds (EGP) — see
/// [kStarterCommissionFeeEgp] for when these apply instead of the real,
/// admin-configured values.
const double kCommissionWarnThresholdEgp = 100.0;
const double kCommissionPauseThresholdEgp = 200.0;