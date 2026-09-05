// Full order lifecycle across BOTH roles: client (consumer) and vendor.
//
// The app's Orders feature is role-shared: `OrdersNotifier`
// (orders_provider.dart) drives the consumer's "My Orders" screen AND the
// vendor's "Incoming Orders" screen — it branches on `authProvider`'s
// current role, not on a separate notifier per role (see the
// flutter-review skill's 2026-08-06 "two independent provider stacks"
// lesson: this repo also has a second, vendor-only stack in
// vendor_orders_provider.dart / vendor_order_detail_provider.dart, which
// this test does not exercise — it targets the shared one that OrderCard
// and OrdersScreen actually render for both roles).
//
// This test drives the SAME production `OrdersNotifier` from two separate
// `ProviderContainer`s — one authenticated as the consumer who placed the
// order, one as the vendor who fulfils it — both pointed at one shared
// in-memory `OrdersRepository` fake that stores a single canonical order.
// That mirrors how a real backend behaves (one order row, two
// role-scoped views of it) far more faithfully than the app's built-in
// mock fixtures, whose consumer (`mock_orders.dart`) and vendor
// (`OrdersRemoteDataSourceImpl._seedVendorOrders`) seed lists are
// disjoint — a newly placed mock order never appears in the vendor's
// incoming-orders list (see `registerPlacedConsumerOrder`'s doc comment).
//
// Only the repository boundary is faked; every notifier, use case, and
// state-transition/optimistic-update rule in between is the real
// production code. Run with: flutter test test/order_lifecycle_full_app_test.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:xstore/core/analytics/analytics_service.dart';
import 'package:xstore/core/error/failures.dart';
import 'package:xstore/features/auth/domain/entities/user_entity.dart';
import 'package:xstore/features/auth/presentation/providers/auth_provider.dart';
import 'package:xstore/features/orders/domain/entities/order_entity.dart';
import 'package:xstore/features/orders/domain/entities/order_item_entity.dart';
import 'package:xstore/features/orders/domain/repositories/orders_repository.dart';
import 'package:xstore/features/orders/presentation/providers/orders_dependencies.dart';
import 'package:xstore/features/orders/presentation/providers/orders_provider.dart';

import 'helpers/fake_async_auth_notifier.dart';

/// One mutable order, shared by both role-scoped `ProviderContainer`s below —
/// stands in for a real backend's single source of truth for an order row.
class _SharedOrdersRepository implements OrdersRepository {
  _SharedOrdersRepository(OrderEntity seed) : _orders = [seed];

  final List<OrderEntity> _orders;

  OrderEntity _requireById(String id) =>
      _orders.firstWhere((o) => o.id == id);

  void _replace(OrderEntity next) {
    final idx = _orders.indexWhere((o) => o.id == next.id);
    _orders[idx] = next;
  }

  @override
  Future<Either<Failure, List<OrderEntity>>> getConsumerOrders({
    required String consumerId,
    required int page,
    required int pageSize,
  }) async => Right(_orders.where((o) => o.consumerId == consumerId).toList());

  @override
  Future<Either<Failure, List<OrderEntity>>> getVendorOrders({
    required String vendorId,
    required int page,
    required int pageSize,
  }) async => Right(_orders.where((o) => o.vendorId == vendorId).toList());

  @override
  Future<Either<Failure, List<OrderEntity>>> getCourierOrders({
    required String courierId,
    required int page,
    required int pageSize,
  }) async => Right(_orders.where((o) => o.courierId == courierId).toList());

  @override
  Future<Either<Failure, OrderEntity>> getOrderDetail({
    required String orderId,
    required String? consumerId,
    required String? vendorId,
    required bool isVendorSession,
  }) async {
    final match = _orders.where((o) => o.id == orderId);
    if (match.isEmpty) return Left(Failure.server('order not found'));
    return Right(match.first);
  }

  @override
  Future<Either<Failure, OrderStatsEntity>> getVendorOrderStats({
    required String vendorId,
  }) async {
    final mine = _orders.where((o) => o.vendorId == vendorId).toList();
    return Right(
      OrderStatsEntity(
        pendingCount:
            mine.where((o) => o.status == OrderStatus.pending).length,
        activeCount: mine
            .where(
              (o) =>
                  o.status == OrderStatus.confirmed ||
                  o.status == OrderStatus.processing ||
                  o.status == OrderStatus.shipped,
            )
            .length,
        monthCount: mine.length,
        totalCount: mine.length,
        totalRevenue: mine
            .where((o) => o.status == OrderStatus.delivered)
            .fold<double>(0, (a, b) => a + b.total),
      ),
    );
  }

  @override
  Future<Either<Failure, OrderEntity>> cancelOrder({
    required String orderId,
    required String reason,
    required bool isVendorSession,
  }) async {
    final now = DateTime.now();
    final next = _requireById(orderId).copyWith(
      status: OrderStatus.cancelled,
      cancelReason: reason,
      cancelledAt: now,
      updatedAt: now,
    );
    _replace(next);
    return Right(next);
  }

  @override
  Future<Either<Failure, OrderEntity>> confirmOrder({
    required String orderId,
    required DeliveryMethod method,
    String? vendorId,
  }) async {
    final now = DateTime.now();
    final next = _requireById(orderId).copyWith(
      status: OrderStatus.confirmed,
      deliveryMethod: method,
      confirmedAt: now,
      updatedAt: now,
    );
    _replace(next);
    return Right(next);
  }

  @override
  Future<Either<Failure, OrderEntity>> rejectOrder({
    required String orderId,
    required String reason,
    String? vendorId,
  }) async {
    final now = DateTime.now();
    final next = _requireById(orderId).copyWith(
      status: OrderStatus.cancelled,
      cancelReason: reason,
      cancelledAt: now,
      updatedAt: now,
    );
    _replace(next);
    return Right(next);
  }

  @override
  Future<Either<Failure, OrderEntity>> markProcessing(
    String orderId, {
    String? vendorId,
  }) async {
    final next = _requireById(
      orderId,
    ).copyWith(status: OrderStatus.processing, updatedAt: DateTime.now());
    _replace(next);
    return Right(next);
  }

  @override
  Future<Either<Failure, OrderEntity>> markShipped({
    required String orderId,
    required ShippingInfo shippingInfo,
    String? vendorId,
  }) async {
    final now = DateTime.now();
    final next = _requireById(orderId).copyWith(
      status: OrderStatus.shipped,
      trackingNumber: shippingInfo.trackingNumber,
      courierName: shippingInfo.courierName,
      estimatedDelivery: shippingInfo.estimatedDelivery,
      shippedAt: now,
      updatedAt: now,
    );
    _replace(next);
    return Right(next);
  }

  @override
  Future<Either<Failure, OrderEntity>> markDelivered(String orderId) async {
    final now = DateTime.now();
    final next = _requireById(
      orderId,
    ).copyWith(status: OrderStatus.delivered, deliveredAt: now, updatedAt: now);
    _replace(next);
    return Right(next);
  }

  @override
  Future<Either<Failure, Unit>> updateDeliveryLocation({
    required String orderId,
    required double latitude,
    required double longitude,
  }) async => const Right(unit);

  @override
  Future<Either<Failure, Unit>> registerCheckoutOrder(
    OrderEntity order,
  ) async {
    _orders.add(order);
    return const Right(unit);
  }
}

OrderEntity _seedOrder() => OrderEntity(
  id: 'ORD-100',
  consumerId: 'consumer_1',
  consumerName: 'Test Buyer',
  consumerPhone: '01012345678',
  vendorId: 'vendor_1',
  vendorName: 'Test Vendor',
  vendorStoreName: 'Test Store',
  items: const [
    OrderItemEntity(
      id: 'oi_1',
      listingId: '501',
      listingName: 'Test Listing',
      listingImage: '',
      category: 'Electronics',
      condition: 'New',
      price: 100,
      quantity: 1,
      total: 100,
    ),
  ],
  status: OrderStatus.pending,
  paymentMethod: PaymentMethod.cashOnDelivery,
  deliveryAddress: const OrderAddress(
    fullName: 'Test Buyer',
    phone: '01012345678',
    street: '1 Test Street',
    city: 'Cairo',
    wilaya: 'Cairo',
  ),
  subtotal: 100,
  shippingCost: 0,
  discount: 0,
  total: 100,
  createdAt: DateTime(2026, 1, 1),
  updatedAt: DateTime(2026, 1, 1),
);

UserEntity _consumer() => const UserEntity(
  id: 'consumer_1',
  name: 'Test Buyer',
  email: 'buyer@test.com',
  phoneNumber: '01012345678',
);

UserEntity _vendor() => const UserEntity(
  id: 'vendor_1',
  name: 'Test Vendor',
  email: 'vendor@test.com',
  phoneNumber: '01099999999',
  role: UserRole.vendor,
);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test(
    'full order lifecycle: vendor accepts and ships, client confirms receipt',
    () async {
      final repo = _SharedOrdersRepository(_seedOrder());

      final consumerContainer = ProviderContainer(
        overrides: [
          authProvider.overrideWith(() => FakeAuth(_consumer())),
          ordersRepositoryProvider.overrideWithValue(repo),
        ],
      );
      addTearDown(consumerContainer.dispose);

      final vendorContainer = ProviderContainer(
        overrides: [
          authProvider.overrideWith(() => FakeAuth(_vendor())),
          ordersRepositoryProvider.overrideWithValue(repo),
        ],
      );
      addTearDown(vendorContainer.dispose);

      await consumerContainer.read(authProvider.future);
      await vendorContainer.read(authProvider.future);
      // AnalyticsService._init() is async; every status-change method below
      // reads analyticsServiceProvider, so wait for init to finish before the
      // test (and its addTearDown dispose) can end — otherwise the pending
      // init resumes on an already-disposed container and throws into
      // whichever test happens to run next (see checkout_order_flow_test
      // .dart's `_buildContainer` for the same guard).
      await consumerContainer.read(analyticsServiceProvider).ready;
      await vendorContainer.read(analyticsServiceProvider).ready;

      // Both roles start out seeing the same order as pending.
      await consumerContainer.read(ordersNotifierProvider.notifier).fetchOrders();
      await vendorContainer.read(ordersNotifierProvider.notifier).fetchOrders();
      expect(
        consumerContainer.read(ordersNotifierProvider).orders.single.status,
        OrderStatus.pending,
      );
      expect(
        vendorContainer.read(ordersNotifierProvider).orders.single.status,
        OrderStatus.pending,
      );

      // Vendor accepts the order, choosing platform delivery.
      await vendorContainer
          .read(ordersNotifierProvider.notifier)
          .confirmOrderVendor('ORD-100', DeliveryMethod.platform);
      expect(
        vendorContainer.read(ordersNotifierProvider).orders.single.status,
        OrderStatus.confirmed,
      );

      // Vendor starts processing, then ships with tracking info.
      await vendorContainer
          .read(ordersNotifierProvider.notifier)
          .markProcessing('ORD-100');
      expect(
        vendorContainer.read(ordersNotifierProvider).orders.single.status,
        OrderStatus.processing,
      );

      await vendorContainer.read(ordersNotifierProvider.notifier).markShipped(
        'ORD-100',
        const ShippingInfo(
          trackingNumber: 'XS-TRACK-1',
          courierName: 'xStore Logistics',
        ),
      );
      expect(
        vendorContainer.read(ordersNotifierProvider).orders.single.status,
        OrderStatus.shipped,
      );

      // Client refetches and sees the vendor's status change on their order.
      await consumerContainer.read(ordersNotifierProvider.notifier).fetchOrders();
      final consumerView =
          consumerContainer.read(ordersNotifierProvider).orders.single;
      expect(consumerView.status, OrderStatus.shipped);
      expect(consumerView.trackingNumber, 'XS-TRACK-1');

      // Client confirms receipt -> delivered.
      await consumerContainer
          .read(ordersNotifierProvider.notifier)
          .confirmReceipt('ORD-100');
      expect(
        consumerContainer.read(ordersNotifierProvider).orders.single.status,
        OrderStatus.delivered,
      );

      // Vendor refetches and sees delivered, with revenue/stats updated.
      await vendorContainer.read(ordersNotifierProvider.notifier).fetchOrders();
      final vendorState = vendorContainer.read(ordersNotifierProvider);
      expect(vendorState.orders.single.status, OrderStatus.delivered);
      expect(vendorState.stats?.totalRevenue, 100);
      expect(vendorState.stats?.pendingCount, 0);
    },
  );

  test(
    'rejected order: vendor rejection is visible on the client side',
    () async {
      final repo = _SharedOrdersRepository(_seedOrder());

      final consumerContainer = ProviderContainer(
        overrides: [
          authProvider.overrideWith(() => FakeAuth(_consumer())),
          ordersRepositoryProvider.overrideWithValue(repo),
        ],
      );
      addTearDown(consumerContainer.dispose);

      final vendorContainer = ProviderContainer(
        overrides: [
          authProvider.overrideWith(() => FakeAuth(_vendor())),
          ordersRepositoryProvider.overrideWithValue(repo),
        ],
      );
      addTearDown(vendorContainer.dispose);

      await consumerContainer.read(authProvider.future);
      await vendorContainer.read(authProvider.future);
      // AnalyticsService._init() is async; every status-change method below
      // reads analyticsServiceProvider, so wait for init to finish before the
      // test (and its addTearDown dispose) can end — otherwise the pending
      // init resumes on an already-disposed container and throws into
      // whichever test happens to run next (see checkout_order_flow_test
      // .dart's `_buildContainer` for the same guard).
      await consumerContainer.read(analyticsServiceProvider).ready;
      await vendorContainer.read(analyticsServiceProvider).ready;

      await vendorContainer.read(ordersNotifierProvider.notifier).fetchOrders();
      await vendorContainer
          .read(ordersNotifierProvider.notifier)
          .rejectOrder('ORD-100', 'Out of stock');
      expect(
        vendorContainer.read(ordersNotifierProvider).orders.single.status,
        OrderStatus.cancelled,
      );

      await consumerContainer.read(ordersNotifierProvider.notifier).fetchOrders();
      final consumerView =
          consumerContainer.read(ordersNotifierProvider).orders.single;
      expect(consumerView.status, OrderStatus.cancelled);
      expect(consumerView.cancelReason, 'Out of stock');
    },
  );
}
