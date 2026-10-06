import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:xstore/core/localization/app_localizations.dart';

void main() {
  test('price-drop banner pluralises in en and ar', () {
    final en = lookupAppLocalizations(const Locale('en'));
    expect(en.wishlistPriceDropBanner(1), contains('1 item '));
    expect(en.wishlistPriceDropBanner(3), contains('3 items'));
    final ar = lookupAppLocalizations(const Locale('ar'));
    expect(ar.wishlistPriceDropBanner(1), contains('منتج واحد'));
    expect(ar.wishlistPriceDropBanner(2), contains('منتجين'));
    expect(ar.wishlistPriceDropBanner(5), contains('5 منتجات'));
    expect(ar.wishlistPriceDropBanner(11), contains('11 منتج'));
  });
}
