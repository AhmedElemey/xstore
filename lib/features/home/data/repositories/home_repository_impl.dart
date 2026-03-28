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
  Future<Either<Failure, List<DealEntity>>> getHotDeals() async {
    try {
      final models = await _remote.fetchHotDeals();
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
      status: ListingStatus.active,
      imageUrls: imgs,
      categoryLabel: '',
      conditionLabel: 'New',
      postedAt: postedAt,
    );
  }

  @override
  Future<Either<Failure, List<ListingEntity>>> getNewArrivals() async {
    final dealsResult = await getHotDeals();
    return dealsResult.fold(Left.new, (deals) {
      final now = DateTime.now();
      final sorted = List<DealEntity>.from(deals)
        ..sort((a, b) => a.id.compareTo(b.id));
      final list = sorted
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
      return Right(list);
    });
  }

  @override
  Future<Either<Failure, List<ListingEntity>>> getRecommended() async {
    final dealsResult = await getHotDeals();
    return dealsResult.fold(Left.new, (deals) {
      final list =
          deals.map((d) => _listingFromDeal(d, DateTime.now())).toList();
      return Right(list);
    });
  }
}
