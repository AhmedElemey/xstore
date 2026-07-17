import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';

import 'package:xstore/core/localization/app_localizations.dart';
import 'package:xstore/core/mock/mock_users.dart';
import 'package:xstore/features/auth/presentation/providers/auth_provider.dart';
import 'package:xstore/features/delivery/presentation/screens/courier_deliveries_screen.dart';
import 'package:xstore/features/delivery/presentation/widgets/delivery_order_card.dart';
import 'package:xstore/features/orders/domain/entities/order_entity.dart';
import 'package:xstore/features/orders/presentation/providers/orders_dependencies.dart';
import 'package:xstore/shared/widgets/empty_state_widget.dart';

import 'helpers/fake_async_auth_notifier.dart';
import 'helpers/stub_orders_repository.dart';

OrderEntity _order({
  required String id,
  required OrderStatus status,
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
    paymentMethod: PaymentMethod.cashOnDelivery,
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

Widget _app(List<Override> overrides) => ProviderScope(
      overrides: overrides,
      child: MaterialApp(
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: AppLocalizations.supportedLocales,
        // Mirror the real app: splash gates on auth, so the courier screen
        // never mounts while authProvider is still Loading (its initState
        // fetch reads authProvider.valueOrNull).
        home: Consumer(
          builder: (context, ref, _) {
            final user = ref.watch(authProvider).valueOrNull;
            if (user == null) return const SizedBox.shrink();
            return const CourierDeliveriesScreen();
          },
        ),
      ),
    );

List<Override> _overrides(List<OrderEntity> orders) => [
      authProvider.overrideWith(() => FakeAuth(mockCourierUser)),
      ordersRepositoryProvider.overrideWithValue(
        StubOrdersRepository(
          getCourierOrdersResult: (
                  {required courierId, required page, required pageSize}) =>
              Right(page == 1 ? orders : const []),
        ),
      ),
    ];

void main() {
  testWidgets('renders active run with actions and collected cash header',
      (tester) async {
    await tester.pumpWidget(_app(_overrides([
      _order(id: 'task_pickup', status: OrderStatus.confirmed, total: 600),
      _order(id: 'task_dropoff', status: OrderStatus.shipped, total: 900),
      _order(id: 'task_done', status: OrderStatus.delivered, total: 1500),
    ])));
    await tester.pumpAndSettle();

    // Active section: one pick-up and one drop-off card with actions
    // (the delivered order sits in History, below the fold).
    expect(find.byType(DeliveryOrderCard), findsNWidgets(2));
    expect(find.text('Picked up'), findsOneWidget);
    expect(find.text('Delivered'), findsOneWidget);
    expect(find.text('Failed'), findsNWidgets(2));

    // COD chips show the amount to collect at the door.
    expect(find.textContaining('Collect'), findsNWidgets(2));

    // Every visible card offers Google Maps directions to the buyer.
    expect(find.byIcon(LucideIcons.navigation), findsNWidgets(2));

    // Cash header sums the delivered COD order.
    expect(find.text('Cash in hand'), findsOneWidget);
    expect(find.textContaining('1,500'), findsWidgets);

    // The finished task is reachable under the History section.
    await tester.scrollUntilVisible(find.text('task_done'), 200);
    expect(find.text('History'), findsOneWidget);
  });

  testWidgets('tapping Delivered asks for confirmation with the COD amount',
      (tester) async {
    await tester.pumpWidget(_app(_overrides([
      _order(id: 'task_dropoff', status: OrderStatus.shipped, total: 900),
    ])));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Delivered'));
    await tester.pumpAndSettle();

    expect(find.text('Confirm delivery'), findsOneWidget);
    expect(find.textContaining('900'), findsWidgets);

    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
    expect(find.text('Confirm delivery'), findsNothing);
  });

  testWidgets('shows empty state when nothing is assigned', (tester) async {
    await tester.pumpWidget(_app(_overrides(const [])));
    await tester.pumpAndSettle();

    expect(find.byType(EmptyStateWidget), findsOneWidget);
    expect(find.text('No deliveries assigned'), findsOneWidget);
  });
}
