import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failures.dart';
import '../entities/banner_entity.dart';
import '../repositories/home_repository.dart';

class GetBannersUseCase {
  const GetBannersUseCase(this._repository);

  final HomeRepository _repository;

  Future<Either<Failure, List<BannerEntity>>> call() =>
      _repository.getBanners();
}
