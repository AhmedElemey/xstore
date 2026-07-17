import 'package:flutter_test/flutter_test.dart';

import 'package:xstore/features/delivery/domain/courier_order_flow.dart';
import 'package:xstore/features/orders/domain/entities/order_entity.dart';

OrderEntity _order({
  required OrderStatus status,
  PaymentMethod payment = PaymentMethod.cashOnDelivery,
  bool isPaid = false,
  double total = 1000,
}) {
  final now = DateTime(2026, 7, 1);
  return OrderEntity(
    id: 'order_1',
    consumerId: 'consumer_1',
    consumerName: 'Test Buyer',
    consumerPhone: '0100000000',
    vendorId: 'vendor_1',
    vendorName: 'Test Vendor',
    vendorStoreName: 'Test Store',
    items: const [],
    status: status,
    paymentMethod: payment,
    isPaid: isPaid,
    deliveryAddress: const OrderAddress(
      fullName: 'Test Buyer',
      phone: '0100000000',
      street: 'Street 1',
      city: 'Cairo',
      wilaya: 'Cairo',
    ),
    subtotal: total,
    shippingCost: 0,
    discount: 0,
    total: total,
    createdAt: now,
    updatedAt: now,
  );
}

void main() {
  group('courierNextAction', () {
    test('confirmed and processing need pick-up', () {
      expect(courierNextAction(OrderStatus.confirmed),
          CourierOrderAction.pickUp);
      expect(courierNextAction(OrderStatus.processing),
          CourierOrderAction.pickUp);
    });

    test('shipped needs drop-off', () {
      expect(
          courierNextAction(OrderStatus.shipped), CourierOrderAction.deliver);
    });

    test('pending and terminal statuses have no action', () {
      expect(courierNextAction(OrderStatus.pending), CourierOrderAction.none);
      expect(
          courierNextAction(OrderStatus.delivered), CourierOrderAction.none);
      expect(
          courierNextAction(OrderStatus.cancelled), CourierOrderAction.none);
      expect(courierNextAction(OrderStatus.refunded), CourierOrderAction.none);
    });
  });

  group('codAmountToCollect', () {
    test('unpaid COD order collects the full total', () {
      expect(
        codAmountToCollect(_order(status: OrderStatus.shipped, total: 750)),
        750,
      );
    });

    test('prepaid card order collects nothing', () {
      expect(
        codAmountToCollect(_order(
          status: OrderStatus.shipped,
          payment: PaymentMethod.cibCard,
          isPaid: true,
        )),
        0,
      );
    });

    test('COD already marked paid collects nothing', () {
      expect(
        codAmountToCollect(_order(status: OrderStatus.shipped, isPaid: true)),
        0,
      );
    });
  });

  group('holdsCollectedCash', () {
    test('only delivered COD orders hold cash', () {
      expect(holdsCollectedCash(_order(status: OrderStatus.delivered)), true);
      expect(holdsCollectedCash(_order(status: OrderStatus.shipped)), false);
      expect(
        holdsCollectedCash(_order(
          status: OrderStatus.delivered,
          payment: PaymentMethod.cibCard,
          isPaid: true,
        )),
        false,
      );
    });
  });
}
