class CommissionBreakdown {
  const CommissionBreakdown({
    required this.price,
    required this.feeAmount,
    required this.vendorEarns,
  });

  final double price;
  final double feeAmount;
  final double vendorEarns;

  /// Flat platform fee per order (EGP), not a percentage of [price].
  factory CommissionBreakdown.forPrice(
    double price, {
    required double feeEgp,
  }) {
    return CommissionBreakdown(
      price: price,
      feeAmount: feeEgp,
      vendorEarns: price - feeEgp,
    );
  }
}
