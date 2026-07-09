import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failures.dart';
import '../entities/review_entity.dart';
import '../entities/review_write_params.dart';
import '../repositories/product_repository.dart';

class UpdateReviewUseCase {
  const UpdateReviewUseCase(this._repository);

  final ProductRepository _repository;

  Future<Either<Failure, ReviewEntity>> call({
    required String listingId,
    required String reviewId,
    required ReviewWriteParams params,
  }) =>
      _repository.updateReview(
        listingId: listingId,
        reviewId: reviewId,
        params: params,
      );
}
