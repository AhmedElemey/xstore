import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failures.dart';
import '../entities/review_entity.dart';
import '../repositories/product_repository.dart';

class GetProductReviewsUseCase {
  const GetProductReviewsUseCase(this._repository);

  final ProductRepository _repository;

  Future<Either<Failure, List<ReviewEntity>>> call(String productId) =>
      _repository.getProductReviews(productId);
}
