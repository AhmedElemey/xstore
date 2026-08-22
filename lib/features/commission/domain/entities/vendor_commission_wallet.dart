enum VendorCommissionAlertLevel { none, warn, paused }

class VendorCommissionWallet {
  const VendorCommissionWallet({
    required this.exceedsWarnThreshold,
    required this.exceedsPauseThreshold,
    required this.warnThresholdEgp,
    required this.pauseThresholdEgp,
  });

  /// Server-authoritative — the vendor's own owed-balance amount
  /// (`VendorCommissionWallet.OutstandingEgp`) is admin-only and never
  /// sent to the vendor app, so these flags (not a computed comparison)
  /// are the source of truth for whether the vendor has crossed a
  /// threshold.
  final bool exceedsWarnThreshold;
  final bool exceedsPauseThreshold;
  final double warnThresholdEgp;
  final double pauseThresholdEgp;

  VendorCommissionAlertLevel get alertLevel {
    if (exceedsPauseThreshold) {
      return VendorCommissionAlertLevel.paused;
    }
    if (exceedsWarnThreshold) {
      return VendorCommissionAlertLevel.warn;
    }
    return VendorCommissionAlertLevel.none;
  }

  bool get isPaused => alertLevel == VendorCommissionAlertLevel.paused;
}
