// The product bar's "Add to cart" label once truncated on narrow screens
// ("Add to ..."). The bar is now a quantity stepper plus Add to cart, with
// Buy now in ProductActionsRow; both labels must still render in full.

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:xstore/core/localization/app_localizations.dart';
import 'package:xstore/features/product/presentation/widgets/product_sticky_bar.dart';

void main() {
  Future<void> pumpBar(
    WidgetTester tester, {
    required Size size,
    int stock = 3,
    VoidCallback? onAddToCart,
    VoidCallback? onBuyNow,
  }) async {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: Align(
            alignment: Alignment.bottomCenter,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ProductActionsRow(
                  onBuyNow: onBuyNow ?? () {},
                  stockLeft: stock,
                ),
                ProductStickyBar(
                  onAddToCart: onAddToCart ?? () {},
                  isAddingToCart: false,
                  quantity: 1,
                  maxQuantity: stock,
                  onDecrement: () {},
                  onIncrement: () {},
                ),
              ],
            ),
          ),
        ),
      ),
    );
    await tester.pump();
  }

  testWidgets(
    'on a narrow screen both button labels render in full, not ellipsized',
    (tester) async {
      await pumpBar(tester, size: const Size(320, 640));

      expect(find.text('Add to Cart'), findsOneWidget);
      expect(find.text('Buy now'), findsOneWidget);
      expect(find.textContaining('…'), findsNothing);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('a sold-out listing disables Add to cart and Buy now', (
    tester,
  ) async {
    var added = false;
    var bought = false;
    await pumpBar(
      tester,
      size: const Size(400, 800),
      stock: 0,
      onAddToCart: () => added = true,
      onBuyNow: () => bought = true,
    );

    expect(find.text('Add to Cart'), findsNothing);
    expect(find.text('Out of stock'), findsNWidgets(2));

    await tester.tap(find.text('Buy now'), warnIfMissed: false);
    // The last match is the Add to cart button's label.
    await tester.tap(find.text('Out of stock').last, warnIfMissed: false);
    await tester.pump();

    expect(added, isFalse);
    expect(bought, isFalse);
  });
}
