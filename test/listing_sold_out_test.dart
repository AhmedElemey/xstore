import 'package:flutter_test/flutter_test.dart';
import 'package:xstore/features/listing/data/models/listing_model.dart';

void main() {
  test('zero or negative stock is sold out', () {
    expect(isListingSoldOut({'stockQuantity': 0}), isTrue);
    expect(isListingSoldOut({'stock': '0'}), isTrue);
    expect(isListingSoldOut({'stockQuantity': -1}), isTrue);
  });

  test('isAvailable false is sold out regardless of stock', () {
    expect(isListingSoldOut({'isAvailable': false, 'stockQuantity': 4}), isTrue);
  });

  test('positive stock or a missing stock field keeps the tile', () {
    expect(isListingSoldOut({'stockQuantity': 3}), isFalse);
    expect(isListingSoldOut({'id': '1', 'title': 'Summary DTO'}), isFalse);
  });
}
