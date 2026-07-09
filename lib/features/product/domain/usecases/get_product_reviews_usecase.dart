import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/network/paginated_result.dart';
import '../entities/review_entity.dart';
import '../repositories/product_repository.dart';

class GetProductReviewsUseCase {
  const GetProductReviewsUseCase(this._repository);

  final ProductRepository _repository;

  Future<Either<Failure, PaginatedResult<ReviewEntity>>> call({
    required String productId,
    required int page,
    required int pageSize,
  }) =>
      _repository.getProductReviews(
        productId: productId,
        page: page,
        pageSize: pageSize,
      );
}
