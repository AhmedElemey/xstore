import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:xstore/core/localization/app_localizations.dart';
import 'package:xstore/features/orders/domain/entities/order_entity.dart';
import 'package:xstore/features/orders/presentation/widgets/order_timeline.dart';

OrderEntity _order() => OrderEntity(
      id: 'o1',
      consumerId: 'c1',
      consumerName: 'Jane',
      consumerPhone: '0100',
      vendorId: 'v1',
      vendorName: 'Ahmed',
      vendorStoreName: 'Ahmed Store',
      items: const [],
      status: OrderStatus.pending,
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
      createdAt: DateTime(2026, 8, 1, 10, 30),
      updatedAt: DateTime(2026, 8, 1, 10, 30),
    );

Future<void> _pump(WidgetTester tester, Locale locale) async {
  await tester.pumpWidget(
    MaterialApp(
      locale: locale,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(
        body: SingleChildScrollView(child: OrderTimeline(order: _order())),
      ),
    ),
  );
  await tester.pump();
  await tester.pump(const Duration(seconds: 1));
}

void main() {
  testWidgets('order dates use Arabic month names in Arabic', (tester) async {
    await _pump(tester, const Locale('ar'));
    expect(find.textContaining('أغسطس'), findsWidgets);
    expect(find.textContaining('Aug'), findsNothing);
  });

  testWidgets('order dates stay English in English', (tester) async {
    await _pump(tester, const Locale('en'));
    expect(find.textContaining('Aug 1, 2026'), findsWidgets);
  });
}
