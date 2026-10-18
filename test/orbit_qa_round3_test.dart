// Orbit QA round 3: load failures show an error state with Retry (orders,
// wishlist, courier cash), the Arabic bidi/digit fixes on cards, mock listings
// are purchasable, tab sheets cover the dock and the ship-order sheet's date
// field matches its text fields.
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:xstore/core/animations/app_dialogs.dart';
import 'package:xstore/core/error/failures.dart';
import 'package:xstore/core/localization/app_localizations.dart';
import 'package:xstore/core/mock/mock_config.dart';
import 'package:xstore/core/mock/mock_listings.dart';
import 'package:xstore/core/mock/mock_users.dart';
import 'package:xstore/core/utils/extensions/context_extensions.dart';
import 'package:xstore/features/auth/domain/entities/user_entity.dart';
import 'package:xstore/features/auth/presentation/providers/auth_provider.dart';
import 'package:xstore/features/cart/presentation/widgets/quantity_control.dart';
import 'package:xstore/features/delivery/presentation/providers/courier_cash_wallet_provider.dart';
import 'package:xstore/features/delivery/presentation/screens/courier_cash_screen.dart';
import 'package:xstore/features/delivery/presentation/widgets/delivery_order_card.dart';
import 'package:xstore/features/orders/domain/entities/order_entity.dart';
import 'package:xstore/features/orders/domain/entities/order_item_entity.dart';
import 'package:xstore/features/orders/presentation/providers/orders_dependencies.dart';
import 'package:xstore/features/orders/presentation/providers/orders_provider.dart';
import 'package:xstore/features/orders/presentation/screens/vendor_orders_screen.dart';
import 'package:xstore/features/orders/presentation/widgets/consumer_orders_view.dart';
import 'package:xstore/features/orders/presentation/widgets/order_flow_sheets.dart';
import 'package:xstore/features/orders/presentation/widgets/vendor_order_card.dart';
import 'package:xstore/features/product/presentation/screens/product_detail_screen.dart';
import 'package:xstore/features/wishlist/presentation/providers/wishlist_dependencies.dart';
import 'package:xstore/features/wishlist/presentation/screens/wishlist_screen.dart';
import 'package:xstore/shared/widgets/error_state_widget.dart';

import 'helpers/fake_async_auth_notifier.dart';
import 'helpers/stub_orders_repository.dart';
import 'helpers/stub_wishlist_remote_datasource.dart';

const _ar = Locale('ar');

Widget _app(Widget home, {Locale? locale}) => MaterialApp(
  locale: locale,
  localizationsDelegates: const [
    AppLocalizations.delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
  ],
  supportedLocales: AppLocalizations.supportedLocales,
  home: Scaffold(body: home),
);

Future<void> _settle(WidgetTester tester, [int times = 15]) async {
  for (var i = 0; i < times; i++) {
    await tester.pump(const Duration(milliseconds: 100));
  }
}

const _consumer = UserEntity(
  id: 'consumer_1',
  name: 'Buyer',
  email: 'b@test.com',
  phoneNumber: '01012345678',
);

OrderEntity _order({
  String id = 'order_1',
  OrderStatus status = OrderStatus.pending,
  String street = '15 Abbas El Akkad St',
  String city = 'Nasr City',
  List<OrderItemEntity> items = const [],
}) {
  final now = DateTime(2026, 7, 1);
  return OrderEntity(
    id: id,
    consumerId: 'consumer_1',
    consumerName: 'Test Buyer',
    consumerPhone: '+20 101 987 6543',
    vendorId: 'vendor_1',
    vendorName: 'Vendor',
    vendorStoreName: 'Store',
    items: items,
    status: status,
    paymentMethod: PaymentMethod.cashOnDelivery,
    deliveryAddress: OrderAddress(
      fullName: 'Test Buyer',
      phone: '+20 101 987 6543',
      street: street,
      city: city,
      wilaya: 'Cairo',
    ),
    subtotal: 10,
    shippingCost: 0,
    discount: 0,
    total: 10,
    createdAt: now,
    updatedAt: now,
  );
}

const _item = OrderItemEntity(
  id: 'i1',
  listingId: 'l1',
  listingName: 'Karim Store Camera',
  listingImage: '',
  category: 'Electronics',
  condition: 'New',
  price: 1500,
  quantity: 3,
  total: 4500,
);

/// An orders repo that fails until [healed], like a dropped connection.
class _FlakyOrders extends StubOrdersRepository {
  _FlakyOrders({this.orders = const []})
    : super(
        getConsumerOrdersResult:
            ({required consumerId, required page, required pageSize}) =>
                Left(Failure.network('offline')),
      );

  var healed = false;
  var calls = 0;
  final List<OrderEntity> orders;

  @override
  Future<Either<Failure, List<OrderEntity>>> getConsumerOrders({
    required String consumerId,
    required int page,
    required int pageSize,
  }) async {
    calls++;
    return healed ? Right(orders) : Left(Failure.network('offline'));
  }

  @override
  Future<Either<Failure, List<OrderEntity>>> getVendorOrders({
    required String vendorId,
    required int page,
    required int pageSize,
  }) async {
    calls++;
    return healed ? Right(orders) : Left(Failure.network('offline'));
  }
}

Future<ProviderContainer> _container(
  List<Override> overrides,
  UserEntity user,
) async {
  final c = ProviderContainer(
    overrides: [
      authProvider.overrideWith(() => FakeAuth(user)),
      ...overrides,
    ],
  );
  // The notifiers read authProvider.valueOrNull on their first fetch.
  await c.read(authProvider.future);
  return c;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final en = lookupAppLocalizations(const Locale('en'));
  final ar = lookupAppLocalizations(_ar);

  setUp(() => SharedPreferences.setMockInitialValues({}));

  group('load failure shows the error state with Retry', () {
    testWidgets('consumer orders', (tester) async {
      final repo = _FlakyOrders(orders: [_order()]);
      final c = await _container([
        ordersRepositoryProvider.overrideWithValue(repo),
      ], _consumer);
      addTearDown(c.dispose);
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: c,
          child: _app(const ConsumerOrdersView()),
        ),
      );
      await _settle(tester);

      expect(find.byType(ErrorStateWidget), findsOneWidget);
      expect(find.text(en.ordersEmptyTitle), findsNothing);
      expect(find.byType(SnackBar), findsNothing);

      repo.healed = true;
      await tester.tap(find.text(en.retry));
      await _settle(tester);
      expect(find.byType(ErrorStateWidget), findsNothing);
      expect(find.textContaining('XS-'), findsWidgets);
    });

    testWidgets('consumer orders keep the snackbar when data is showing', (
      tester,
    ) async {
      final repo = _FlakyOrders(orders: [_order()])..healed = true;
      final c = await _container([
        ordersRepositoryProvider.overrideWithValue(repo),
      ], _consumer);
      addTearDown(c.dispose);
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: c,
          child: _app(const ConsumerOrdersView()),
        ),
      );
      await _settle(tester);
      expect(find.byType(ErrorStateWidget), findsNothing);

      repo.healed = false;
      await c.read(ordersNotifierProvider.notifier).fetchOrders();
      await _settle(tester);
      expect(find.byType(ErrorStateWidget), findsNothing);
      expect(find.byType(SnackBar), findsOneWidget);
    });

    testWidgets('vendor orders', (tester) async {
      final repo = _FlakyOrders(orders: [_order()]);
      final c = await _container([
        ordersRepositoryProvider.overrideWithValue(repo),
      ], mockVendorUser);
      addTearDown(c.dispose);
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: c,
          child: _app(const VendorOrdersScreen()),
        ),
      );
      await _settle(tester);

      expect(find.byType(ErrorStateWidget), findsOneWidget);
      expect(find.text(en.vendorOrdersEmptyTitle), findsNothing);

      repo.healed = true;
      await tester.tap(find.text(en.retry));
      await _settle(tester);
      expect(find.byType(ErrorStateWidget), findsNothing);
    });

    testWidgets('wishlist', (tester) async {
      var fail = true;
      final c = await _container([
        wishlistRemoteDataSourceProvider.overrideWithValue(
          StubWishlistRemoteDataSource(
            onGetWishlist: (_) async {
              if (fail) throw Exception('offline');
              return [];
            },
          ),
        ),
      ], _consumer);
      addTearDown(c.dispose);
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: c,
          child: _app(const WishlistScreen()),
        ),
      );
      await _settle(tester);

      expect(find.byType(ErrorStateWidget), findsOneWidget);
      expect(find.byType(SnackBar), findsNothing);

      fail = false;
      await tester.tap(find.text(en.retry));
      await _settle(tester);
      expect(find.byType(ErrorStateWidget), findsNothing);
    });

    test('courier cash provider throws instead of a zero balance', () async {
      final c = await _container([
        ordersRepositoryProvider.overrideWithValue(
          StubOrdersRepository(
            getCourierOrdersResult:
                ({required courierId, required page, required pageSize}) =>
                    Left(Failure.network('offline')),
          ),
        ),
      ], mockCourierUser);
      addTearDown(c.dispose);
      await expectLater(
        c.read(courierCashWalletProvider.future),
        throwsA(isA<Failure>()),
      );
    });

    testWidgets('courier cash screen', (tester) async {
      final c = await _container([
        ordersRepositoryProvider.overrideWithValue(
          StubOrdersRepository(
            getCourierOrdersResult:
                ({required courierId, required page, required pageSize}) =>
                    Left(Failure.network('offline')),
          ),
        ),
      ], mockCourierUser);
      addTearDown(c.dispose);
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: c,
          child: _app(const CourierCashScreen()),
        ),
      );
      await _settle(tester);

      expect(find.byType(ErrorStateWidget), findsOneWidget);
      expect(find.text('0 LE'), findsNothing);
    });
  });

  group('Arabic address line (comma stays with the street)', () {
    testWidgets('addressLine isolates the whole line with the Arabic comma', (
      tester,
    ) async {
      late BuildContext ctx;
      await tester.pumpWidget(
        _app(
          Builder(
            builder: (c) {
              ctx = c;
              return const SizedBox();
            },
          ),
          locale: _ar,
        ),
      );
      expect(
        ctx.addressLine(['15 Abbas St', 'Nasr City']),
        '\u206815 Abbas St\u060C Nasr City\u2069',
      );
      expect(ctx.addressLine(['15 Abbas St', '', 'Cairo']), contains('\u060C'));
    });

    testWidgets('English keeps the plain ", " line', (tester) async {
      late BuildContext ctx;
      await tester.pumpWidget(
        _app(
          Builder(
            builder: (c) {
              ctx = c;
              return const SizedBox();
            },
          ),
        ),
      );
      expect(
        ctx.addressLine(['15 Abbas St', 'Nasr City']),
        '15 Abbas St, Nasr City',
      );
    });

    testWidgets('courier delivery card shows one isolated line in Arabic', (
      tester,
    ) async {
      await tester.pumpWidget(
        _app(
          SingleChildScrollView(
            child: DeliveryOrderCard(order: _order(status: OrderStatus.shipped)),
          ),
          locale: _ar,
        ),
      );
      expect(
        find.text('\u206815 Abbas El Akkad St\u060C Nasr City\u2069'),
        findsOneWidget,
      );
    });
  });

  group('Arabic cards: user text isolated, digits match prices', () {
    testWidgets('vendor order card', (tester) async {
      await tester.pumpWidget(
        _app(
          SingleChildScrollView(
            child: VendorOrderCard(
              order: _order(items: const [_item]),
              onConfirm: () {},
              onReject: () {},
              onProcessing: () {},
              onShipped: () {},
              onDelivered: () {},
            ),
          ),
          locale: _ar,
        ),
      );
      // Latin item title keeps its own direction.
      expect(find.text('\u2068Karim Store Camera\u2069'), findsOneWidget);
      // Quantity uses the same digits as the price on that line.
      expect(find.textContaining('${ar.ordersQtyTotalLinePrefix} ٣'), findsOneWidget);
    });

    testWidgets('cart quantity control: stepper and "only N left"', (
      tester,
    ) async {
      await tester.pumpWidget(
        _app(
          QuantityControl(
            quantity: 2,
            maxQuantity: 3,
            enabled: true,
            onDecrement: () {},
            onIncrement: () {},
            onEditQuantity: () {},
          ),
          locale: _ar,
        ),
      );
      expect(find.text('٢'), findsOneWidget);
      expect(
        find.text('${ar.onlyLeftPrefix}٣${ar.onlyLeftSuffix}'),
        findsOneWidget,
      );
    });

    testWidgets('English digits stay Latin', (tester) async {
      late BuildContext ctx;
      await tester.pumpWidget(
        _app(
          Builder(
            builder: (c) {
              ctx = c;
              return const SizedBox();
            },
          ),
        ),
      );
      expect(ctx.formatInt(1234), '1234');
    });
  });

  group('mock listings are purchasable', () {
    test('mock listings carry stock; a couple stay sold out', () {
      final stocks = mockListingModels.map((m) => m.stockQuantity).toList();
      expect(mockListingModels.first.stockQuantity, greaterThan(0));
      expect(stocks.where((s) => s > 0).length, greaterThan(10));
      expect(stocks.where((s) => s == 0), isNotEmpty);
    });

    testWidgets(
      'a mock product shows Add to Cart, not Sold out',
      skip: !MockConfig.useMock,
      (tester) async {
        final c = await _container([], _consumer);
        await tester.pumpWidget(
          UncontrolledProviderScope(
            container: c,
            child: const MaterialApp(
              localizationsDelegates: [
                AppLocalizations.delegate,
                GlobalMaterialLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
                GlobalCupertinoLocalizations.delegate,
              ],
              supportedLocales: AppLocalizations.supportedLocales,
              home: ProductDetailScreen(productId: 'listing_001'),
            ),
          ),
        );
        await _settle(tester, 30);
        expect(find.text('Add to Cart'), findsOneWidget);
        expect(find.text('Sold out'), findsNothing);

        // Let the mock latency and entrance animations finish.
        await tester.pumpWidget(const SizedBox());
        c.dispose();
        await tester.pump(const Duration(seconds: 5));
      },
    );
  });

  group('tab sheets cover the dock', () {
    testWidgets('showAnimatedBottomSheet opens on the root navigator', (
      tester,
    ) async {
      NavigatorState? sheetNavigator;
      NavigatorState? rootNavigator;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            bottomNavigationBar: const SizedBox(height: 80),
            // Like a shell branch: a nested navigator under the root one.
            body: Navigator(
              onGenerateRoute: (_) => MaterialPageRoute<void>(
                builder: (tabContext) => Center(
                  child: TextButton(
                    onPressed: () => showAnimatedBottomSheet<void>(
                      context: tabContext,
                      builder: (sheetContext) {
                        sheetNavigator = Navigator.of(sheetContext);
                        rootNavigator = Navigator.of(
                          sheetContext,
                          rootNavigator: true,
                        );
                        return TextButton(
                          onPressed: () => Navigator.pop(sheetContext),
                          child: const Text('close'),
                        );
                      },
                    ),
                    child: const Text('open'),
                  ),
                ),
              ),
            ),
          ),
        ),
      );
      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();
      expect(sheetNavigator, isNotNull);
      expect(identical(sheetNavigator, rootNavigator), isTrue);

      await tester.tap(find.text('close'));
      await tester.pumpAndSettle();
      expect(find.text('close'), findsNothing);
    });
  });

  testWidgets('ship-order sheet date field matches the text fields', (
    tester,
  ) async {
    await tester.pumpWidget(
      _app(
        Builder(
          builder: (context) => TextButton(
            onPressed: () => showShipOrderSheet(context),
            child: const Text('open'),
          ),
        ),
      ),
    );
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();

    expect(find.byType(ListTile), findsNothing);
    final fields = find.byType(InputDecorator);
    expect(fields, findsNWidgets(3));
    final first = tester.getRect(fields.at(0));
    final date = tester.getRect(fields.at(2));
    expect(date.left, first.left);
    expect(date.width, first.width);
    expect(find.text(en.ordersEstimatedDeliveryLabel), findsOneWidget);

    // The date still opens the picker.
    await tester.tap(fields.at(2));
    await tester.pumpAndSettle();
    expect(find.byType(DatePickerDialog), findsOneWidget);
  });
}
