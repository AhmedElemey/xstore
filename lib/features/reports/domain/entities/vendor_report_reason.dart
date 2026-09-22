/// Why a consumer is reporting a vendor after a placed order.
enum VendorReportReason {
  fraud,
  poorProductQuality,
  itemNotAsDescribed,
  noResponseFromSeller,
  harassment,
  other,
}

extension VendorReportReasonWire on VendorReportReason {
  /// Wire value proposed for the backend contract (PascalCase, matching
  /// this backend's other enum conventions — see `orderStatusToWireName`).
  /// NOT YET CONFIRMED: no vendor-report endpoint exists on the backend as
  /// of 2026-09-15. See `VendorReportsRemoteDataSourceImpl` for the full
  /// proposed contract.
  String get wireName => switch (this) {
    VendorReportReason.fraud => 'Fraud',
    VendorReportReason.poorProductQuality => 'PoorProductQuality',
    VendorReportReason.itemNotAsDescribed => 'ItemNotAsDescribed',
    VendorReportReason.noResponseFromSeller => 'NoResponseFromSeller',
    VendorReportReason.harassment => 'Harassment',
    VendorReportReason.other => 'Other',
  };
}
