import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:xstore/core/localization/app_localizations.dart';
import 'package:xstore/features/orders/domain/entities/order_entity.dart';
import 'package:xstore/features/orders/presentation/providers/orders_provider.dart';
import 'package:xstore/features/orders/presentation/widgets/order_filter_tabs.dart';

OrderEntity _order(String id, OrderStatus status) {
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
    paymentMethod: PaymentMethod.cashOnDelivery,
    deliveryAddress: const OrderAddress(
      fullName: 'Test Buyer',
      phone: '0100000000',
      street: 'Street 1',
      city: 'Cairo',
      wilaya: 'Cairo',
    ),
    subtotal: 100,
    shippingCost: 0,
    discount: 0,
    total: 100,
    createdAt: now,
    updatedAt: now,
  );
}

class _Orders extends OrdersNotifier {
  @override
  OrdersState build() => OrdersState(
    hasMore: false,
    orders: [
      _order('o1', OrderStatus.delivered),
      _order('o2', OrderStatus.deliveryFailed),
    ],
  );
}

void main() {
  testWidgets('consumer tabs hide Delivery failed but All still counts it', (
    tester,
  ) async {
    // Wide enough that the horizontal list builds every chip.
    tester.view.physicalSize = const Size(3000, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [ordersNotifierProvider.overrideWith(_Orders.new)],
        child: MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const Scaffold(body: OrderFilterTabs()),
        ),
      ),
    );

    expect(find.textContaining('Delivery failed'), findsNothing);
    for (final label in [
      'Pending',
      'Confirmed',
      'Processing',
      'Shipped',
      'Delivered',
      'Cancelled',
    ]) {
      expect(find.textContaining(label), findsOneWidget, reason: label);
    }
    expect(find.text('All (2)'), findsOneWidget);
  });
}
