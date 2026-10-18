/// How a vendor sent a platform-fee payment. Payments happen outside the
/// app (InstaPay transfer or mobile-wallet send); the vendor then uploads
/// the receipt for an admin to approve.
enum CommissionPaymentMethod {
  instaPay,
  vodafoneCash,
  orangeCash,
  etisalatCash;

  /// PascalCase wire value (this backend's enum convention); in the backend
  /// collection (v10) as `method`.
  String get wireName => switch (this) {
    CommissionPaymentMethod.instaPay => 'InstaPay',
    CommissionPaymentMethod.vodafoneCash => 'VodafoneCash',
    CommissionPaymentMethod.orangeCash => 'OrangeCash',
    CommissionPaymentMethod.etisalatCash => 'EtisalatCash',
  };

  /// Tolerant read: case-insensitive name or the C# enum code
  /// (InstaPay=1, VodafoneCash=2, OrangeCash=3, EtisalatCash=4).
  static CommissionPaymentMethod? fromWire(String? value) {
    final v = value?.trim().toLowerCase();
    if (v == null || v.isEmpty) return null;
    for (final method in values) {
      if (method.wireName.toLowerCase() == v || '${method.index + 1}' == v) {
        return method;
      }
    }
    return null;
  }
}
