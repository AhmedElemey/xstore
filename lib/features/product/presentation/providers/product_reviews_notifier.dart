import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../domain/entities/review_write_params.dart';
import 'product_dependencies.dart';
import 'product_reviews_state.dart';

part 'product_reviews_notifier.g.dart';

@riverpod
class ProductReviewsNotifier extends _$ProductReviewsNotifier {
  static const _pageSize = 20;

  // Set when this autoDispose notifier is torn down (screen popped) so
  // in-flight requests don't write state to a disposed notifier — that
  // throws an unhandled StateError.
  var _disposed = false;

  @override
  ProductReviewsState build(String listingId) {
    _disposed = false;
    ref.onDispose(() => _disposed = true);
    Future.microtask(refresh);
    return const ProductReviewsState(isLoading: true);
  }

  Future<void> refresh() async {
    if (_disposed) return;
    state = state.copyWith(isLoading: true, error: null);
    final result = await ref.read(getProductReviewsUseCaseProvider).call(
          productId: listingId,
          page: 0,
          pageSize: _pageSize,
        );
    if (_disposed) return;
    result.fold(
      (failure) =>
          state = state.copyWith(isLoading: false, error: failure.toString()),
      (page) => state = state.copyWith(
        isLoading: false,
        reviews: page.items,
        page: 0,
        hasMore: page.items.length >= _pageSize,
      ),
    );
  }

  Future<void> loadMore() async {
    if (state.isLoadingMore || !state.hasMore) return;
    state = state.copyWith(isLoadingMore: true);
    final next = state.page + 1;
    final result = await ref.read(getProductReviewsUseCaseProvider).call(
          productId: listingId,
          page: next,
          pageSize: _pageSize,
        );
    if (_disposed) return;
    result.fold(
      (failure) => state =
          state.copyWith(isLoadingMore: false, error: failure.toString()),
      (page) => state = state.copyWith(
        isLoadingMore: false,
        reviews: [...state.reviews, ...page.items],
        page: next,
        hasMore: page.items.length >= _pageSize,
      ),
    );
  }

  Future<bool> submitReview(
    ReviewWriteParams params, {
    String? editingReviewId,
  }) async {
    state = state.copyWith(isSubmitting: true, error: null);
    final result = editingReviewId == null
        ? await ref
            .read(createReviewUseCaseProvider)
            .call(listingId: listingId, params: params)
        : await ref.read(updateReviewUseCaseProvider).call(
              listingId: listingId,
              reviewId: editingReviewId,
              params: params,
            );
    if (_disposed) return false;
    return result.fold(
      (failure) {
        state = state.copyWith(isSubmitting: false, error: failure.toString());
        return false;
      },
      (_) {
        state = state.copyWith(isSubmitting: false);
        unawaited(refresh());
        return true;
      },
    );
  }

  Future<void> deleteReview(String reviewId) async {
    final result = await ref
        .read(deleteReviewUseCaseProvider)
        .call(listingId: listingId, reviewId: reviewId);
    if (_disposed) return;
    result.fold(
      (failure) => state = state.copyWith(error: failure.toString()),
      (_) => state = state.copyWith(
        reviews: state.reviews.where((r) => r.id != reviewId).toList(),
      ),
    );
  }
}
