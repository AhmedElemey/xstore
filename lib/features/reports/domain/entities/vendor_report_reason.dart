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
  /// PascalCase wire value (this backend's enum convention — see
  /// `orderStatusToWireName`). "Fraud" and "Harassment" appear in the
  /// Postman collection; the rest are unconfirmed.
  String get wireName => switch (this) {
    VendorReportReason.fraud => 'Fraud',
    VendorReportReason.poorProductQuality => 'PoorProductQuality',
    VendorReportReason.itemNotAsDescribed => 'ItemNotAsDescribed',
    VendorReportReason.noResponseFromSeller => 'NoResponseFromSeller',
    VendorReportReason.harassment => 'Harassment',
    VendorReportReason.other => 'Other',
  };
}
