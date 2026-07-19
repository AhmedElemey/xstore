import '../../orders/domain/entities/order_entity.dart';
import 'entities/delivery_request.dart';

/// The next step a courier can take on an assigned package request
/// (mirrors [CourierOrderAction] for marketplace orders).
enum CourierPackageAction {
  /// Request confirmed — collect the cash price from the sender, then the
  /// parcel.
  collectAndPickUp,

  /// Parcel (and cash) is with the courier — deliver to the recipient.
  deliver,

  /// Terminal, cancelled, or not yet actionable.
  none,
}

CourierPackageAction courierPackageNextAction(DeliveryRequestStatus status) =>
    switch (status) {
      DeliveryRequestStatus.confirmed => CourierPackageAction.collectAndPickUp,
      DeliveryRequestStatus.pickedUp => CourierPackageAction.deliver,
      _ => CourierPackageAction.none,
    };

/// Requests still on the courier's active run (needs pick-up or drop-off).
bool isActivePackageTask(DeliveryRequestEntity request) =>
    courierPackageNextAction(request.status) != CourierPackageAction.none;

/// Cash the courier collects from the sender at pickup. Once picked up it
/// is cash-in-hand until handover; zero before the consumer confirms the
/// admin's price (the app never holds money).
double cashToCollectFromSender(DeliveryRequestEntity request) =>
    switch (request.status) {
      DeliveryRequestStatus.confirmed ||
      DeliveryRequestStatus.pickedUp ||
      DeliveryRequestStatus.delivered =>
        request.price ?? 0,
      _ => 0,
    };

/// Whether the courier is holding the sender's cash (collected at pickup,
/// held until handover to xStore).
bool courierHoldsPackageCash(DeliveryRequestEntity request) =>
    (request.status == DeliveryRequestStatus.pickedUp ||
        request.status == DeliveryRequestStatus.delivered) &&
    request.price != null;

/// Privacy rule: the customer's name/phone are hidden from couriers until
/// the request is confirmed (i.e. it actually became their task).
bool courierSeesCustomerIdentity(DeliveryRequestStatus status) =>
    switch (status) {
      DeliveryRequestStatus.confirmed ||
      DeliveryRequestStatus.pickedUp ||
      DeliveryRequestStatus.delivered =>
        true,
      _ => false,
    };

/// Equivalent privacy rule for marketplace orders: identity is hidden only
/// while the order is pending vendor confirmation.
bool courierSeesOrderCustomerIdentity(OrderStatus status) =>
    status != OrderStatus.pending;
