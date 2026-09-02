import 'package:flutter_test/flutter_test.dart';
import 'package:xstore/core/error/failures.dart';
import 'package:xstore/features/orders/data/models/order_model.dart';
import 'package:xstore/features/orders/data/repositories/orders_repository_impl.dart';
import 'package:xstore/features/orders/domain/entities/order_entity.dart';

import '../../../../helpers/stub_orders_remote_datasource.dart';

OrderModel _order({
  required String id,
  String consumerId = '',
}) =>
    OrderModel(
      id: id,
      consumerId: consumerId,
      consumerName: 'Jane',
      consumerPhone: '0100',
      vendorId: 'vendor_1',
      vendorName: 'Ahmed',
      vendorStoreName: 'Ahmed Store',
      items: const [],
      status: OrderStatus.pending,
      paymentMethod: PaymentMethod.cashOnDelivery,
      deliveryAddress: const OrderAddressModel(
        fullName: 'Jane',
        phone: '0100',
        street: 'St',
        city: 'Cairo',
        wilaya: 'Cairo',
      ),
      subtotal: 100,
      shippingCost: 0,
      discount: 0,
      total: 100,
      createdAt: DateTime(2026, 9, 1),
      updatedAt: DateTime(2026, 9, 1),
    );

void main() {
  const orderId = '42';
  const consumerId = 'user-1';

  group('OrdersRepositoryImpl.getOrderDetail (consumer)', () {
    test('keeps an order whose payload omitted consumerId', () async {
      final repo = OrdersRepositoryImpl(
        StubOrdersRemoteDataSource(
          getOrderByIdResult: (_) async => _order(id: orderId),
        ),
      );

      final result = await repo.getOrderDetail(
        orderId: orderId,
        consumerId: consumerId,
        vendorId: null,
        isVendorSession: false,
      );

      expect(result.isRight(), isTrue);
      expect(result.getOrElse((_) => throw StateError('left')).id, orderId);
    });

    test('falls back to GET /orders/me when by-id is missing', () async {
      final repo = OrdersRepositoryImpl(
        StubOrdersRemoteDataSource(
          getOrderByIdResult: (_) async => null,
          getConsumerOrdersResult: ({
            required consumerId,
            required page,
            required pageSize,
          }) async =>
              [_order(id: orderId, consumerId: consumerId)],
        ),
      );

      final result = await repo.getOrderDetail(
        orderId: orderId,
        consumerId: consumerId,
        vendorId: null,
        isVendorSession: false,
      );

      expect(result.isRight(), isTrue);
      expect(result.getOrElse((_) => throw StateError('left')).id, orderId);
    });

    test('rejects when a present consumerId does not match the session',
        () async {
      final repo = OrdersRepositoryImpl(
        StubOrdersRemoteDataSource(
          getOrderByIdResult: (_) async =>
              _order(id: orderId, consumerId: 'someone-else'),
        ),
      );

      final result = await repo.getOrderDetail(
        orderId: orderId,
        consumerId: consumerId,
        vendorId: null,
        isVendorSession: false,
      );

      result.fold(
        (f) => expect(f, isA<UnauthorizedFailure>()),
        (_) => fail('expected unauthorized'),
      );
    });
  });
}
