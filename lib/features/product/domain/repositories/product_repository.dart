import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/network/paginated_result.dart';
import '../entities/product_detail_entity.dart';
import '../entities/review_entity.dart';
import '../entities/review_write_params.dart';

abstract interface class ProductRepository {
  Future<Either<Failure, ProductDetailEntity>> getProductDetail(String id);

  Future<Either<Failure, List<ProductDetailEntity>>> getSimilarProducts({
    required String productId,
    required String category,
  });

  Future<Either<Failure, PaginatedResult<ReviewEntity>>> getProductReviews({
    required String productId,
    required int page,
    required int pageSize,
  });

  Future<Either<Failure, ReviewEntity>> createReview({
    required String listingId,
    required ReviewWriteParams params,
  });

  Future<Either<Failure, ReviewEntity>> updateReview({
    required String listingId,
    required String reviewId,
    required ReviewWriteParams params,
  });

  Future<Either<Failure, Unit>> deleteReview({
    required String listingId,
    required String reviewId,
  });
}
