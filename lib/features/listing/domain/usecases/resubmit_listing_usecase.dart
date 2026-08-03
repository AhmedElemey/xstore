import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failures.dart';
import '../entities/listing_entity.dart';
import '../repositories/listing_repository.dart';

class ResubmitListingUseCase {
  const ResubmitListingUseCase(this._repository);

  final ListingRepository _repository;

  Future<Either<Failure, ListingEntity>> call({
    required String id,
    required double newPrice,
  }) {
    return _repository.resubmitListing(id: id, newPrice: newPrice);
  }
}
