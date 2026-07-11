import 'package:flutter_test/flutter_test.dart';
import 'package:xstore/features/listing/data/models/listing_model.dart';
import 'package:xstore/features/listing/domain/entities/listing_entity.dart';

void main() {
  group('ListingCondition wire mapping (backend C# enum, 1-based)', () {
    test('wire codes match the backend enum exactly', () {
      // public enum ListingCondition { New=1, LikeNew=2, Good=3, UsedForParts=4 }
      expect(listingConditionToWire(ListingCondition.newItem), 1);
      expect(listingConditionToWire(ListingCondition.likeNew), 2);
      expect(listingConditionToWire(ListingCondition.good), 3);
      expect(listingConditionToWire(ListingCondition.usedForParts), 4);
    });

    test('every condition round-trips wire → enum → wire', () {
      for (final c in ListingCondition.values) {
        final wire = listingConditionToWire(c);
        expect(listingConditionFromToken('$wire'), c,
            reason: 'wire code $wire should parse back to $c');
      }
    });

    test('0 means unset on the backend and parses to null', () {
      expect(listingConditionFromToken('0'), isNull);
      expect(listingConditionLabelFromRaw(0), '');
      expect(listingConditionLabelFromRaw(null), '');
    });

    test('numeric raw values become display tokens, not digits', () {
      expect(listingConditionLabelFromRaw(1), 'New');
      expect(listingConditionLabelFromRaw(2), 'Like New');
      expect(listingConditionLabelFromRaw(3), 'Good');
      expect(listingConditionLabelFromRaw(4), 'Used / For Parts');
    });

    test('legacy draft tokens map onto the merged backend value', () {
      expect(
        listingConditionFromToken('Used'),
        ListingCondition.usedForParts,
      );
      expect(
        listingConditionFromToken('For Parts'),
        ListingCondition.usedForParts,
      );
      expect(
        listingConditionFromToken('Used / For Parts'),
        ListingCondition.usedForParts,
      );
      expect(
        listingConditionFromToken('UsedForParts'),
        ListingCondition.usedForParts,
      );
    });

    test('display token set stays 1:1 with the enum', () {
      final labels = ListingCondition.values.map(listingConditionLabel);
      expect(labels.toSet().length, ListingCondition.values.length);
      for (final c in ListingCondition.values) {
        expect(
          listingConditionFromToken(listingConditionLabel(c)),
          c,
          reason: 'label "${listingConditionLabel(c)}" should parse back',
        );
      }
    });
  });
}
