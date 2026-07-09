import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failures.dart';
import '../repositories/product_repository.dart';

class DeleteReviewUseCase {
  const DeleteReviewUseCase(this._repository);

  final ProductRepository _repository;

  Future<Either<Failure, Unit>> call({
    required String listingId,
    required String reviewId,
  }) =>
      _repository.deleteReview(listingId: listingId, reviewId: reviewId);
}
