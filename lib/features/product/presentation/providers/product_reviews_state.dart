import 'package:freezed_annotation/freezed_annotation.dart';

import '../../domain/entities/review_entity.dart';

part 'product_reviews_state.freezed.dart';

@freezed
class ProductReviewsState with _$ProductReviewsState {
  const factory ProductReviewsState({
    @Default(<ReviewEntity>[]) List<ReviewEntity> reviews,
    @Default(0) int page,
    @Default(true) bool hasMore,
    @Default(false) bool isLoading,
    @Default(false) bool isLoadingMore,
    @Default(false) bool isSubmitting,
    String? error,
  }) = _ProductReviewsState;
}
