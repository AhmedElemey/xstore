import 'package:fpdart/fpdart.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../../listing/domain/entities/listing_entity.dart';
import '../../domain/entities/banner_entity.dart';
import '../../domain/entities/category_entity.dart';
import '../../domain/entities/deal_entity.dart';
import '../../domain/repositories/home_repository.dart';
import '../datasources/home_remote_datasource.dart';
import '../models/banner_model.dart';
import '../models/category_model.dart';
import '../models/deal_model.dart';

class HomeRepositoryImpl implements HomeRepository {
  HomeRepositoryImpl(this._remote);

  final HomeRemoteDataSource _remote;

  @override
  Future<Either<Failure, List<BannerEntity>>> getBanners() async {
    try {
      final models = await _remote.fetchBanners();
      return Right(models.map((m) => m.toEntity()).toList());
    } on NetworkException catch (e) {
      return Left(Failure.network(e.message));
    } on ServerException catch (e) {
      return Left(Failure.server(e.message));
    } catch (e) {
      return Left(Failure.server(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<CategoryEntity>>> getCategories() async {
    try {
      final models = await _remote.fetchCategories();
      return Right(models.map((m) => m.toEntity()).toList());
    } on NetworkException catch (e) {
      return Left(Failure.network(e.message));
    } on ServerException catch (e) {
      return Left(Failure.server(e.message));
    } catch (e) {
      return Left(Failure.server(e.toString()));
    }
  }

  ListingEntity _listingFromDeal(DealEntity d, DateTime postedAt) {
    final imgs = <String>[];
    if (d.imageUrl != null && d.imageUrl!.isNotEmpty) {
      imgs.add(d.imageUrl!);
    }
    return ListingEntity(
      id: d.id,
      title: d.title,
      description: d.title,
      price: d.price,
      // Backend keeps sold-out listings Active; `sold` greys the tile.
      status: d.isSoldOut ? ListingStatus.sold : ListingStatus.active,
      imageUrls: imgs,
      categoryLabel: '',
      conditionLabel: 'New',
      postedAt: postedAt,
    );
  }

  @override
  Future<Either<Failure, HomeFeed>> getHomeFeed() async {
    try {
      // One GET /api/home serves all three carousels. Only a section it
      // leaves empty falls back: hot deals to GET /api/listings, the other
      // two to the hot-deals list.
      final aggregate = await _remote.fetchHomeAggregate();
      final aggregateDeals = aggregate?.hotDeals ?? const <DealModel>[];
      final hotDeals = (aggregateDeals.isNotEmpty
              ? aggregateDeals
              : await _remote.fetchHotDeals())
          .map((m) => m.toEntity())
          .toList();
      final now = DateTime.now();

      final aggregateArrivals = aggregate?.newArrivals ?? const <DealModel>[];
      final List<ListingEntity> newArrivals;
      if (aggregateArrivals.isNotEmpty) {
        newArrivals = aggregateArrivals
            .asMap()
            .entries
            .map(
              (e) => _listingFromDeal(
                e.value.toEntity(),
                now.subtract(Duration(hours: e.key)),
              ),
            )
            .toList();
      } else {
        final sorted = List<DealEntity>.from(hotDeals)
          ..sort((a, b) => a.id.compareTo(b.id));
        newArrivals = sorted
            .asMap()
            .entries
            .map(
              (e) => _listingFromDeal(
                e.value,
                now.subtract(Duration(hours: e.key)),
              ),
            )
            .toList()
            .reversed
            .toList();
      }

      final aggregatePicks = aggregate?.recommendedForYou ?? const <DealModel>[];
      final recommended = aggregatePicks.isNotEmpty
          ? aggregatePicks
              .map((d) => _listingFromDeal(d.toEntity(), now))
              .toList()
          : hotDeals.map((d) => _listingFromDeal(d, now)).toList();

      return Right((
        hotDeals: hotDeals,
        newArrivals: newArrivals,
        recommended: recommended,
      ));
    } on NetworkException catch (e) {
      return Left(Failure.network(e.message));
    } on ServerException catch (e) {
      return Left(Failure.server(e.message));
    } catch (e) {
      return Left(Failure.server(e.toString()));
    }
  }
}
