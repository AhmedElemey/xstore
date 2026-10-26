import 'package:flutter_test/flutter_test.dart';
import 'package:xstore/features/listing/data/models/listing_model.dart';
import 'package:xstore/features/listing/domain/entities/listing_entity.dart';

// Backend C# declaration:
// public enum ListingStatus { Pending = 1, Active = 2, Rejected = 5, Cancelled = 6 }
ListingStatus _parse(Object? wire) => ListingModel.fromJson({
  'id': '1',
  'title': 'Lamp',
  'description': 'A lamp',
  'price': 10,
  'status': wire,
}).toEntity().status;

void main() {
  group('ListingStatus wire mapping', () {
    const wire = {
      ListingStatus.pending: 1,
      ListingStatus.active: 2,
      ListingStatus.rejected: 5,
      ListingStatus.cancelled: 6,
    };

    test('covers every enum member and mirrors the backend codes', () {
      expect(wire.keys.toSet(), ListingStatus.values.toSet());
      for (final e in wire.entries) {
        expect(listingStatusToWire(e.key), e.value);
      }
    });

    test('round-trips every member through the DTO', () {
      for (final e in wire.entries) {
        expect(_parse(e.value), e.key);
        expect(_parse(e.value.toString()), e.key);
      }
    });

    test('parses status names, including both cancelled spellings', () {
      expect(_parse('Pending'), ListingStatus.pending);
      expect(_parse('Active'), ListingStatus.active);
      expect(_parse('Rejected'), ListingStatus.rejected);
      expect(_parse('Cancelled'), ListingStatus.cancelled);
      expect(_parse('canceled'), ListingStatus.cancelled);
    });

    test('unknown or legacy codes fall back to pending', () {
      for (final code in [0, 3, 4, 99, 'draft', 'sold', 'garbage']) {
        expect(_parse(code), ListingStatus.pending, reason: '$code');
      }
    });

    test('a missing status parses as pending', () {
      expect(_parse(null), ListingStatus.pending);
    });
  });
}
