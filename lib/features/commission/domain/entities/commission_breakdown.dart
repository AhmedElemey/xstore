class CommissionBreakdown {
  const CommissionBreakdown({
    required this.price,
    required this.ratePercent,
    required this.feeAmount,
    required this.vendorEarns,
  });

  final double price;
  final double ratePercent;
  final double feeAmount;
  final double vendorEarns;

  factory CommissionBreakdown.forPrice(double price, {required double ratePercent}) {
    final fee = price * (ratePercent / 100);
    return CommissionBreakdown(
      price: price,
      ratePercent: ratePercent,
      feeAmount: fee,
      vendorEarns: price - fee,
    );
  }
}
