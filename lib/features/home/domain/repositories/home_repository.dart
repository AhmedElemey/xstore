import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failures.dart';
import '../entities/banner_entity.dart';
import '../entities/category_entity.dart';
import '../../../listing/domain/entities/listing_entity.dart';
import '../entities/deal_entity.dart';

/// The three listing carousels on Home. All come from one `GET /api/home`
/// call, so they load together.
typedef HomeFeed = ({
  List<DealEntity> hotDeals,
  List<ListingEntity> newArrivals,
  List<ListingEntity> recommended,
});

abstract interface class HomeRepository {
  Future<Either<Failure, List<BannerEntity>>> getBanners();

  Future<Either<Failure, List<CategoryEntity>>> getCategories();

  /// Hot deals, new arrivals (sorted by `postedAt` desc) and recommended
  /// picks. A section the aggregate leaves empty is derived from hot deals.
  Future<Either<Failure, HomeFeed>> getHomeFeed();
}
