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
  }) = _PaginatedResult<T>;
}
