import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failures.dart';
import '../entities/banner_entity.dart';
import '../entities/category_entity.dart';
import '../entities/deal_entity.dart';

abstract interface class HomeRepository {
  Future<Either<Failure, List<BannerEntity>>> getBanners();

  Future<Either<Failure, List<DealEntity>>> getHotDeals();

  Future<Either<Failure, List<CategoryEntity>>> getCategories();
}
