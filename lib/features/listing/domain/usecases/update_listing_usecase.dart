import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failures.dart';
import '../entities/listing_entity.dart';
import '../repositories/listing_repository.dart';

class UpdateListingUseCase {
  const UpdateListingUseCase(this._repository);

  final ListingRepository _repository;

  Future<Either<Failure, ListingEntity>> call({
    required String id,
    required String title,
    required String description,
    required double price,
    required ListingStatus status,
  }) {
    return _repository.updateListing(
      id: id,
      title: title,
      description: description,
      price: price,
      status: status,
    );
  }
}
