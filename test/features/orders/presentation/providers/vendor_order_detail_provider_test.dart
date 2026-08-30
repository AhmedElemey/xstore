// Covers VendorOrderDetailNotifier — no dedicated test existed before this
// file. This notifier delegates every mutation to VendorOrdersNotifier
// (vendorOrdersProvider.notifier) rather than reimplementing the usecases,
// then does `ref.invalidate(vendorOrdersProvider)` + refetches its own
// order. That invalidate turned out NOT to auto-refetch the list (see the
// "does not refetch" test below) — a real behavior worth locking in, not an
// assumption to test around.
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
import 'package:xstore/features/orders/presentation/providers/vendor_order_detail_provider.dart';
import 'package:xstore/features/orders/presentation/providers/vendor_orders_provider.dart';

import '../../../../helpers/fake_async_auth_notifier.dart';
import '../../../../helpers/stub_orders_repository.dart';

const _orderId = 'order_1';

OrderEntity _order({
  OrderStatus status = OrderStatus.pending,
}) =>
    OrderEntity(
      id: _orderId,
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
      createdAt: DateTime(2026, 8, 1),
      updatedAt: DateTime(2026, 8, 1),
    );

/// Builds a container backed by a mutable `backendOrder` that plays the role
/// of the server's own row for [_orderId] — getOrderDetail always reads it,
/// independent of whatever the (separately invalidatable) vendorOrdersProvider
/// list currently holds, exactly like a real getOrderDetail endpoint would
/// not care about a client-side list cache being cleared.
Future<ProviderContainer> _syncedContainer({
  Either<Failure, OrderEntity> Function(String orderId, DeliveryMethod method)?
      confirm,
  Either<Failure, OrderEntity> Function(String orderId, String reason)? reject,
  Either<Failure, OrderEntity> Function(String orderId)? markProcessing,
  Either<Failure, OrderEntity> Function(String orderId, ShippingInfo info)?
      markShipped,
}) async {
  var backendOrder = _order();
  void adopt(Either<Failure, OrderEntity> result) =>
      result.fold((_) {}, (order) => backendOrder = order);

  final repo = StubOrdersRepository(
    getVendorOrdersResult: ({
      required vendorId,
      required page,
      required pageSize,
    }) =>
        Right([backendOrder]),
    confirmOrderResult: confirm == null
        ? null
        : (orderId, method) {
            final result = confirm(orderId, method);
            adopt(result);
            return result;
          },
    rejectOrderResult: reject == null
        ? null
        : (orderId, reason) {
            final result = reject(orderId, reason);
            adopt(result);
            return result;
          },
    markProcessingResult: markProcessing == null
        ? null
        : (orderId) {
            final result = markProcessing(orderId);
            adopt(result);
            return result;
          },
    markShippedResult: markShipped == null
        ? null
        : (orderId, info) {
            final result = markShipped(orderId, info);
            adopt(result);
            return result;
          },
    getOrderDetailResult: ({
      required orderId,
      required consumerId,
      required vendorId,
      required isVendorSession,
    }) =>
        orderId == backendOrder.id
            ? Right(backendOrder)
            : Left(Failure.server('not found')),
  );
  final container = ProviderContainer(
    overrides: [
      authProvider.overrideWith(() => FakeAuth(mockVendorUser)),
      ordersRepositoryProvider.overrideWithValue(repo),
    ],
  );
  addTearDown(container.dispose);
  // autoDispose family + a plain analytics-touching sibling provider: hold
  // both open across the awaits below (2026-08-29 lesson). Reading the list
  // notifier's own constructor also warms up authProvider's first read,
  // avoiding the "lazy async provider reads as Loading" trap on the very
  // first ref.read(authProvider) elsewhere.
  container.listen(vendorOrderDetailProvider(_orderId), (_, __) {});
  container.listen(vendorOrdersProvider, (_, __) {});
  await container.read(analyticsServiceProvider).ready;
  await container.read(vendorOrdersProvider.notifier).fetchOrders();
  return container;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('VendorOrderDetailNotifier.fetchOrder', () {
    test('populates state.order on success', () async {
      final container = await _syncedContainer();
      final notifier = container.read(vendorOrderDetailProvider(_orderId).notifier);

      await notifier.fetchOrder();

      final state = container.read(vendorOrderDetailProvider(_orderId));
      expect(state.order?.id, _orderId);
      expect(state.isLoading, isFalse);
      expect(state.error, isNull);
    });

    test('sets state.error and leaves order null on failure', () async {
      final container = ProviderContainer(
        overrides: [
          authProvider.overrideWith(() => FakeAuth(mockVendorUser)),
          ordersRepositoryProvider.overrideWithValue(
            StubOrdersRepository(
              getOrderDetailResult: ({
                required orderId,
                required consumerId,
                required vendorId,
                required isVendorSession,
              }) =>
                  Left(Failure.network('offline')),
            ),
          ),
        ],
      );
      addTearDown(container.dispose);
      container.listen(vendorOrderDetailProvider(_orderId), (_, __) {});
      await container.read(analyticsServiceProvider).ready;
      // authProvider's very first ref.read in fetchOrder() would otherwise
      // see AsyncLoading (valueOrNull null) and short-circuit before ever
      // reaching the repository — warm it up first.
      await container.read(authProvider.future);
      final notifier = container.read(vendorOrderDetailProvider(_orderId).notifier);

      await notifier.fetchOrder();

      final state = container.read(vendorOrderDetailProvider(_orderId));
      expect(state.order, isNull);
      expect(state.error, isNotNull);
    });
  });

  group('VendorOrderDetailNotifier mutations delegate to VendorOrdersNotifier', () {
    test('confirmOrder updates the detail order but does NOT auto-refresh the list',
        () async {
      final container = await _syncedContainer(
        confirm: (orderId, method) => Right(
          _order().copyWith(status: OrderStatus.confirmed, deliveryMethod: method),
        ),
      );
      final notifier = container.read(vendorOrderDetailProvider(_orderId).notifier);
      await notifier.fetchOrder();
      expect(
        container.read(vendorOrderDetailProvider(_orderId)).order?.status,
        OrderStatus.pending,
      );

      final ok = await notifier.confirmOrder(DeliveryMethod.self);

      expect(ok, isTrue);
      // The detail notifier's own state was refetched and shows the update.
      expect(
        container.read(vendorOrderDetailProvider(_orderId)).order?.status,
        OrderStatus.confirmed,
      );
      // ref.invalidate(vendorOrdersProvider) resets it to VendorOrdersNotifier's
      // initial (empty) state — it does NOT trigger a refetch by itself. In
      // production the list only becomes fresh again via
      // VendorOrdersScreen.initState() calling fetchOrders(), which only runs
      // if that screen is actually remounted (not just popped back to). A
      // provider-level read right after invalidate sees an empty list.
      expect(
        container.read(vendorOrdersProvider).orders,
        isEmpty,
        reason: 'invalidate alone does not refetch — this is the real, verified behavior',
      );

      // The recovery path: an explicit fetchOrders() call (what the list
      // screen does on remount) picks up the same confirmed order.
      await container.read(vendorOrdersProvider.notifier).fetchOrders();
      expect(
        container.read(vendorOrdersProvider).orders.single.status,
        OrderStatus.confirmed,
      );
    });

    test('rejectOrder failure leaves both the list and the detail order untouched',
        () async {
      final container = await _syncedContainer(
        reject: (orderId, reason) => Left(Failure.server('backend rejected')),
      );
      final notifier = container.read(vendorOrderDetailProvider(_orderId).notifier);
      await notifier.fetchOrder();

      final ok = await notifier.rejectOrder('Out of stock');

      expect(ok, isFalse);
      expect(
        container.read(vendorOrdersProvider).orders.single.status,
        OrderStatus.pending,
        reason: 'list notifier already rolls back its own optimistic update',
      );
      expect(
        container.read(vendorOrderDetailProvider(_orderId)).order?.status,
        OrderStatus.pending,
        reason: 'detail must not invalidate/refetch on a failed mutation',
      );
    });

    test('markProcessing then markShipped keep the detail order in sync step by step',
        () async {
      final container = await _syncedContainer(
        markProcessing: (orderId) => Right(_order(status: OrderStatus.processing)),
        markShipped: (orderId, info) => Right(
          _order(status: OrderStatus.shipped)
              .copyWith(trackingNumber: info.trackingNumber),
        ),
      );
      final detailNotifier =
          container.read(vendorOrderDetailProvider(_orderId).notifier);

      final processedOk = await detailNotifier.markProcessing();
      expect(processedOk, isTrue);
      expect(
        container.read(vendorOrderDetailProvider(_orderId)).order?.status,
        OrderStatus.processing,
      );

      final shippedOk = await detailNotifier.markShipped(
        const ShippingInfo(trackingNumber: 'XS-9'),
      );
      expect(shippedOk, isTrue);
      final detailState = container.read(vendorOrderDetailProvider(_orderId));
      expect(detailState.order?.status, OrderStatus.shipped);
      expect(detailState.order?.trackingNumber, 'XS-9');

      // Each successful action invalidated the list again; explicitly
      // refetching (as the list screen would on remount) shows both
      // transitions landed on the same underlying "backend" row.
      await container.read(vendorOrdersProvider.notifier).fetchOrders();
      final listOrder = container.read(vendorOrdersProvider).orders.single;
      expect(listOrder.status, OrderStatus.shipped);
      expect(listOrder.trackingNumber, 'XS-9');
    });
  });

  group('VendorOrderDetailNotifier.clearError', () {
    test('resets error without touching the loaded order', () async {
      final container = await _syncedContainer();
      final notifier = container.read(vendorOrderDetailProvider(_orderId).notifier);
      await notifier.fetchOrder();

      final before = container.read(vendorOrderDetailProvider(_orderId)).order;
      notifier.clearError();

      final after = container.read(vendorOrderDetailProvider(_orderId));
      expect(after.error, isNull);
      expect(after.order, before);
    });
  });
}
