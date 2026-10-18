// Orbit QA round 4: truncated Latin titles keep their ellipsis at the end in
// Arabic, one digit system next to Arabic-Indic prices, and the vendor-list
// shipping sheet's date field matches its text fields.
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:xstore/core/localization/app_localizations.dart';
import 'package:xstore/core/utils/extensions/context_extensions.dart';
import 'package:xstore/features/orders/domain/entities/order_entity.dart';
import 'package:xstore/features/orders/domain/entities/order_item_entity.dart';
import 'package:xstore/features/orders/presentation/widgets/shipping_info_sheet.dart';
import 'package:xstore/features/orders/presentation/widgets/vendor_order_card.dart';
import 'package:xstore/features/orders/presentation/widgets/vendor_order_stats_banner.dart';

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

OrderItemEntity _item(String name) => OrderItemEntity(
  id: 'i1',
  listingId: 'l1',
  listingName: name,
  listingImage: '',
  category: 'Books',
  condition: 'New',
  price: 150,
  quantity: 1,
  total: 150,
);

OrderEntity _order(String itemName) {
  final now = DateTime(2026, 7, 1);
  return OrderEntity(
    id: 'order_1',
    consumerId: 'consumer_1',
    consumerName: 'Test Buyer',
    consumerPhone: '+20 101 987 6543',
    vendorId: 'vendor_1',
    vendorName: 'Vendor',
    vendorStoreName: 'Store',
    items: [_item(itemName)],
    status: OrderStatus.pending,
    paymentMethod: PaymentMethod.cashOnDelivery,
    deliveryAddress: const OrderAddress(
      fullName: 'Test Buyer',
      phone: '+20 101 987 6543',
      street: '15 Abbas El Akkad St',
      city: 'Nasr City',
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

Widget _card(String itemName) => SingleChildScrollView(
  child: VendorOrderCard(
    order: _order(itemName),
    onConfirm: () {},
    onReject: () {},
    onProcessing: () {},
    onShipped: () {},
    onDelivered: () {},
  ),
);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final ar = lookupAppLocalizations(_ar);
  final en = lookupAppLocalizations(const Locale('en'));

  group('truncated titles take the direction of their first letter', () {
    const latin = 'Atomic Habits - James Clear Special Collector Edition';

    testWidgets('a Latin title in an Arabic card is laid out LTR', (
      tester,
    ) async {
      await tester.pumpWidget(_app(_card(latin), locale: _ar));
      final title = tester.widget<Text>(find.textContaining('Atomic Habits'));
      expect(title.textDirection, TextDirection.ltr);
      expect(title.overflow, TextOverflow.ellipsis);
    });

    testWidgets('an Arabic title stays RTL', (tester) async {
      await tester.pumpWidget(_app(_card('كتاب العادات الذرية'), locale: _ar));
      final title = tester.widget<Text>(find.textContaining('كتاب'));
      expect(title.textDirection, TextDirection.rtl);
    });

    testWidgets('English UI keeps a Latin title LTR', (tester) async {
      await tester.pumpWidget(_app(_card(latin)));
      final title = tester.widget<Text>(find.text(latin));
      expect(title.textDirection, TextDirection.ltr);
    });

    testWidgets('a title with no letters follows the ambient direction', (
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
      expect(ctx.textDirectionOf('2024'), TextDirection.rtl);
    });
  });

  group('one digit system in Arabic', () {
    testWidgets('vendor stats row uses Arabic-Indic digits', (tester) async {
      await tester.pumpWidget(
        _app(
          VendorOrderStatsBanner(
            pendingCount: 2,
            activeCount: 4,
            totalCount: 8,
            totalRevenue: 0,
            onConfirmAllPending: () {},
          ),
          locale: _ar,
        ),
      );
      expect(find.text('٢'), findsOneWidget);
      expect(find.text('٤'), findsOneWidget);
      expect(find.text('٨'), findsOneWidget);
    });

    testWidgets('English stays Latin; ratings keep one decimal', (
      tester,
    ) async {
      late BuildContext ctx;
      Widget probe() => Builder(
        builder: (c) {
          ctx = c;
          return const SizedBox();
        },
      );
      await tester.pumpWidget(_app(probe()));
      expect(ctx.formatDecimal(4.5), '4.5');
      expect(ctx.formatDecimal(4), '4.0');
      await tester.pumpWidget(_app(probe(), locale: _ar));
      await tester.pump();
      expect(ctx.formatDecimal(4.5), '٤٫٥');
      expect(ctx.formatDecimal(4), '٤٫٠');
    });

    test('count messages take the formatted string', () {
      expect(ar.cartSubtotalLine('٢'), contains('٢'));
      expect(ar.cartClearBody('٣'), contains('٣'));
      expect(ar.applyFiltersCount('٠'), contains('٠'));
      expect(ar.notificationsUnreadBannerLine('٢'), contains('٢'));
      expect(ar.cartShippingPaid('٥٠٠'), contains('٥٠٠'));
      expect(en.cartSubtotalLine('2'), contains('2'));
    });
  });

  testWidgets('vendor-list shipping sheet date field matches the text fields', (
    tester,
  ) async {
    await tester.pumpWidget(
      _app(
        ShippingInfoSheet(onConfirm: (_) async {}),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(OutlinedButton), findsOneWidget); // Cancel only
    final fields = find.byType(InputDecorator);
    expect(fields, findsNWidgets(3));
    final first = tester.getRect(fields.at(0));
    final date = tester.getRect(fields.at(2));
    expect(date.left, first.left);
    expect(date.width, first.width);
    expect(find.text(en.ordersEstimatedDeliveryLabel), findsOneWidget);
    // The label sits inside the field like the text fields' labels instead
    // of floating onto the top border.
    final label = tester.getRect(find.text(en.ordersEstimatedDeliveryLabel));
    expect(label.top, greaterThan(date.top));
    expect(label.bottom, lessThan(date.bottom));
    expect(find.byIcon(Icons.calendar_today_outlined), findsOneWidget);

    // The date still opens the picker.
    await tester.tap(fields.at(2));
    await tester.pumpAndSettle();
    expect(find.byType(DatePickerDialog), findsOneWidget);
  });
}
