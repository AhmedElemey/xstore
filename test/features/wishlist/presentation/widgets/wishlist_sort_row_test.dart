// Regression test for the wishlist filter/sort row redesign: the separate
// "Price Drop ▾" dropdown (opening a bottom sheet) was removed and its
// remaining sort options were merged into the same horizontally scrolling
// chip row as the filter chips. "Recently Added", "Price Drop" (the sort,
// distinct from the "Price Dropped" filter chip) and "Biggest Discount"
// sort options were deleted outright, not moved.
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:xstore/core/localization/app_localizations.dart';
import 'package:xstore/features/wishlist/domain/entities/wishlist_item_entity.dart';
import 'package:xstore/features/wishlist/presentation/providers/wishlist_provider.dart';
import 'package:xstore/features/wishlist/presentation/providers/wishlist_state.dart';
import 'package:xstore/features/wishlist/presentation/widgets/wishlist_sort_row.dart';

class _FakeWishlist extends Wishlist {
  _FakeWishlist(this._initial);
  final WishlistState _initial;

  @override
  WishlistState build() => _initial;
}

WishlistItemEntity _item({
  required String id,
  required String name,
  required double price,
}) => WishlistItemEntity(
  id: id,
  listingId: id,
  listingName: name,
  listingImages: const [],
  vendorId: 'vendor_1',
  vendorName: 'Ahmed',
  vendorStoreName: 'Ahmed Store',
  price: price,
  category: 'Electronics',
  condition: 'New',
  addedAt: DateTime(2026, 1, 1),
  lastPriceCheckAt: DateTime(2026, 1, 1),
);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Future<ProviderContainer> pumpRow(WidgetTester tester) async {
    final items = [
      _item(id: '1', name: 'Zebra Print Scarf', price: 300),
      _item(id: '2', name: 'Amber Necklace', price: 100),
      _item(id: '3', name: 'Blue Mug', price: 200),
    ];
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          wishlistProvider.overrideWith(
            () => _FakeWishlist(
              WishlistState(items: items, filteredItems: items),
            ),
          ),
        ],
        child: const MaterialApp(
          localizationsDelegates: [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(body: WishlistSortRow()),
        ),
      ),
    );
    await tester.pump();
    return ProviderScope.containerOf(
      tester.element(find.byType(WishlistSortRow)),
      listen: false,
    );
  }

  testWidgets(
    'the dropdown is gone; filter and remaining sort options share one row',
    (tester) async {
      await pumpRow(tester);

      // The old dropdown button/chevron no longer exists.
      expect(find.byIcon(Icons.keyboard_arrow_down_rounded), findsNothing);

      // Filter chips are still present.
      expect(find.text('All'), findsOneWidget);
      expect(find.text('Available'), findsOneWidget);
      expect(find.text('Price Dropped'), findsOneWidget);
      expect(find.text('In Cart'), findsOneWidget);

      // Remaining sort options now render as chips in the same row.
      expect(find.text('Price: Low to High'), findsOneWidget);
      expect(find.text('Price: High to Low'), findsOneWidget);
      expect(find.text('Name A–Z'), findsOneWidget);

      // Deleted sort options must not appear anywhere.
      expect(find.text('Recently Added'), findsNothing);
      expect(find.text('Biggest Discount'), findsNothing);
      // The deleted sort's exact label ("Price Drop", no trailing "ped") —
      // distinct from the still-present "Price Dropped" FILTER chip.
      expect(find.text('Price Drop'), findsNothing);
    },
  );

  testWidgets('tapping a sort chip actually applies that sort', (
    tester,
  ) async {
    final container = await pumpRow(tester);
    expect(
      container.read(wishlistProvider).sortOption,
      WishlistSortOption.priceLowToHigh,
    );

    final highToLowChip = find.text('Price: High to Low');
    await tester.ensureVisible(highToLowChip);
    await tester.pump();
    await tester.tap(highToLowChip);
    await tester.pump();

    expect(
      container.read(wishlistProvider).sortOption,
      WishlistSortOption.priceHighToLow,
    );
    final ordered = container.read(wishlistProvider).filteredItems;
    expect(ordered.map((e) => e.price).toList(), [300, 200, 100]);
  });
}
