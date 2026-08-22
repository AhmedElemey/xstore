import 'package:flutter_test/flutter_test.dart';
import 'package:xstore/core/localization/app_localizations_en.dart';
import 'package:xstore/features/product/domain/entities/product_seller_entity.dart';
import 'package:xstore/shared/utils/public_seller_stats.dart';

void main() {
  final l10n = AppLocalizationsEn();

  test('omitted rating and sales show New seller, never 4.9 / 230', () {
    const seller = ProductSellerEntity(
      id: 'v1',
      name: 'Shop',
      avatarUrl: '',
    );
    expect(seller.hasPublicStats, isFalse);
    expect(seller.rating, isNull);
    expect(seller.salesCount, isNull);
    expect(publicSellerStatsLabel(l10n), l10n.newSeller);
  });

  test('real stats are shown when the API sends them', () {
    expect(
      publicSellerStatsLabel(l10n, rating: 4.2, sales: 12),
      '⭐ 4.2 · 12 ${l10n.statSalesShort}',
    );
  });
}
