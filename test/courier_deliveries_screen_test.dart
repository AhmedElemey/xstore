import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';

import 'package:xstore/core/localization/app_localizations.dart';
import 'package:xstore/core/mock/mock_users.dart';
import 'package:xstore/features/auth/presentation/providers/auth_provider.dart';
import 'package:xstore/features/delivery/domain/entities/delivery_request.dart';
import 'package:xstore/features/delivery/presentation/providers/delivery_request_dependencies.dart';
import 'package:xstore/features/delivery/presentation/screens/courier_deliveries_screen.dart';
import 'package:xstore/features/delivery/presentation/widgets/delivery_order_card.dart';
import 'package:xstore/features/delivery/presentation/widgets/package_delivery_card.dart';
import 'package:xstore/features/orders/domain/entities/order_entity.dart';
import 'package:xstore/features/orders/presentation/providers/orders_dependencies.dart';
import 'package:xstore/shared/widgets/empty_state_widget.dart';

import 'helpers/fake_async_auth_notifier.dart';
import 'helpers/stub_delivery_request_repository.dart';
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

List<Override> _overrides(
  List<OrderEntity> orders, {
  List<DeliveryRequestEntity> packages = const [],
}) =>
    [
      authProvider.overrideWith(() => FakeAuth(mockCourierUser)),
      ordersRepositoryProvider.overrideWithValue(
        StubOrdersRepository(
          getCourierOrdersResult: (
                  {required courierId, required page, required pageSize}) =>
              Right(page == 1 ? orders : const []),
        ),
      ),
      // Zero-latency package store: keeps the mock datasource's simulated
      // network Timer (and its demo seeds) out of these scenarios.
      deliveryRequestRepositoryProvider.overrideWithValue(
        StubDeliveryRequestRepository(courierPackages: packages),
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

  testWidgets('customer identity is masked until the order is confirmed',
      (tester) async {
    await tester.pumpWidget(_app(_overrides([
      _order(id: 'task_pending', status: OrderStatus.pending),
    ])));
    await tester.pumpAndSettle();

    // Pending order (History section, not yet actionable): name and call
    // button are hidden behind the privacy placeholder.
    expect(
      find.text('Customer details unlock after confirmation'),
      findsOneWidget,
    );
    expect(find.text('Test Buyer'), findsNothing);
    expect(find.byIcon(LucideIcons.phone), findsNothing);
  });

  testWidgets('confirmed order shows the labeled collect-from-customer row',
      (tester) async {
    await tester.pumpWidget(_app(_overrides([
      _order(id: 'task_pickup', status: OrderStatus.confirmed, total: 600),
    ])));
    await tester.pumpAndSettle();

    expect(find.text('Collect from customer'), findsOneWidget);
    expect(find.textContaining('600'), findsWidgets);
    // Identity unlocked once confirmed.
    expect(find.text('Test Buyer'), findsOneWidget);
    expect(find.byIcon(LucideIcons.phone), findsOneWidget);
  });

  testWidgets(
      'confirmed package task shows sender cash row and pick-up flow '
      'moves it to deliver', (tester) async {
    await tester.pumpWidget(_app(_overrides(
      const [],
      packages: [
        testPackageRequest(
          id: 'pkg_ready',
          status: DeliveryRequestStatus.confirmed,
          courierId: 'courier_001',
        ),
      ],
    )));
    await tester.pumpAndSettle();

    // Packages section renders the task with the admin-set price to collect
    // from the sender at pickup; identity is visible (status >= confirmed).
    expect(find.text('Packages'), findsOneWidget);
    expect(find.byType(PackageDeliveryCard), findsOneWidget);
    expect(find.text('Collect from sender at pickup'), findsOneWidget);
    expect(find.textContaining('80'), findsWidgets);
    expect(find.text('Sender Person'), findsOneWidget);

    // Pick-up goes through a cash-amount confirmation dialog.
    await tester.tap(find.text('Cash collected — picked up'));
    await tester.pumpAndSettle();
    expect(find.text('Collect cash & pick up'), findsOneWidget);
    await tester.tap(find.text('Cash collected — picked up').last);
    await tester.pumpAndSettle();

    // Optimistic update: the task is now at the deliver stage.
    expect(find.text('Delivered'), findsOneWidget);
  });
}
