import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:xstore/core/localization/app_localizations.dart';
import 'package:xstore/features/auth/presentation/providers/auth_provider.dart';
import 'package:xstore/features/explore/domain/entities/search_result_entity.dart';
import 'package:xstore/features/explore/presentation/widgets/product_grid_card.dart';
import 'package:xstore/features/explore/presentation/widgets/product_list_card.dart';

import '../../../../helpers/fake_async_auth_notifier.dart';

SearchResultEntity _item({double? compareAtPrice}) => SearchResultEntity(
  id: 'l1',
  name: 'Earbuds',
  price: 500,
  compareAtPrice: compareAtPrice,
  condition: 'New',
  category: 'Electronics',
  rating: 4,
  reviewCount: 2,
  sellerName: 'Ahmed Store',
  isSellerVerified: false,
  location: 'Cairo',
  hasShipping: true,
);

final _struckThrough = find.byWidgetPredicate(
  (w) => w is Text && w.style?.decoration == TextDecoration.lineThrough,
);

// ProviderScope: the cards embed WishHeartButton.
Widget _wrap(Widget child) => ProviderScope(
  overrides: [authProvider.overrideWith(() => FakeAuth(null))],
  child: MaterialApp(
    localizationsDelegates: const [
      AppLocalizations.delegate,
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
    ],
    supportedLocales: AppLocalizations.supportedLocales,
    // Explore's real layouts: a 0.58-ratio grid cell, or a list row.
    home: Scaffold(body: ListView(children: [child])),
  ),
);

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
    FlutterSecureStorage.setMockInitialValues({});
  });

  final cards = <String, Widget Function(SearchResultEntity)>{
    'grid': (item) => SizedBox(
      width: 180,
      height: 180 / 0.58,
      child: ProductGridCard(
        item: item,
        onAddToCart: () {},
        showAddToCart: false,
        onTap: () {},
      ),
    ),
    'list': (item) => ProductListCard(
      item: item,
      onAddToCart: () {},
      showAddToCart: false,
      onTap: () {},
    ),
  };

  for (final entry in cards.entries) {
    group('${entry.key} card compare-at price', () {
      for (final (compareAt, shown) in [
        (null, false),
        (500.0, false),
        (400.0, false),
        (650.0, true),
      ]) {
        testWidgets(
          '${shown ? 'shows' : 'hides'} the struck-through price when '
          'compareAt=$compareAt and price=500',
          (tester) async {
            await tester.pumpWidget(
              _wrap(entry.value(_item(compareAtPrice: compareAt))),
            );
            await tester.pump();

            expect(_struckThrough, shown ? findsOneWidget : findsNothing);

            // Let the heart button's provider timers finish before teardown.
            await tester.pumpWidget(const SizedBox());
            await tester.pump(const Duration(seconds: 5));
          },
        );
      }
    });
  }
}
