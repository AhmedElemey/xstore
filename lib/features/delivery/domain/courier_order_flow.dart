import '../../orders/domain/entities/order_entity.dart';

/// The next step a courier can take on an assigned order. The courier flow
/// deliberately reuses the existing [OrderStatus] lifecycle instead of a
/// parallel status enum: pick-up = shipped, drop-off = delivered,
/// failed = cancelled.
enum CourierOrderAction {
  /// Order is confirmed/processing — collect the parcel from the vendor.
  pickUp,

  /// Parcel is with the courier (shipped) — deliver and collect COD.
  deliver,

  /// Terminal or not yet actionable (pending vendor confirmation).
  none,
}

CourierOrderAction courierNextAction(OrderStatus status) => switch (status) {
      OrderStatus.confirmed ||
      OrderStatus.processing =>
        CourierOrderAction.pickUp,
      OrderStatus.shipped => CourierOrderAction.deliver,
      _ => CourierOrderAction.none,
    };

/// Orders still on the courier's active run (needs pick-up or drop-off).
bool isActiveCourierOrder(OrderEntity order) =>
    courierNextAction(order.status) != CourierOrderAction.none;

/// Cash the courier must collect from the buyer at the door. Zero for
/// prepaid orders (card) and anything already marked paid.
double codAmountToCollect(OrderEntity order) =>
    order.paymentMethod == PaymentMethod.cashOnDelivery && !order.isPaid
        ? order.total
        : 0;

/// Delivered COD orders put cash in the courier's hand until handover.
bool holdsCollectedCash(OrderEntity order) =>
    order.status == OrderStatus.delivered && codAmountToCollect(order) > 0;
