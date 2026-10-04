import 'package:flutter_test/flutter_test.dart';
import 'package:xstore/features/explore/data/models/search_result_model.dart';

void main() {
  group('SearchResultModel.fromListingLike isSoldOut', () {
    Map<String, dynamic> listing([Map<String, dynamic> extra = const {}]) =>
        {'id': 7, 'title': 'PS5', 'price': 100, ...extra};

    test('is true for an explicit stockQuantity of 0', () {
      final m = SearchResultModel.fromListingLike(listing({'stockQuantity': 0}));
      expect(m.isSoldOut, isTrue);
      expect(m.toEntity().isSoldOut, isTrue);
    });

    test('is false when stock is positive or missing', () {
      expect(
        SearchResultModel.fromListingLike(listing({'stockQuantity': 2})).isSoldOut,
        isFalse,
      );
      expect(SearchResultModel.fromListingLike(listing()).isSoldOut, isFalse);
    });
  });
}
