import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:xstore/core/localization/app_localizations.dart';

void main() {
  test('price-drop banner pluralises in en and ar', () {
    final en = lookupAppLocalizations(const Locale('en'));
    expect(en.wishlistPriceDropBanner(1, '1'), contains('1 item '));
    expect(en.wishlistPriceDropBanner(3, '3'), contains('3 items'));
    final ar = lookupAppLocalizations(const Locale('ar'));
    expect(ar.wishlistPriceDropBanner(1, '1'), contains('منتج واحد'));
    expect(ar.wishlistPriceDropBanner(2, '2'), contains('منتجين'));
    expect(ar.wishlistPriceDropBanner(5, '5'), contains('5 منتجات'));
    expect(ar.wishlistPriceDropBanner(11, '11'), contains('11 منتج'));
  });

  test('plural rule follows the int, the digits follow the text placeholder', () {
    final ar = lookupAppLocalizations(const Locale('ar'));
    expect(ar.wishlistPriceDropBanner(5, '٥'), contains('٥ منتجات'));
    expect(ar.wishlistPriceDropBanner(11, '١١'), contains('١١ منتج'));
    expect(ar.courierItemsSummary(4, '٤', '٩٠ ج.م'), contains('٤ منتجات'));
    expect(ar.courierItemsSummary(1, '١', '٩٠ ج.م'), contains('منتج واحد'));
  });
}
