/// Lifecycle of the platform commission owed by a vendor for one order.
///
/// pending: order not yet delivered — nothing owed yet.
/// due: delivered (COD cash collected by vendor) — vendor now owes the fee.
/// settled: vendor has paid off this amount in a wallet settlement (phase C).
/// voided: order cancelled/refunded — no commission owed.
enum CommissionStatus { pending, due, settled, voided }
