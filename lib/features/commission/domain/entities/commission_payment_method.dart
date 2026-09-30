/// How a vendor sent a platform-fee payment. Payments happen outside the
/// app (InstaPay transfer or mobile-wallet send); the vendor then uploads
/// the receipt for an admin to approve.
enum CommissionPaymentMethod {
  instaPay,
  vodafoneCash,
  orangeCash,
  etisalatCash;

  /// PascalCase wire value (this backend's enum convention). PROPOSED —
  /// see docs_business/backend/11_COMMISSION_PAYMENT_REQUESTS_HANDOFF.md.
  /// Also the key of each pay-to account in the
  /// `commission_payment_accounts` app setting.
  String get wireName => switch (this) {
    CommissionPaymentMethod.instaPay => 'InstaPay',
    CommissionPaymentMethod.vodafoneCash => 'VodafoneCash',
    CommissionPaymentMethod.orangeCash => 'OrangeCash',
    CommissionPaymentMethod.etisalatCash => 'EtisalatCash',
  };

  static CommissionPaymentMethod? fromWire(String? value) {
    for (final method in values) {
      if (method.wireName == value) return method;
    }
    return null;
  }
}
