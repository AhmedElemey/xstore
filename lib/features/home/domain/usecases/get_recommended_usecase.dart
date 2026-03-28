import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failures.dart';
import '../../../listing/domain/entities/listing_entity.dart';
import '../repositories/home_repository.dart';

class GetRecommendedUseCase {
  const GetRecommendedUseCase(this._repository);

  final HomeRepository _repository;

  Future<Either<Failure, List<ListingEntity>>> call() =>
      _repository.getRecommended();
}
