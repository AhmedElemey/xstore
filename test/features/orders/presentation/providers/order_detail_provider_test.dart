// Covers OrderDetailNotifier's CONSUMER-role actions. Unlike the vendor
// detail notifier, this one does NOT delegate to OrdersNotifier — it calls
// the usecases directly with its own optimistic-update/rollback, then
// (on success) ref.invalidate(ordersNotifierProvider). That invalidate has
// the same "does not auto-refetch" behavior already found and locked in on
// the vendor side (vendor_order_detail_provider_test.dart) — verified here
// too, since it's the same non-autoDispose keepAlive list provider.
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:xstore/core/analytics/analytics_service.dart';
import 'package:xstore/core/error/failures.dart';
import 'package:xstore/core/mock/mock_users.dart';
import 'package:xstore/features/auth/presentation/providers/auth_provider.dart';
import 'package:xstore/features/orders/domain/entities/order_entity.dart';
import 'package:xstore/features/orders/presentation/providers/order_detail_provider.dart';
import 'package:xstore/features/orders/presentation/providers/orders_dependencies.dart';
import 'package:xstore/features/orders/presentation/providers/orders_provider.dart';

import '../../../../helpers/fake_async_auth_notifier.dart';
import '../../../../helpers/stub_orders_repository.dart';

const _orderId = 'order_1';

OrderEntity _order({OrderStatus status = OrderStatus.pending}) => OrderEntity(
      id: _orderId,
      consumerId: mockConsumerUser.id,
      consumerName: 'Jane',
      consumerPhone: '0100',
      vendorId: 'vendor_1',
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
      createdAt: DateTime(2026, 8, 1),
      updatedAt: DateTime(2026, 8, 1),
    );

Future<ProviderContainer> _containerFor(StubOrdersRepository repo) async {
  final container = ProviderContainer(
    overrides: [
      authProvider.overrideWith(() => FakeAuth(mockConsumerUser)),
      ordersRepositoryProvider.overrideWithValue(repo),
    ],
  );
  addTearDown(container.dispose);
  container.listen(orderDetailNotifierProvider(_orderId), (_, __) {});
  // authProvider must be resolved before any notifier method runs — see the
  // matching lesson/comment in orders_provider_test.dart.
  await container.read(authProvider.future);
  await container.read(analyticsServiceProvider).ready;
  return container;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('OrderDetailNotifier.fetchOrder (consumer)', () {
    test('populates state.order on success', () async {
      final container = await _containerFor(
        StubOrdersRepository(
          getOrderDetailResult: ({
            required orderId,
            required consumerId,
            required vendorId,
            required isVendorSession,
          }) =>
              Right(_order()),
        ),
      );
      final notifier = container.read(orderDetailNotifierProvider(_orderId).notifier);

      await notifier.fetchOrder();

      final state = container.read(orderDetailNotifierProvider(_orderId));
      expect(state.order?.id, _orderId);
      expect(state.isLoading, isFalse);
      expect(state.error, isNull);
    });

    test('sets error and leaves order null on failure', () async {
      final container = await _containerFor(
        StubOrdersRepository(
          getOrderDetailResult: ({
            required orderId,
            required consumerId,
            required vendorId,
            required isVendorSession,
          }) =>
              Left(Failure.network('offline')),
        ),
      );
      final notifier = container.read(orderDetailNotifierProvider(_orderId).notifier);

      await notifier.fetchOrder();

      final state = container.read(orderDetailNotifierProvider(_orderId));
      expect(state.order, isNull);
      expect(state.error, isNotNull);
    });
  });

  group('OrderDetailNotifier.cancelOrder (consumer)', () {
    test('updates the order on success and invalidates the list without refetching it',
        () async {
      final container = await _containerFor(
        StubOrdersRepository(
          getOrderDetailResult: ({
            required orderId,
            required consumerId,
            required vendorId,
            required isVendorSession,
          }) =>
              Right(_order()),
          cancelOrderResult: (orderId, reason, isVendorSession) => Right(
            _order().copyWith(status: OrderStatus.cancelled, cancelReason: reason),
          ),
        ),
      );
      final notifier = container.read(orderDetailNotifierProvider(_orderId).notifier);
      await notifier.fetchOrder();

      await notifier.cancelOrder('Changed my mind');

      expect(
        container.read(orderDetailNotifierProvider(_orderId)).order?.status,
        OrderStatus.cancelled,
      );
      // Same real behavior found on the vendor side: invalidate resets the
      // keepAlive list notifier to its empty initial state rather than
      // refetching it.
      expect(
        container.read(ordersNotifierProvider).orders,
        isEmpty,
        reason: 'ref.invalidate(ordersNotifierProvider) does not refetch by itself',
      );
    });

    test('rolls back to the previous order and sets error on failure', () async {
      final original = _order();
      final container = await _containerFor(
        StubOrdersRepository(
          getOrderDetailResult: ({
            required orderId,
            required consumerId,
            required vendorId,
            required isVendorSession,
          }) =>
              Right(original),
        ),
      );
      final notifier = container.read(orderDetailNotifierProvider(_orderId).notifier);
      await notifier.fetchOrder();

      // cancelOrderUseCaseProvider has no override here, so StubOrdersRepository's
      // default cancelOrder (always Left) exercises the rollback path.
      await notifier.cancelOrder('Changed my mind');

      final state = container.read(orderDetailNotifierProvider(_orderId));
      expect(state.order?.status, OrderStatus.pending);
      expect(state.error, isNotNull);
      expect(state.isActioning, isFalse);
    });
  });

  group('OrderDetailNotifier.confirmReceipt (consumer)', () {
    test('delegates to markDelivered and updates the order on success', () async {
      final shipped = _order(status: OrderStatus.shipped);
      final container = await _containerFor(
        StubOrdersRepository(
          getOrderDetailResult: ({
            required orderId,
            required consumerId,
            required vendorId,
            required isVendorSession,
          }) =>
              Right(shipped),
          markDeliveredResult: (orderId) =>
              Right(shipped.copyWith(status: OrderStatus.delivered)),
        ),
      );
      final notifier = container.read(orderDetailNotifierProvider(_orderId).notifier);
      await notifier.fetchOrder();

      await notifier.confirmReceipt();

      final state = container.read(orderDetailNotifierProvider(_orderId));
      expect(state.order?.status, OrderStatus.delivered);
      expect(state.error, isNull);
    });

    test('rolls back to shipped and sets error on failure', () async {
      final shipped = _order(status: OrderStatus.shipped);
      final container = await _containerFor(
        StubOrdersRepository(
          getOrderDetailResult: ({
            required orderId,
            required consumerId,
            required vendorId,
            required isVendorSession,
          }) =>
              Right(shipped),
          markDeliveredResult: (orderId) => Left(Failure.server('down')),
        ),
      );
      final notifier = container.read(orderDetailNotifierProvider(_orderId).notifier);
      await notifier.fetchOrder();

      await notifier.confirmReceipt();

      final state = container.read(orderDetailNotifierProvider(_orderId));
      expect(state.order?.status, OrderStatus.shipped);
      expect(state.error, isNotNull);
    });
  });

  group('OrderDetailNotifier.clearError', () {
    test('resets error without touching the loaded order', () async {
      final container = await _containerFor(
        StubOrdersRepository(
          getOrderDetailResult: ({
            required orderId,
            required consumerId,
            required vendorId,
            required isVendorSession,
          }) =>
              Right(_order()),
        ),
      );
      final notifier = container.read(orderDetailNotifierProvider(_orderId).notifier);
      await notifier.fetchOrder();
      final before = container.read(orderDetailNotifierProvider(_orderId)).order;

      notifier.clearError();

      final after = container.read(orderDetailNotifierProvider(_orderId));
      expect(after.error, isNull);
      expect(after.order, before);
    });
  });
}
