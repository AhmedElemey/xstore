import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failures.dart';
import '../repositories/listing_repository.dart';

class DeleteListingUseCase {
  const DeleteListingUseCase(this._repository);

  final ListingRepository _repository;

  Future<Either<Failure, Unit>> call(String id) =>
      _repository.deleteListing(id);
}
