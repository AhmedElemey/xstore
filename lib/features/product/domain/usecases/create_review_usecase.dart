import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failures.dart';
import '../entities/review_entity.dart';
import '../entities/review_write_params.dart';
import '../repositories/product_repository.dart';

class CreateReviewUseCase {
  const CreateReviewUseCase(this._repository);

  final ProductRepository _repository;

  Future<Either<Failure, ReviewEntity>> call({
    required String listingId,
    required ReviewWriteParams params,
  }) =>
      _repository.createReview(listingId: listingId, params: params);
}
