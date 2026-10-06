import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:xstore/core/localization/app_localizations.dart';
import 'package:xstore/features/delivery/domain/entities/delivery_request.dart';
import 'package:xstore/features/delivery/presentation/widgets/package_delivery_card.dart';
import 'package:xstore/features/orders/domain/entities/order_entity.dart';

const _addr = OrderAddress(
  fullName: 'Person',
  phone: '01000000000',
  street: 'Street 1',
  city: 'Cairo',
  wilaya: 'Cairo',
);

DeliveryRequestEntity _request({String? orderId}) => DeliveryRequestEntity(
  id: 'pkg_004',
  requesterId: 'c1',
  requesterName: 'Sender',
  requesterPhone: '01000000000',
  pickup: _addr,
  dropoff: _addr,
  packageNote: '',
  orderId: orderId,
  status: DeliveryRequestStatus.confirmed,
  createdAt: DateTime(2026, 7, 19),
  updatedAt: DateTime(2026, 7, 19),
);

Widget _host(DeliveryRequestEntity r) => MaterialApp(
  localizationsDelegates: const [
    AppLocalizations.delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
  ],
  supportedLocales: AppLocalizations.supportedLocales,
  home: Scaffold(
    body: SingleChildScrollView(child: PackageDeliveryCard(request: r)),
  ),
);

void main() {
  testWidgets('standalone package shows a localized title, not the raw id', (
    tester,
  ) async {
    await tester.pumpWidget(_host(_request()));
    expect(find.text('Package'), findsOneWidget);
    expect(find.text('pkg_004'), findsNothing);
  });

  testWidgets('package linked to an order is titled by that order', (
    tester,
  ) async {
    await tester.pumpWidget(_host(_request(orderId: 'ord_77')));
    expect(find.text('Order #ord_77'), findsOneWidget);
    expect(find.text('pkg_004'), findsNothing);
  });
}
