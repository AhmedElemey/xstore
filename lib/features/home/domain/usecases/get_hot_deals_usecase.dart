import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failures.dart';
import '../entities/deal_entity.dart';
import '../repositories/home_repository.dart';

class GetHotDealsUseCase {
  const GetHotDealsUseCase(this._repository);

  final HomeRepository _repository;

  Future<Either<Failure, List<DealEntity>>> call() =>
      _repository.getHotDeals();
}
