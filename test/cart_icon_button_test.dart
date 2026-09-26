// The add-to-cart control on product cards is a cart icon only; it turns
// green once that listing is in the cart.

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lucide_icons/lucide_icons.dart';

import 'package:xstore/core/constants/app_colors.dart';
import 'package:xstore/core/localization/app_localizations.dart';
import 'package:xstore/features/cart/domain/entities/cart_item_entity.dart';
import 'package:xstore/features/cart/presentation/providers/cart_provider.dart';
import 'package:xstore/features/cart/presentation/providers/cart_state.dart';
import 'package:xstore/shared/widgets/cart_icon_button.dart';

class _FakeCart extends Cart {
  _FakeCart(this._state);

  final CartState _state;

  @override
  CartState build() => _state;
}

CartItemEntity _item(String listingId) => CartItemEntity(
      id: 'line_$listingId',
      listingId: listingId,
      listingName: 'Earbuds',
      listingImage: '',
      vendorId: 'v1',
      vendorName: 'Ahmed',
      vendorStoreName: 'Ahmed Store',
      price: 500,
      quantity: 1,
      maxQuantity: 5,
      category: 'Electronics',
      condition: 'New',
      addedAt: DateTime(2026, 9, 1),
    );

Future<Color?> _iconColor(WidgetTester tester, CartState cart) async {
  var taps = 0;
  await tester.pumpWidget(
    ProviderScope(
      overrides: [cartProvider.overrideWith(() => _FakeCart(cart))],
      child: MaterialApp(
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: CartIconButton(listingId: 'l1', onPressed: () => taps++),
        ),
      ),
    ),
  );
  await tester.tap(find.byType(CartIconButton));
  expect(taps, 1);
  expect(find.byType(Text), findsNothing, reason: 'icon only, no label');
  return tester.widget<Icon>(find.byIcon(LucideIcons.shoppingCart)).color;
}

void main() {
  testWidgets('cart icon is not green when the listing is not in the cart',
      (tester) async {
    final color = await _iconColor(
      tester,
      CartState(items: [_item('other')]),
    );
    expect(color, isNot(AppColors.success));
  });

  testWidgets('cart icon turns green when the listing is in the cart',
      (tester) async {
    final color = await _iconColor(tester, CartState(items: [_item('l1')]));
    expect(color, AppColors.success);
  });
}
