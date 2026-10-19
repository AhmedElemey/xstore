import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failures.dart';
import '../repositories/listing_repository.dart';

class DeactivateListingUseCase {
  const DeactivateListingUseCase(this._repository);

  final ListingRepository _repository;

  Future<Either<Failure, Unit>> call(String id) {
    return _repository.deactivateListing(id);
  }
}
