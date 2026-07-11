import '../../../orders/domain/entities/order_entity.dart';

/// Lifecycle of the platform commission owed by a vendor for one order.
///
/// pending: order not yet delivered — nothing owed yet.
/// due: delivered (COD cash collected by vendor) — vendor now owes the fee.
/// settled: vendor has paid off this amount in a wallet settlement (phase C).
/// voided: order cancelled/refunded — no commission owed.
enum CommissionStatus { pending, due, settled, voided }

/// Order-status → commission-status mapping. COD assumption (see design
/// memory): commission is only "due" once the vendor has actually collected
/// cash on delivery; cancelled/refunded orders owe nothing.
CommissionStatus commissionStatusForOrder(OrderStatus status) {
  switch (status) {
    case OrderStatus.cancelled:
    case OrderStatus.refunded:
      return CommissionStatus.voided;
    case OrderStatus.delivered:
      return CommissionStatus.due;
    case OrderStatus.pending:
    case OrderStatus.confirmed:
    case OrderStatus.processing:
    case OrderStatus.shipped:
      return CommissionStatus.pending;
  }
}
