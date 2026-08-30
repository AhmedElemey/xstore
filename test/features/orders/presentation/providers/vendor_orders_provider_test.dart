// Covers the vendor order-action lifecycle (confirm/reject/markProcessing/
// markShipped) driven through VendorOrdersNotifier — the optimistic-update +
// rollback-on-failure behavior had no dedicated test before this file (only
// list-rendering/dispose coverage existed for VendorOrdersScreen).
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:xstore/core/analytics/analytics_service.dart';
import 'package:xstore/core/error/failures.dart';
import 'package:xstore/core/mock/mock_users.dart';
import 'package:xstore/features/auth/presentation/providers/auth_provider.dart';
import 'package:xstore/features/orders/domain/entities/order_entity.dart';
import 'package:xstore/features/orders/presentation/providers/orders_dependencies.dart';
import 'package:xstore/features/orders/presentation/providers/vendor_orders_provider.dart';

import '../../../../helpers/fake_async_auth_notifier.dart';
import '../../../../helpers/stub_orders_repository.dart';

OrderEntity _order({
  required String id,
  OrderStatus status = OrderStatus.pending,
  DateTime? createdAt,
}) =>
    OrderEntity(
      id: id,
      consumerId: 'consumer_1',
      consumerName: 'Jane',
      consumerPhone: '0100',
      vendorId: mockVendorUser.id,
      vendorName: 'Ahmed',
      vendorStoreName: 'Ahmed Store',
      items: const [],
      status: status,
      paymentMethod: PaymentMethod.cashOnDelivery,
      deliveryAddress: const OrderAddress(
        fullName: 'Jane',
        phone: '0100',
        street: 'St',
        city: 'Cairo',
        wilaya: 'Cairo',
      ),
      subtotal: 500,
      shippingCost: 0,
      discount: 0,
      total: 500,
      createdAt: createdAt ?? DateTime(2026, 8, 1),
      updatedAt: createdAt ?? DateTime(2026, 8, 1),
    );

/// Waits for [AnalyticsService]'s async init to finish registering its own
/// internal listener before the test can dispose the container — see
/// checkout_order_flow_test.dart's `_buildContainer` for the same guard.
Future<ProviderContainer> _containerWith(StubOrdersRepository repo) async {
  final container = ProviderContainer(
    overrides: [
      authProvider.overrideWith(() => FakeAuth(mockVendorUser)),
      ordersRepositoryProvider.overrideWithValue(repo),
    ],
  );
  addTearDown(container.dispose);
  container.listen(vendorOrdersProvider, (_, __) {});
  await container.read(analyticsServiceProvider).ready;
  return container;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('VendorOrdersNotifier.confirmOrder', () {
    test('optimistically confirms then merges the server order on success', () async {
      final pending = _order(id: 'order_1');
      final confirmed = pending.copyWith(
        status: OrderStatus.confirmed,
        deliveryMethod: DeliveryMethod.self,
      );
      final container = await _containerWith(
        StubOrdersRepository(
          getVendorOrdersResult: ({
            required vendorId,
            required page,
            required pageSize,
          }) =>
              Right([pending]),
          confirmOrderResult: (orderId, method) => Right(confirmed),
        ),
      );
      final notifier = container.read(vendorOrdersProvider.notifier);
      await notifier.fetchOrders();

      final ok = await notifier.confirmOrder('order_1', DeliveryMethod.self);

      expect(ok, isTrue);
      final order = container.read(vendorOrdersProvider).orders.single;
      expect(order.status, OrderStatus.confirmed);
      expect(order.deliveryMethod, DeliveryMethod.self);
      expect(container.read(vendorOrdersProvider).error, isNull);
    });

    test('rolls back the optimistic status and surfaces an error on failure', () async {
      final pending = _order(id: 'order_1');
      final container = await _containerWith(
        StubOrdersRepository(
          getVendorOrdersResult: ({
            required vendorId,
            required page,
            required pageSize,
          }) =>
              Right([pending]),
          confirmOrderResult: (orderId, method) =>
              Left(Failure.server('backend rejected confirm')),
        ),
      );
      final notifier = container.read(vendorOrdersProvider.notifier);
      await notifier.fetchOrders();

      final ok = await notifier.confirmOrder('order_1', DeliveryMethod.self);

      expect(ok, isFalse);
      final order = container.read(vendorOrdersProvider).orders.single;
      expect(order.status, OrderStatus.pending, reason: 'must roll back to pending');
      expect(container.read(vendorOrdersProvider).error, isNotNull);
    });
  });

  group('VendorOrdersNotifier.confirmAllPending', () {
    test('confirms every pending order and counts only the successes', () async {
      final orders = [
        _order(id: 'order_1'),
        _order(id: 'order_2'),
        _order(id: 'order_3', status: OrderStatus.confirmed),
      ];
      final container = await _containerWith(
        StubOrdersRepository(
          getVendorOrdersResult: ({
            required vendorId,
            required page,
            required pageSize,
          }) =>
              Right(orders),
          confirmOrderResult: (orderId, method) => orderId == 'order_2'
              ? Left(Failure.server('order_2 failed'))
              : Right(
                  orders
                      .firstWhere((o) => o.id == orderId)
                      .copyWith(status: OrderStatus.confirmed, deliveryMethod: method),
                ),
        ),
      );
      final notifier = container.read(vendorOrdersProvider.notifier);
      await notifier.fetchOrders();

      final okCount = await notifier.confirmAllPending(DeliveryMethod.platform);

      expect(okCount, 1, reason: 'only order_1 was pending and succeeded');
      final byId = {
        for (final o in container.read(vendorOrdersProvider).orders) o.id: o.status,
      };
      expect(byId['order_1'], OrderStatus.confirmed);
      expect(byId['order_2'], OrderStatus.pending, reason: 'rolled back after failure');
      expect(byId['order_3'], OrderStatus.confirmed, reason: 'was never pending');
    });
  });

  group('VendorOrdersNotifier.rejectOrder', () {
    test('marks the order cancelled with the reason on success', () async {
      final pending = _order(id: 'order_1');
      final rejected = pending.copyWith(
        status: OrderStatus.cancelled,
        cancelReason: 'Out of stock',
        cancelledAt: DateTime(2026, 8, 2),
      );
      final container = await _containerWith(
        StubOrdersRepository(
          getVendorOrdersResult: ({
            required vendorId,
            required page,
            required pageSize,
          }) =>
              Right([pending]),
          rejectOrderResult: (orderId, reason) => Right(rejected),
        ),
      );
      final notifier = container.read(vendorOrdersProvider.notifier);
      await notifier.fetchOrders();

      final ok = await notifier.rejectOrder('order_1', 'Out of stock');

      expect(ok, isTrue);
      final order = container.read(vendorOrdersProvider).orders.single;
      expect(order.status, OrderStatus.cancelled);
      expect(order.cancelReason, 'Out of stock');
    });

    test('rolls back to pending and keeps the reason unset on failure', () async {
      final pending = _order(id: 'order_1');
      final container = await _containerWith(
        StubOrdersRepository(
          getVendorOrdersResult: ({
            required vendorId,
            required page,
            required pageSize,
          }) =>
              Right([pending]),
          rejectOrderResult: (orderId, reason) =>
              Left(Failure.network('offline')),
        ),
      );
      final notifier = container.read(vendorOrdersProvider.notifier);
      await notifier.fetchOrders();

      final ok = await notifier.rejectOrder('order_1', 'Out of stock');

      expect(ok, isFalse);
      final order = container.read(vendorOrdersProvider).orders.single;
      expect(order.status, OrderStatus.pending);
      expect(order.cancelReason, isNull);
    });
  });

  group('VendorOrdersNotifier.markProcessing / markShipped', () {
    test('advances confirmed -> processing -> shipped with tracking info', () async {
      final confirmed = _order(id: 'order_1', status: OrderStatus.confirmed);
      final processing = confirmed.copyWith(status: OrderStatus.processing);
      final shipped = processing.copyWith(
        status: OrderStatus.shipped,
        trackingNumber: 'XS-123',
        courierName: 'Aramex',
      );
      final container = await _containerWith(
        StubOrdersRepository(
          getVendorOrdersResult: ({
            required vendorId,
            required page,
            required pageSize,
          }) =>
              Right([confirmed]),
          markProcessingResult: (orderId) => Right(processing),
          markShippedResult: (orderId, info) => Right(shipped),
        ),
      );
      final notifier = container.read(vendorOrdersProvider.notifier);
      await notifier.fetchOrders();

      final processedOk = await notifier.markProcessing('order_1');
      expect(processedOk, isTrue);
      expect(
        container.read(vendorOrdersProvider).orders.single.status,
        OrderStatus.processing,
      );

      final shippedOk = await notifier.markShipped(
        'order_1',
        const ShippingInfo(trackingNumber: 'XS-123', courierName: 'Aramex'),
      );
      expect(shippedOk, isTrue);
      final order = container.read(vendorOrdersProvider).orders.single;
      expect(order.status, OrderStatus.shipped);
      expect(order.trackingNumber, 'XS-123');
      expect(order.courierName, 'Aramex');
    });

    test('markShipped rolls back on failure but keeps the fallback tracking number '
        'from the optimistic update only until rollback', () async {
      final confirmed = _order(id: 'order_1', status: OrderStatus.confirmed);
      final container = await _containerWith(
        StubOrdersRepository(
          getVendorOrdersResult: ({
            required vendorId,
            required page,
            required pageSize,
          }) =>
              Right([confirmed]),
          markShippedResult: (orderId, info) =>
              Left(Failure.server('ship failed')),
        ),
      );
      final notifier = container.read(vendorOrdersProvider.notifier);
      await notifier.fetchOrders();

      final ok = await notifier.markShipped('order_1', const ShippingInfo());

      expect(ok, isFalse);
      final order = container.read(vendorOrdersProvider).orders.single;
      expect(order.status, OrderStatus.confirmed, reason: 'must roll back to confirmed');
      expect(order.trackingNumber, isNull);
    });
  });

  group('VendorOrdersNotifier filtering after a status change', () {
    test('applyFilter(pending) drops an order once it is confirmed', () async {
      final pending1 = _order(id: 'order_1');
      final pending2 = _order(id: 'order_2');
      final container = await _containerWith(
        StubOrdersRepository(
          getVendorOrdersResult: ({
            required vendorId,
            required page,
            required pageSize,
          }) =>
              Right([pending1, pending2]),
          confirmOrderResult: (orderId, method) => Right(
            pending1.copyWith(status: OrderStatus.confirmed),
          ),
        ),
      );
      final notifier = container.read(vendorOrdersProvider.notifier);
      await notifier.fetchOrders();
      notifier.applyFilter(OrderStatus.pending);
      expect(container.read(vendorOrdersProvider).filteredOrders, hasLength(2));

      await notifier.confirmOrder('order_1', DeliveryMethod.self);

      expect(container.read(vendorOrdersProvider).filteredOrders, hasLength(1));
      expect(
        container.read(vendorOrdersProvider).filteredOrders.single.id,
        'order_2',
      );
      expect(container.read(vendorOrdersProvider).pendingCount, 1);
    });
  });
}
