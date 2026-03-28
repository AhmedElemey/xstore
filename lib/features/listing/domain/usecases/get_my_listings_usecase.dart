import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failures.dart';
import '../entities/listing_entity.dart';
import '../repositories/listing_repository.dart';

class GetMyListingsUseCase {
  const GetMyListingsUseCase(this._repository);

  final ListingRepository _repository;

  Future<Either<Failure, List<ListingEntity>>> call() =>
      _repository.getMyListings();
}
