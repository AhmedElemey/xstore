import 'package:xstore/core/network/paginated_result.dart';
import 'package:xstore/features/product/data/datasources/product_remote_datasource.dart';
import 'package:xstore/features/product/domain/entities/product_detail_entity.dart';
import 'package:xstore/features/product/domain/entities/review_entity.dart';
import 'package:xstore/features/product/domain/entities/review_write_params.dart';

/// Fake [ProductRemoteDataSource] for repository tests — same callback-
/// per-method, throw-if-unstubbed convention as the other stub datasources.
class StubProductRemoteDataSource implements ProductRemoteDataSource {
  StubProductRemoteDataSource({
    Future<ProductDetailEntity> Function(String listingId)? onFetchProductDetail,
    Future<List<ProductDetailEntity>> Function({
      required String productId,
      required String category,
    })? onFetchSimilarProducts,
    Future<PaginatedResult<ReviewEntity>> Function({
      required String listingId,
      required int page,
      required int pageSize,
    })? onFetchProductReviews,
    Future<ReviewEntity> Function({
      required String listingId,
      required ReviewWriteParams params,
    })? onCreateReview,
    Future<ReviewEntity> Function({
      required String listingId,
      required String reviewId,
      required ReviewWriteParams params,
    })? onUpdateReview,
    Future<void> Function({
      required String listingId,
      required String reviewId,
    })? onDeleteReview,
  })  : _onFetchProductDetail = onFetchProductDetail,
        _onFetchSimilarProducts = onFetchSimilarProducts,
        _onFetchProductReviews = onFetchProductReviews,
        _onCreateReview = onCreateReview,
        _onUpdateReview = onUpdateReview,
        _onDeleteReview = onDeleteReview;

  final Future<ProductDetailEntity> Function(String listingId)?
      _onFetchProductDetail;
  final Future<List<ProductDetailEntity>> Function({
    required String productId,
    required String category,
  })? _onFetchSimilarProducts;
  final Future<PaginatedResult<ReviewEntity>> Function({
    required String listingId,
    required int page,
    required int pageSize,
  })? _onFetchProductReviews;
  final Future<ReviewEntity> Function({
    required String listingId,
    required ReviewWriteParams params,
  })? _onCreateReview;
  final Future<ReviewEntity> Function({
    required String listingId,
    required String reviewId,
    required ReviewWriteParams params,
  })? _onUpdateReview;
  final Future<void> Function({
    required String listingId,
    required String reviewId,
  })? _onDeleteReview;

  @override
  Future<ProductDetailEntity> fetchProductDetail(String listingId) {
    final cb = _onFetchProductDetail;
    if (cb == null) throw UnimplementedError('fetchProductDetail not stubbed');
    return cb(listingId);
  }

  @override
  Future<List<ProductDetailEntity>> fetchSimilarProducts({
    required String productId,
    required String category,
  }) {
    final cb = _onFetchSimilarProducts;
    if (cb == null) {
      throw UnimplementedError('fetchSimilarProducts not stubbed');
    }
    return cb(productId: productId, category: category);
  }

  @override
  Future<PaginatedResult<ReviewEntity>> fetchProductReviews({
    required String listingId,
    required int page,
    required int pageSize,
  }) {
    final cb = _onFetchProductReviews;
    if (cb == null) {
      throw UnimplementedError('fetchProductReviews not stubbed');
    }
    return cb(listingId: listingId, page: page, pageSize: pageSize);
  }

  @override
  Future<ReviewEntity> createReview({
    required String listingId,
    required ReviewWriteParams params,
  }) {
    final cb = _onCreateReview;
    if (cb == null) throw UnimplementedError('createReview not stubbed');
    return cb(listingId: listingId, params: params);
  }

  @override
  Future<ReviewEntity> updateReview({
    required String listingId,
    required String reviewId,
    required ReviewWriteParams params,
  }) {
    final cb = _onUpdateReview;
    if (cb == null) throw UnimplementedError('updateReview not stubbed');
    return cb(listingId: listingId, reviewId: reviewId, params: params);
  }

  @override
  Future<void> deleteReview({
    required String listingId,
    required String reviewId,
  }) {
    final cb = _onDeleteReview;
    if (cb == null) throw UnimplementedError('deleteReview not stubbed');
    return cb(listingId: listingId, reviewId: reviewId);
  }
}
