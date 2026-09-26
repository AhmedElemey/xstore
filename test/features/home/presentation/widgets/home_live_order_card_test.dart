import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:xstore/core/localization/app_localizations.dart';
import 'package:xstore/features/auth/domain/entities/user_entity.dart';
import 'package:xstore/features/auth/presentation/providers/auth_provider.dart';
import 'package:xstore/features/explore/presentation/widgets/explore_radar_header.dart';
import 'package:xstore/features/home/presentation/widgets/home_live_order_card.dart';
import 'package:xstore/features/orders/domain/entities/order_entity.dart';
import 'package:xstore/features/orders/presentation/providers/orders_provider.dart';

OrderEntity _order(String id, OrderStatus status, DateTime createdAt) =>
    OrderEntity(
      id: id,
      consumerId: 'c1',
      consumerName: 'Salma',
      consumerPhone: '0100',
      vendorId: 'v1',
      vendorName: 'Nour',
      vendorStoreName: 'Nour Studio',
      items: const [],
      status: status,
      paymentMethod: PaymentMethod.cashOnDelivery,
      deliveryAddress: const OrderAddress(
        fullName: 'Salma',
        phone: '0100',
        street: 'St',
        city: 'Cairo',
        wilaya: 'Cairo',
      ),
      subtotal: 890,
      shippingCost: 45,
      discount: 0,
      total: 935,
      createdAt: createdAt,
      updatedAt: createdAt,
    );

class _FakeAuth extends Auth {
  _FakeAuth(this._user);
  final UserEntity? _user;
  @override
  Future<UserEntity?> build() async => _user;
}

class _FakeOrders extends OrdersNotifier {
  _FakeOrders(this._initial);
  final OrdersState _initial;
  int fetches = 0;

  @override
  OrdersState build() => _initial;

  @override
  Future<void> fetchOrders() async => fetches++;
}

const _consumer = UserEntity(
  id: 'c1',
  name: 'Salma',
  email: 's@test.com',
  phoneNumber: '01012345678',
);

Future<_FakeOrders> _pump(
  WidgetTester tester, {
  required List<OrderEntity> orders,
  UserEntity? user = _consumer,
}) async {
  final fake = _FakeOrders(OrdersState(orders: orders));
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        authProvider.overrideWith(() => _FakeAuth(user)),
        ordersNotifierProvider.overrideWith(() => fake),
      ],
      child: const MaterialApp(
        locale: Locale('en'),
        localizationsDelegates: [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(body: HomeLiveOrderCard()),
      ),
    ),
  );
  await tester.pump();
  await tester.pump();
  return fake;
}

void main() {
  group('liveOrderOf', () {
    test('picks the newest order that is still in flight', () {
      final live = liveOrderOf([
        _order('old', OrderStatus.confirmed, DateTime(2026, 9, 1)),
        _order('done', OrderStatus.delivered, DateTime(2026, 9, 20)),
        _order('new', OrderStatus.shipped, DateTime(2026, 9, 10)),
        _order('gone', OrderStatus.cancelled, DateTime(2026, 9, 25)),
      ]);
      expect(live?.id, 'new');
    });

    test('is null when every order is finished', () {
      expect(
        liveOrderOf([
          _order('a', OrderStatus.delivered, DateTime(2026, 9, 1)),
          _order('b', OrderStatus.cancelled, DateTime(2026, 9, 2)),
        ]),
        isNull,
      );
    });
  });

  testWidgets('shows status, cash to have ready and a track action', (
    tester,
  ) async {
    await _pump(
      tester,
      orders: [_order('48213', OrderStatus.shipped, DateTime(2026, 9, 25))],
    );

    expect(find.text('SHIPPED'), findsOneWidget);
    expect(find.text('#48213'), findsOneWidget);
    expect(find.textContaining('cash ready'), findsOneWidget);
    expect(find.textContaining('935'), findsOneWidget);
    expect(find.text('Track'), findsOneWidget);
  });

  testWidgets('stays hidden when nothing is in flight', (tester) async {
    await _pump(
      tester,
      orders: [_order('1', OrderStatus.delivered, DateTime(2026, 9, 25))],
    );
    expect(find.text('Track'), findsNothing);
  });

  testWidgets('fetches orders once on open when none are loaded', (
    tester,
  ) async {
    final fake = await _pump(tester, orders: const []);
    expect(fake.fetches, 1);
  });

  testWidgets('does not fetch or show for vendors', (tester) async {
    final fake = await _pump(
      tester,
      orders: [_order('1', OrderStatus.shipped, DateTime(2026, 9, 25))],
      user: _consumer.copyWith(role: UserRole.vendor),
    );
    expect(fake.fetches, 0);
    expect(find.text('Track'), findsNothing);
  });

  testWidgets('explore radar shows the localized result count', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        locale: Locale('en'),
        localizationsDelegates: [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: ExploreRadarHeader(resultCount: 24, queryLabel: 'sneakers'),
        ),
      ),
    );
    expect(find.text('24 results'), findsOneWidget);
    expect(find.text('Results for sneakers'), findsOneWidget);
    expect(find.text('AROUND YOU'), findsOneWidget);
  });
}
