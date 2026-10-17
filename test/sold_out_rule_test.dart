import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:xstore/core/localization/app_localizations.dart';
import 'package:xstore/features/home/presentation/widgets/new_arrivals_grid.dart';
import 'package:xstore/features/listing/data/models/listing_model.dart';
import 'package:xstore/features/listing/domain/entities/listing_entity.dart';

ListingEntity _listing(ListingStatus status) => ListingEntity(
  id: '1',
  title: 'Keyboard',
  description: 'Keyboard',
  price: 100,
  status: status,
);

void main() {
  group('isSoldOutListing', () {
    test('status sold is sold out whatever the stock', () {
      expect(isSoldOutListing(status: ListingStatus.sold), isTrue);
      expect(isSoldOutListing(status: ListingStatus.sold, stock: 5), isTrue);
    });

    test('known stock <= 0 is sold out', () {
      expect(isSoldOutListing(status: ListingStatus.active, stock: 0), isTrue);
      expect(isSoldOutListing(stock: -1), isTrue);
    });

    test('missing stock is available', () {
      expect(isSoldOutListing(status: ListingStatus.active), isFalse);
      expect(isSoldOutListing(), isFalse);
      expect(isSoldOutListing(status: ListingStatus.active, stock: 1), isFalse);
    });
  });

  group('isSoldOutListingJson', () {
    test('uses the same rule', () {
      expect(isSoldOutListingJson({'status': 2}), isFalse);
      expect(isSoldOutListingJson({'status': 2, 'stockQuantity': 0}), isTrue);
      expect(isSoldOutListingJson({'status': 2, 'stock': '3'}), isFalse);
      expect(isSoldOutListingJson({'status': 4, 'stockQuantity': 3}), isTrue);
      expect(isSoldOutListingJson({'status': 'sold'}), isTrue);
    });
  });

  for (final (status, soldOut) in [
    (ListingStatus.sold, true),
    (ListingStatus.active, false),
  ]) {
    testWidgets(
      'a ${status.name} listing ${soldOut ? 'is' : 'is not'} greyed on the card',
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
              home: Scaffold(body: NewArrivalsGrid(items: [_listing(status)])),
            ),
          ),
        );
        await tester.pump(const Duration(seconds: 1));

        expect(find.text('Sold out'), soldOut ? findsOneWidget : findsNothing);
      },
    );
  }
}
