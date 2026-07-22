import 'package:freezed_annotation/freezed_annotation.dart';

part 'paginated_result.freezed.dart';

/// Shared paginated list envelope for reference-data lookups
/// (cities/governments/store categories). Plain `categories` has no
/// pagination in the API spec and returns a bare list instead.
@freezed
class PaginatedResult<T> with _$PaginatedResult<T> {
  const factory PaginatedResult({
    required List<T> items,
    required int page,
    required int pageSize,
    required int totalCount,
    @Default(0) int totalPages,
  }) = _PaginatedResult<T>;
}

extension PaginatedResultX<T> on PaginatedResult<T> {
  /// Whether another page likely exists. When [totalPages] is present (> 0),
  /// uses `currentPage + 1 < totalPages` (0-based page vs 1-based wire page
  /// count). Otherwise falls back to [totalCount], then page fullness.
  bool hasNextPage(int currentPage) {
    if (totalPages > 0) {
      return (currentPage + 1) < totalPages;
    }
    if (totalCount > 0) {
      return (currentPage + 1) * pageSize < totalCount;
    }
    return items.length >= pageSize;
  }
}
