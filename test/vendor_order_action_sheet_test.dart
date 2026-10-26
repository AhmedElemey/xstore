import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:xstore/core/localization/app_localizations.dart';
import 'package:xstore/features/orders/domain/entities/order_entity.dart';
import 'package:xstore/features/orders/presentation/widgets/vendor_order_action_sheet.dart';
import 'package:xstore/shared/widgets/xstore_button.dart';

OrderEntity _order(OrderStatus status) {
  final now = DateTime(2026, 7, 1);
  return OrderEntity(
    id: 'o1',
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

Widget _app(OrderStatus status) => MaterialApp(
  localizationsDelegates: AppLocalizations.localizationsDelegates,
  supportedLocales: AppLocalizations.supportedLocales,
  home: Scaffold(
    body: VendorOrderActionSheet(
      order: _order(status),
      onConfirm: () {},
      onReject: () {},
      onProcessing: () {},
      onShipped: () {},
      onDelivered: () {},
    ),
  ),
);

void main() {
  // DeliveryFailed is terminal: like Delivered/Cancelled it must not fall
  // through to the default "Mark shipped" action.
  for (final status in [
    OrderStatus.delivered,
    OrderStatus.cancelled,
    OrderStatus.deliveryFailed,
  ]) {
    testWidgets('$status shows no vendor actions', (tester) async {
      await tester.pumpWidget(_app(status));
      expect(find.byType(XstoreButton), findsNothing);
    });
  }

  testWidgets('processing still offers Mark shipped', (tester) async {
    await tester.pumpWidget(_app(OrderStatus.processing));
    expect(find.byType(XstoreButton), findsOneWidget);
  });
}
