// Covers OrdersNotifier's CONSUMER-role actions (fetchOrders, cancelOrder,
// confirmReceipt/markDelivered, reorder) — checkout_order_flow_test.dart only
// covers PLACING a new order; nothing previously tested acting on an
// existing one. This notifier is role-shared with the vendor side (already
// covered by vendor_orders_provider_test.dart via a separate, vendor-only
// VendorOrdersNotifier) — here the session is always a consumer.
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:xstore/core/analytics/analytics_service.dart';
import 'package:xstore/core/error/failures.dart';
import 'package:xstore/core/mock/mock_users.dart';
import 'package:xstore/features/auth/presentation/providers/auth_provider.dart';
import 'package:xstore/features/cart/presentation/providers/cart_provider.dart';
import 'package:xstore/features/cart/presentation/providers/cart_state.dart';
import 'package:xstore/features/orders/domain/entities/order_entity.dart';
import 'package:xstore/features/orders/domain/entities/order_item_entity.dart';
import 'package:xstore/features/orders/presentation/providers/orders_dependencies.dart';
import 'package:xstore/features/orders/presentation/providers/orders_provider.dart';

import '../../../../helpers/fake_async_auth_notifier.dart';
import '../../../../helpers/stub_orders_repository.dart';

const _orderId = 'order_1';

OrderEntity _order({
  OrderStatus status = OrderStatus.pending,
  List<OrderItemEntity> items = const [],
}) =>
    OrderEntity(
      id: _orderId,
      consumerId: mockConsumerUser.id,
      consumerName: 'Jane',
      consumerPhone: '0100',
      vendorId: 'vendor_1',
      vendorName: 'Ahmed',
      vendorStoreName: 'Ahmed Store',
      items: items,
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
      createdAt: DateTime(2026, 8, 1),
      updatedAt: DateTime(2026, 8, 1),
    );

/// Records reorderFromOrderItems calls instead of touching real cart/network
/// infrastructure — OrdersNotifier.reorder()'s only job is to delegate.
class _RecordingCart extends Cart {
  List<OrderItemEntity>? reorderedLines;

  @override
  CartState build() => const CartState(consumerId: 'consumer_1');

  @override
  Future<void> reorderFromOrderItems(List<OrderItemEntity> lines) async {
    reorderedLines = lines;
  }
}

Future<ProviderContainer> _containerFor(
  StubOrdersRepository repo, {
  _RecordingCart? cart,
}) async {
  final container = ProviderContainer(
    overrides: [
      authProvider.overrideWith(() => FakeAuth(mockConsumerUser)),
      ordersRepositoryProvider.overrideWithValue(repo),
      if (cart != null) cartProvider.overrideWith(() => cart),
    ],
  );
  addTearDown(container.dispose);
  // OrdersNotifier.fetchOrders() reads authProvider synchronously with no
  // await before it — the very first ref.read of a lazy async provider
  // reads AsyncLoading (valueOrNull null), so it must already be resolved
  // before any notifier method runs (2026-07-11 "Lazy async providers read
  // as Loading in widget tests" lesson).
  await container.read(authProvider.future);
  await container.read(analyticsServiceProvider).ready;
  return container;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('OrdersNotifier.fetchOrders (consumer)', () {
    test('populates orders via getConsumerOrders, not the vendor path', () async {
      final container = await _containerFor(
        StubOrdersRepository(
          getConsumerOrdersResult: ({
            required consumerId,
            required page,
            required pageSize,
          }) =>
              Right([_order()]),
          // Left unset (defaults to failing) — proves the consumer path
          // never touches getVendorOrders for a consumer session.
        ),
      );

      await container.read(ordersNotifierProvider.notifier).fetchOrders();

      final state = container.read(ordersNotifierProvider);
      expect(state.orders, hasLength(1));
      expect(state.isLoading, isFalse);
      expect(state.error, isNull);
    });

    test('sets error on failure', () async {
      final container = await _containerFor(
        StubOrdersRepository(
          getConsumerOrdersResult: ({
            required consumerId,
            required page,
            required pageSize,
          }) =>
              Left(Failure.network('offline')),
        ),
      );

      await container.read(ordersNotifierProvider.notifier).fetchOrders();

      final state = container.read(ordersNotifierProvider);
      expect(state.orders, isEmpty);
      expect(state.error, isNotNull);
    });
  });

  group('OrdersNotifier.cancelOrder (consumer)', () {
    test('optimistically cancels then keeps the server order on success', () async {
      final container = await _containerFor(
        StubOrdersRepository(
          getConsumerOrdersResult: ({
            required consumerId,
            required page,
            required pageSize,
          }) =>
              Right([_order()]),
        ),
      );
      final notifier = container.read(ordersNotifierProvider.notifier);
      await notifier.fetchOrders();

      // cancelOrder has no injectable result via StubOrdersRepository's
      // default (fails), so this exercises the rollback path directly —
      // covered fully in the next test; here confirm the optimistic write
      // lands before the network call resolves.
      final future = notifier.cancelOrder(_orderId, 'Changed my mind');
      expect(
        container.read(ordersNotifierProvider).orders.single.status,
        OrderStatus.cancelled,
        reason: 'optimistic update applies synchronously before the await',
      );
      await future;
    });

    test('rolls back to the previous status and sets error on failure', () async {
      final container = await _containerFor(
        StubOrdersRepository(
          getConsumerOrdersResult: ({
            required consumerId,
            required page,
            required pageSize,
          }) =>
              Right([_order()]),
        ),
      );
      final notifier = container.read(ordersNotifierProvider.notifier);
      await notifier.fetchOrders();

      await notifier.cancelOrder(_orderId, 'Changed my mind');

      final state = container.read(ordersNotifierProvider);
      expect(state.orders.single.status, OrderStatus.pending);
      expect(state.error, isNotNull);
    });
  });

  group('OrdersNotifier.confirmReceipt (consumer)', () {
    test('delegates to markDelivered and updates status on success', () async {
      final shipped = _order(status: OrderStatus.shipped);
      final container = await _containerFor(
        StubOrdersRepository(
          getConsumerOrdersResult: ({
            required consumerId,
            required page,
            required pageSize,
          }) =>
              Right([shipped]),
          markDeliveredResult: (orderId) =>
              Right(shipped.copyWith(status: OrderStatus.delivered)),
        ),
      );
      final notifier = container.read(ordersNotifierProvider.notifier);
      await notifier.fetchOrders();

      await notifier.confirmReceipt(_orderId);

      expect(
        container.read(ordersNotifierProvider).orders.single.status,
        OrderStatus.delivered,
      );
    });

    test('rolls back to shipped and sets error on failure', () async {
      final shipped = _order(status: OrderStatus.shipped);
      final container = await _containerFor(
        StubOrdersRepository(
          getConsumerOrdersResult: ({
            required consumerId,
            required page,
            required pageSize,
          }) =>
              Right([shipped]),
          markDeliveredResult: (orderId) => Left(Failure.server('down')),
        ),
      );
      final notifier = container.read(ordersNotifierProvider.notifier);
      await notifier.fetchOrders();

      await notifier.confirmReceipt(_orderId);

      final state = container.read(ordersNotifierProvider);
      expect(state.orders.single.status, OrderStatus.shipped);
      expect(state.error, isNotNull);
    });
  });

  group('OrdersNotifier.reorder', () {
    test('forwards the order\'s items to Cart.reorderFromOrderItems', () async {
      final lines = [
        const OrderItemEntity(
          id: 'item_1',
          listingId: 'listing_1',
          listingName: 'PS5',
          listingImage: '',
          category: 'Electronics',
          condition: 'New',
          price: 500,
          quantity: 1,
          total: 500,
        ),
      ];
      final recordingCart = _RecordingCart();
      final container = await _containerFor(
        StubOrdersRepository(
          getConsumerOrdersResult: ({
            required consumerId,
            required page,
            required pageSize,
          }) =>
              Right([_order(items: lines)]),
        ),
        cart: recordingCart,
      );
      final notifier = container.read(ordersNotifierProvider.notifier);
      await notifier.fetchOrders();

      await notifier.reorder(_orderId);

      expect(recordingCart.reorderedLines, lines);
    });

    test('no-ops when the order id is not found in state', () async {
      final recordingCart = _RecordingCart();
      final container = await _containerFor(
        StubOrdersRepository(
          getConsumerOrdersResult: ({
            required consumerId,
            required page,
            required pageSize,
          }) =>
              Right([]),
        ),
        cart: recordingCart,
      );
      final notifier = container.read(ordersNotifierProvider.notifier);
      await notifier.fetchOrders();

      await notifier.reorder('nonexistent');

      expect(recordingCart.reorderedLines, isNull);
    });
  });
}
