import 'package:fpdart/fpdart.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/listing_entity.dart';
import '../../domain/repositories/listing_repository.dart';
import '../datasources/listing_remote_datasource.dart';
import '../models/listing_model.dart';

class ListingRepositoryImpl implements ListingRepository {
  ListingRepositoryImpl(this._remote);

  final ListingRemoteDataSource _remote;

  @override
  Future<Either<Failure, ListingEntity>> createListing({
    required String titleEn,
    required String titleAr,
    required String descriptionEn,
    required String descriptionAr,
    required double price,
    double? compareAtPrice,
    required int categoryId,
    int? subcategoryId,
    required ListingCondition condition,
    required String brand,
    required int stockQuantity,
    required bool shippingAvailable,
    required double shippingCost,
    required String location,
    required Map<String, String> attributes,
    List<String> imageUrls = const [],
  }) async {
    try {
      final model = await _remote.createListing(
        titleEn: titleEn,
        titleAr: titleAr,
        descriptionEn: descriptionEn,
        descriptionAr: descriptionAr,
        price: price,
        compareAtPrice: compareAtPrice,
        categoryId: categoryId,
        subcategoryId: subcategoryId,
        condition: condition,
        brand: brand,
        stockQuantity: stockQuantity,
        shippingAvailable: shippingAvailable,
        shippingCost: shippingCost,
        location: location,
        attributes: attributes,
        imageUrls: imageUrls,
      );
      return Right(model.toEntity());
    } on NetworkException catch (e) {
      return Left(Failure.network(e.message));
    } on ServerException catch (e) {
      return Left(Failure.server(e.message));
    } catch (e) {
      return Left(Failure.server(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<ListingEntity>>> getMyListings() async {
    try {
      final models = await _remote.fetchMyListings();
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
  Future<Either<Failure, ListingEntity>> updateListing({
    required String id,
    required String titleEn,
    required String titleAr,
    required String descriptionEn,
    required String descriptionAr,
    required double price,
    double? compareAtPrice,
    required int categoryId,
    int? subcategoryId,
    required ListingCondition condition,
    required String brand,
    required int stockQuantity,
    required bool shippingAvailable,
    required double shippingCost,
    required String location,
    required Map<String, String> attributes,
    required List<String> imageUrls,
    required ListingStatus status,
  }) async {
    try {
      final model = await _remote.updateListing(
        id: id,
        titleEn: titleEn,
        titleAr: titleAr,
        descriptionEn: descriptionEn,
        descriptionAr: descriptionAr,
        price: price,
        compareAtPrice: compareAtPrice,
        categoryId: categoryId,
        subcategoryId: subcategoryId,
        condition: condition,
        brand: brand,
        stockQuantity: stockQuantity,
        shippingAvailable: shippingAvailable,
        shippingCost: shippingCost,
        location: location,
        attributes: attributes,
        imageUrls: imageUrls,
        status: status,
      );
      return Right(model.toEntity());
    } on NetworkException catch (e) {
      return Left(Failure.network(e.message));
    } on ServerException catch (e) {
      return Left(Failure.server(e.message));
    } catch (e) {
      return Left(Failure.server(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Unit>> deleteListing(String id) async {
    try {
      await _remote.deleteListing(id);
      return const Right(unit);
    } on NetworkException catch (e) {
      return Left(Failure.network(e.message));
    } on ServerException catch (e) {
      return Left(Failure.server(e.message));
    } catch (e) {
      return Left(Failure.server(e.toString()));
    }
  }
}
