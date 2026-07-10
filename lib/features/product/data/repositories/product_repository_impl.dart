import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/network/paginated_result.dart';
import '../datasources/product_remote_datasource.dart';
import '../../domain/entities/product_detail_entity.dart';
import '../../domain/entities/review_entity.dart';
import '../../domain/entities/review_write_params.dart';
import '../../domain/repositories/product_repository.dart';

class ProductRepositoryImpl implements ProductRepository {
  ProductRepositoryImpl({required ProductRemoteDataSource remote})
      : _remote = remote;

  final ProductRemoteDataSource _remote;

  @override
  Future<Either<Failure, ProductDetailEntity>> getProductDetail(String id) async {
    try {
      return Right(await _remote.fetchProductDetail(id));
    } catch (e) {
      return Left(Failure.server(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<ProductDetailEntity>>> getSimilarProducts({
    required String productId,
    required String category,
  }) async {
    try {
      return Right(
        await _remote.fetchSimilarProducts(
          productId: productId,
          category: category,
        ),
      );
    } catch (e) {
      return Left(Failure.server(e.toString()));
    }
  }

  @override
  Future<Either<Failure, PaginatedResult<ReviewEntity>>> getProductReviews({
    required String productId,
    required int page,
    required int pageSize,
  }) async {
    try {
      return Right(
        await _remote.fetchProductReviews(
          listingId: productId,
          page: page,
          pageSize: pageSize,
        ),
      );
    } catch (e) {
      return Left(Failure.server(e.toString()));
    }
  }

  @override
  Future<Either<Failure, ReviewEntity>> createReview({
    required String listingId,
    required ReviewWriteParams params,
  }) async {
    try {
      return Right(
        await _remote.createReview(listingId: listingId, params: params),
      );
    } catch (e) {
      return Left(Failure.server(e.toString()));
    }
  }

  @override
  Future<Either<Failure, ReviewEntity>> updateReview({
    required String listingId,
    required String reviewId,
    required ReviewWriteParams params,
  }) async {
    try {
      return Right(
        await _remote.updateReview(
          listingId: listingId,
          reviewId: reviewId,
          params: params,
        ),
      );
    } catch (e) {
      return Left(Failure.server(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Unit>> deleteReview({
    required String listingId,
    required String reviewId,
  }) async {
    try {
      await _remote.deleteReview(listingId: listingId, reviewId: reviewId);
      return const Right(unit);
    } catch (e) {
      return Left(Failure.server(e.toString()));
    }
  }
}
