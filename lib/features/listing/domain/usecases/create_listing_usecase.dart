import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failures.dart';
import '../entities/listing_entity.dart';
import '../repositories/listing_repository.dart';

class CreateListingUseCase {
  const CreateListingUseCase(this._repository);

  final ListingRepository _repository;

  Future<Either<Failure, ListingEntity>> call({
    required String title,
    required String description,
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
    List<String> imagePaths = const [],
  }) {
    return _repository.createListing(
      title: title,
      description: description,
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
      imagePaths: imagePaths,
    );
  }
}
