import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:xstore/core/localization/app_localizations.dart';
import 'package:xstore/features/auth/domain/entities/user_entity.dart';
import 'package:xstore/features/auth/presentation/providers/auth_provider.dart';
import 'package:xstore/features/orders/domain/entities/order_entity.dart';
import 'package:xstore/features/orders/presentation/widgets/order_action_buttons.dart';
import 'package:xstore/features/orders/presentation/widgets/order_card.dart';

class _FakeAuth extends Auth {
  @override
  Future<UserEntity?> build() async => null;
}

OrderEntity _order({required bool isReviewed}) {
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
    status: OrderStatus.delivered,
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
    isReviewed: isReviewed,
    createdAt: now,
    updatedAt: now,
  );
}

Widget _app(Widget child) => ProviderScope(
  overrides: [authProvider.overrideWith(_FakeAuth.new)],
  child: MaterialApp(
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: Scaffold(body: SingleChildScrollView(child: child)),
  ),
);

void main() {
  final cases = <String, Widget Function(OrderEntity)>{
    'OrderCard': (o) => OrderCard(order: o),
    'OrderActionButtons': (o) => OrderActionButtons(orderId: o.id, order: o),
  };

  cases.forEach((name, build) {
    testWidgets('$name shows Leave review for an unreviewed delivered order', (
      tester,
    ) async {
      await tester.pumpWidget(_app(build(_order(isReviewed: false))));
      await tester.pump();
      expect(find.text('Leave Review'), findsOneWidget);
    });

    testWidgets('$name hides Leave review once the order is reviewed', (
      tester,
    ) async {
      await tester.pumpWidget(_app(build(_order(isReviewed: true))));
      await tester.pump();
      expect(find.text('Leave Review'), findsNothing);
    });
  });
}
