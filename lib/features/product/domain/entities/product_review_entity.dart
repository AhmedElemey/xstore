import 'package:freezed_annotation/freezed_annotation.dart';

part 'product_review_entity.freezed.dart';

@freezed
class ReviewSummaryEntity with _$ReviewSummaryEntity {
  const factory ReviewSummaryEntity({
    required double average,
    required int totalCount,
    /// Index 0 = 5★ count, index 4 = 1★ count.
    @Default([0, 0, 0, 0, 0]) List<int> starCounts,
  }) = _ReviewSummaryEntity;
}

@freezed
class ProductReviewEntity with _$ProductReviewEntity {
  const factory ProductReviewEntity({
    required String id,
    required String userName,
    String? userAvatarUrl,
    required DateTime date,
    required double stars,
    required String text,
    @Default(0) int helpfulCount,
  }) = _ProductReviewEntity;
}
