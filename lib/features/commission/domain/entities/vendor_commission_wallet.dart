enum VendorCommissionAlertLevel { none, warn, paused }

class VendorCommissionWallet {
  const VendorCommissionWallet({
    required this.exceedsWarnThreshold,
    required this.exceedsPauseThreshold,
    required this.warnThresholdEgp,
    required this.pauseThresholdEgp,
    this.outstandingBalanceEgp,
  });

  /// Server-authoritative warn/pause state — always use these flags, never
  /// compare [outstandingBalanceEgp] against the thresholds client-side.
  final bool exceedsWarnThreshold;
  final bool exceedsPauseThreshold;
  final double warnThresholdEgp;
  final double pauseThresholdEgp;

  /// Owed platform fees (EGP) from the `GET /api/vendor/orders` envelope.
  /// Null when the backend omits it (older deployment, or no vendor
  /// session) — the wallet screen then hides the balance card.
  final double? outstandingBalanceEgp;

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
