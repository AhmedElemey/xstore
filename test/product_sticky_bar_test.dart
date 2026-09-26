// The product bar's "Add to cart" label once truncated on narrow screens
// ("Add to ..."). The bar is now a quantity stepper plus Add to cart, with
// Buy now in ProductActionsRow; both labels must still render in full.

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:xstore/core/localization/app_localizations.dart';
import 'package:xstore/features/product/presentation/widgets/product_sticky_bar.dart';

void main() {
  Future<void> pumpBar(WidgetTester tester, {required Size size}) async {
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
                  onBuyNow: () {},
                  stockLeft: 3,
                ),
                ProductStickyBar(
                  onAddToCart: () {},
                  isAddingToCart: false,
                  quantity: 1,
                  maxQuantity: 3,
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
}
