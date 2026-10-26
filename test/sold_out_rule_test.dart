import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:xstore/core/localization/app_localizations.dart';
import 'package:xstore/features/home/presentation/widgets/new_arrivals_grid.dart';
import 'package:xstore/features/listing/data/models/listing_model.dart';
import 'package:xstore/features/listing/domain/entities/listing_entity.dart';

ListingEntity _listing({required int stock}) => ListingEntity(
  id: '1',
  title: 'Keyboard',
  description: 'Keyboard',
  price: 100,
  status: ListingStatus.active,
  stockQuantity: stock,
);

void main() {
  group('isSoldOutListing', () {
    test('known stock <= 0 is sold out', () {
      expect(isSoldOutListing(stock: 0), isTrue);
      expect(isSoldOutListing(stock: -1), isTrue);
    });

    test('missing or positive stock is available', () {
      expect(isSoldOutListing(), isFalse);
      expect(isSoldOutListing(stock: 1), isFalse);
    });
  });

  group('isSoldOutListingJson', () {
    test('uses the same rule', () {
      expect(isSoldOutListingJson({'status': 2}), isFalse);
      expect(isSoldOutListingJson({'status': 2, 'stockQuantity': 0}), isTrue);
      expect(isSoldOutListingJson({'status': 2, 'stock': '3'}), isFalse);
      expect(isSoldOutListingJson({'status': 'sold'}), isFalse);
    });
  });

  for (final (stock, soldOut) in [(0, true), (3, false)]) {
    testWidgets(
      'a listing with stock $stock ${soldOut ? 'is' : 'is not'} greyed on the card',
      (tester) async {
        await tester.pumpWidget(
          ProviderScope(
            child: MaterialApp(
              localizationsDelegates: const [
                AppLocalizations.delegate,
                GlobalMaterialLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
                GlobalCupertinoLocalizations.delegate,
              ],
              supportedLocales: AppLocalizations.supportedLocales,
              home: Scaffold(
                body: NewArrivalsGrid(items: [_listing(stock: stock)]),
              ),
            ),
          ),
        );
        await tester.pump(const Duration(seconds: 1));

        expect(find.text('Sold out'), soldOut ? findsOneWidget : findsNothing);
      },
    );
  }
}
