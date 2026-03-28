import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failures.dart';
import '../../../listing/domain/entities/listing_entity.dart';
import '../repositories/home_repository.dart';

class GetNewArrivalsUseCase {
  const GetNewArrivalsUseCase(this._repository);

  final HomeRepository _repository;

  Future<Either<Failure, List<ListingEntity>>> call() =>
      _repository.getNewArrivals();
}
