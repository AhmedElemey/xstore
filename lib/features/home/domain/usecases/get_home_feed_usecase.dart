import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failures.dart';
import '../repositories/home_repository.dart';

class GetHomeFeedUseCase {
  const GetHomeFeedUseCase(this._repository);

  final HomeRepository _repository;

  Future<Either<Failure, HomeFeed>> call() => _repository.getHomeFeed();
}
