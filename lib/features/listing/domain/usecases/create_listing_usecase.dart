import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failures.dart';
import '../entities/listing_entity.dart';
import '../repositories/listing_repository.dart';

class CreateListingUseCase {
  const CreateListingUseCase(this._repository);

  final ListingRepository _repository;

  Future<Either<Failure, ListingEntity>> call({
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
  }) {
    return _repository.createListing(
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
  }
}
