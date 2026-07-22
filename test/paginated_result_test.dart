import 'package:flutter_test/flutter_test.dart';
import 'package:xstore/core/network/paginated_result.dart';

void main() {
  group('PaginatedResultX.hasNextPage', () {
    test('uses totalPages when present (> 0)', () {
      const result = PaginatedResult<String>(
        items: ['a'],
        page: 0,
        pageSize: 20,
        totalCount: 50,
        totalPages: 3,
      );

      expect(result.hasNextPage(0), isTrue);
      expect(result.hasNextPage(1), isTrue);
      expect(result.hasNextPage(2), isFalse);
    });

    test('falls back to totalCount when totalPages is 0', () {
      final result = PaginatedResult<String>(
        items: List.filled(20, 'x'),
        page: 0,
        pageSize: 20,
        totalCount: 45,
      );

      expect(result.hasNextPage(0), isTrue);
      expect(result.hasNextPage(1), isTrue);
      expect(result.hasNextPage(2), isFalse);
    });

    test('falls back to page fullness when totalPages and totalCount are 0',
        () {
      final fullPage = PaginatedResult<String>(
        items: List.filled(20, 'x'),
        page: 0,
        pageSize: 20,
        totalCount: 0,
        totalPages: 0,
      );
      expect(fullPage.hasNextPage(0), isTrue);

      final partialPage = PaginatedResult<String>(
        items: ['only'],
        page: 0,
        pageSize: 20,
        totalCount: 0,
        totalPages: 0,
      );
      expect(partialPage.hasNextPage(0), isFalse);
    });
  });
}
