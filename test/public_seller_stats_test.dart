import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:xstore/core/localization/app_localizations.dart';
import 'package:xstore/features/product/domain/entities/product_seller_entity.dart';
import 'package:xstore/shared/utils/public_seller_stats.dart';

Future<String> _label(
  WidgetTester tester, {
  Locale locale = const Locale('en'),
  double? rating,
  int? sales,
}) async {
  late String label;
  await tester.pumpWidget(
    MaterialApp(
      locale: locale,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      home: Builder(
        builder: (context) {
          label = publicSellerStatsLabel(context, rating: rating, sales: sales);
          return const SizedBox();
        },
      ),
    ),
  );
  return label;
}

void main() {
  final l10n = lookupAppLocalizations(const Locale('en'));

  testWidgets('omitted rating and sales show New seller, never 4.9 / 230', (
    tester,
  ) async {
    const seller = ProductSellerEntity(
      id: 'v1',
      name: 'Shop',
      avatarUrl: '',
    );
    expect(seller.rating, isNull);
    expect(seller.salesCount, isNull);
    expect(await _label(tester), l10n.newSeller);
  });

  testWidgets('real stats are shown when the API sends them', (tester) async {
    expect(
      await _label(tester, rating: 4.2, sales: 12),
      '⭐ 4.2 · 12 ${l10n.statSalesShort}',
    );
  });

  testWidgets('Arabic shows Arabic-Indic digits like the prices', (
    tester,
  ) async {
    final ar = lookupAppLocalizations(const Locale('ar'));
    expect(
      await _label(tester, locale: const Locale('ar'), rating: 4.8, sales: 142),
      '⭐ ٤٫٨ · ١٤٢ ${ar.statSalesShort}',
    );
  });
}
