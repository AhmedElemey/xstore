import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:xstore/core/localization/app_localizations.dart';
import 'package:xstore/features/commission/domain/entities/commission_status.dart';
import 'package:xstore/features/orders/domain/entities/order_entity.dart';
import 'package:xstore/features/orders/presentation/widgets/order_price_breakdown.dart';

OrderEntity _order({required OrderStatus status}) {
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
    paymentMethod: PaymentMethod.cashOnDelivery,
    deliveryAddress: const OrderAddress(
      fullName: 'Test Buyer',
      phone: '0100000000',
      street: 'Street 1',
      city: 'Cairo',
      wilaya: 'Cairo',
    ),
    subtotal: 1000,
    shippingCost: 0,
    discount: 0,
    total: 1000,
    createdAt: now,
    updatedAt: now,
  );
}

Widget _wrap(Widget child) => ProviderScope(
      child: MaterialApp(
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(body: child),
      ),
    );

void main() {
  group('commissionStatusForOrder', () {
    test('maps order status to commission status', () {
      expect(commissionStatusForOrder(OrderStatus.pending),
          CommissionStatus.pending);
      expect(commissionStatusForOrder(OrderStatus.shipped),
          CommissionStatus.pending);
      expect(commissionStatusForOrder(OrderStatus.delivered),
          CommissionStatus.due);
      expect(commissionStatusForOrder(OrderStatus.cancelled),
          CommissionStatus.voided);
      expect(commissionStatusForOrder(OrderStatus.refunded),
          CommissionStatus.voided);
    });
  });

  group('OrderPriceBreakdown', () {
    testWidgets('buyer view never shows the platform fee', (tester) async {
      await tester.pumpWidget(
        _wrap(OrderPriceBreakdown(order: _order(status: OrderStatus.delivered))),
      );
      await tester.pumpAndSettle();

      expect(find.textContaining('You earn'), findsNothing);
      expect(find.textContaining('Platform fee'), findsNothing);
    });

    testWidgets('vendor view shows earnings, fee, and due status',
        (tester) async {
      await tester.pumpWidget(
        _wrap(
          OrderPriceBreakdown(
            order: _order(status: OrderStatus.delivered),
            vendorMode: true,
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.textContaining('You earn'), findsOneWidget);
      expect(find.textContaining('980'), findsOneWidget);
      expect(find.textContaining('20'), findsWidgets);
      expect(find.textContaining('Due on delivery'), findsOneWidget);
    });

    testWidgets('vendor view shows voided status for cancelled orders',
        (tester) async {
      await tester.pumpWidget(
        _wrap(
          OrderPriceBreakdown(
            order: _order(status: OrderStatus.cancelled),
            vendorMode: true,
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.textContaining('Voided'), findsOneWidget);
    });
  });
}
