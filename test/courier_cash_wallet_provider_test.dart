import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';

import 'package:xstore/core/mock/mock_users.dart';
import 'package:xstore/features/auth/presentation/providers/auth_provider.dart';
import 'package:xstore/features/delivery/presentation/providers/courier_cash_wallet_provider.dart';
import 'package:xstore/features/orders/domain/entities/order_entity.dart';
import 'package:xstore/features/orders/presentation/providers/orders_dependencies.dart';

import 'helpers/fake_async_auth_notifier.dart';
import 'helpers/stub_orders_repository.dart';

OrderEntity _order({
  required String id,
  required OrderStatus status,
  PaymentMethod payment = PaymentMethod.cashOnDelivery,
  bool isPaid = false,
  double total = 1000,
}) {
  final now = DateTime(2026, 7, 1);
  return OrderEntity(
    id: id,
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
  test('sums only delivered COD orders into cash in hand', () async {
    final orders = [
      _order(id: 'o1', status: OrderStatus.delivered, total: 1200),
      _order(id: 'o2', status: OrderStatus.shipped, total: 500),
      _order(
        id: 'o3',
        status: OrderStatus.delivered,
        payment: PaymentMethod.cibCard,
        isPaid: true,
        total: 800,
      ),
      _order(id: 'o4', status: OrderStatus.cancelled, total: 300),
    ];
    final container = ProviderContainer(
      overrides: [
        authProvider.overrideWith(() => FakeAuth(mockCourierUser)),
        ordersRepositoryProvider.overrideWithValue(
          StubOrdersRepository(
            getCourierOrdersResult: (
                    {required courierId, required page, required pageSize}) =>
                Right(page == 1 ? orders : const []),
          ),
        ),
      ],
    );
    addTearDown(container.dispose);

    // Warm auth up first — the wallet reads authProvider.valueOrNull, which
    // is null while the lazy async provider is still Loading.
    await container.read(authProvider.future);

    final wallet = await container.read(courierCashWalletProvider.future);
    expect(wallet.cashInHandEgp, 1200);
    expect(wallet.deliveredCodOrders.map((o) => o.id), ['o1']);
    expect(wallet.handoverThresholdEgp, kCourierCashHandoverThresholdEgp);
    expect(wallet.handoverDue, false);
  });

  test('handoverDue trips at the threshold', () async {
    final container = ProviderContainer(
      overrides: [
        authProvider.overrideWith(() => FakeAuth(mockCourierUser)),
        ordersRepositoryProvider.overrideWithValue(
          StubOrdersRepository(
            getCourierOrdersResult: (
                    {required courierId, required page, required pageSize}) =>
                Right(page == 1
                    ? [
                        _order(
                          id: 'o1',
                          status: OrderStatus.delivered,
                          total: kCourierCashHandoverThresholdEgp,
                        ),
                      ]
                    : const []),
          ),
        ),
      ],
    );
    addTearDown(container.dispose);

    await container.read(authProvider.future);

    final wallet = await container.read(courierCashWalletProvider.future);
    expect(wallet.handoverDue, true);
  });

  test('non-courier session gets an empty wallet without fetching', () async {
    var fetches = 0;
    final container = ProviderContainer(
      overrides: [
        authProvider.overrideWith(() => FakeAuth(mockConsumerUser)),
        ordersRepositoryProvider.overrideWithValue(
          StubOrdersRepository(
            getCourierOrdersResult: (
                {required courierId, required page, required pageSize}) {
              fetches++;
              return const Right([]);
            },
          ),
        ),
      ],
    );
    addTearDown(container.dispose);

    await container.read(authProvider.future);

    final wallet = await container.read(courierCashWalletProvider.future);
    expect(wallet.cashInHandEgp, 0);
    expect(wallet.deliveredCodOrders, isEmpty);
    expect(fetches, 0);
  });
}
