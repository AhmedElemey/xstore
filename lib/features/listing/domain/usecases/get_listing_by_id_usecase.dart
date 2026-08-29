import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failures.dart';
import '../entities/listing_entity.dart';
import '../repositories/listing_repository.dart';

class GetListingByIdUseCase {
  const GetListingByIdUseCase(this._repository);

  final ListingRepository _repository;

  Future<Either<Failure, ListingEntity>> call(String id) =>
      _repository.getListingById(id);
}
