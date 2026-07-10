enum VendorCommissionAlertLevel { none, warn, paused }

class VendorCommissionWallet {
  const VendorCommissionWallet({
    required this.outstandingEgp,
    required this.warnThresholdEgp,
    required this.pauseThresholdEgp,
  });

  final double outstandingEgp;
  final double warnThresholdEgp;
  final double pauseThresholdEgp;

  VendorCommissionAlertLevel get alertLevel {
    if (outstandingEgp >= pauseThresholdEgp) {
      return VendorCommissionAlertLevel.paused;
    }
    if (outstandingEgp >= warnThresholdEgp) {
      return VendorCommissionAlertLevel.warn;
    }
    return VendorCommissionAlertLevel.none;
  }

  bool get isPaused => alertLevel == VendorCommissionAlertLevel.paused;
}
