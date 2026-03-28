import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failures.dart';
import '../entities/listing_entity.dart';
import '../repositories/listing_repository.dart';

class CreateListingUseCase {
  const CreateListingUseCase(this._repository);

  final ListingRepository _repository;

  Future<Either<Failure, ListingEntity>> call({
    required String title,
    required String description,
    required double price,
    required List<String> imagePaths,
  }) {
    return _repository.createListing(
      title: title,
      description: description,
      price: price,
      imagePaths: imagePaths,
    );
  }
}
