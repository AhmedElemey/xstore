import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:xstore/features/listing/presentation/widgets/listing_thumbnail.dart';

void main() {
  testWidgets(
    'network thumbnail with infinite width does not throw Infinity toInt',
    (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Center(
            child: SizedBox(
              width: 180,
              height: 140,
              child: ListingThumbnail(
                imageUrl: 'https://example.com/listing.png',
                width: double.infinity,
                height: 140,
              ),
            ),
          ),
        ),
      );
      expect(tester.takeException(), isNull);
      expect(find.byType(ListingThumbnail), findsOneWidget);
    },
  );
}
