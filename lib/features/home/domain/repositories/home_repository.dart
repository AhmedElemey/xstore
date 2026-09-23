import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failures.dart';
import '../entities/banner_entity.dart';
import '../entities/category_entity.dart';
import '../../../listing/domain/entities/listing_entity.dart';
import '../entities/deal_entity.dart';

/// Every section GET /api/home carries, mapped once. Sections read this
/// first and only call their own getter below when their slice is empty.
typedef HomeFeed = ({
  List<BannerEntity> banners,
  List<DealEntity> hotDeals,
  List<ListingEntity> newArrivals,
  List<ListingEntity> recommended,
});

abstract interface class HomeRepository {
  /// One GET /api/home for all sections; null when it failed or came back
  /// empty, so callers fall back to the per-section getters.
  Future<HomeFeed?> getHomeFeed();

  Future<Either<Failure, List<BannerEntity>>> getBanners();

  Future<Either<Failure, List<DealEntity>>> getHotDeals();

  Future<Either<Failure, List<CategoryEntity>>> getCategories();

  /// Latest listings (mock: derived from hot deals), sorted by `postedAt` desc.
  Future<Either<Failure, List<ListingEntity>>> getNewArrivals();

  /// Personalized picks (mock: same pool as hot deals).
  Future<Either<Failure, List<ListingEntity>>> getRecommended();
}
