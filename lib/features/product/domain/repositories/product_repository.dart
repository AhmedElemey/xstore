import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failures.dart';
import '../entities/product_detail_entity.dart';
import '../entities/review_entity.dart';

abstract interface class ProductRepository {
  Future<Either<Failure, ProductDetailEntity>> getProductDetail(String id);

  Future<Either<Failure, List<ProductDetailEntity>>> getSimilarProducts({
    required String productId,
    required String category,
  });

  Future<Either<Failure, List<ReviewEntity>>> getProductReviews(String productId);
}
