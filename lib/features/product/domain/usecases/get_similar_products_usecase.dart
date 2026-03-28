import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failures.dart';
import '../entities/product_detail_entity.dart';
import '../repositories/product_repository.dart';

class GetSimilarProductsUseCase {
  const GetSimilarProductsUseCase(this._repository);

  final ProductRepository _repository;

  Future<Either<Failure, List<ProductDetailEntity>>> call({
    required String productId,
    required String category,
  }) =>
      _repository.getSimilarProducts(productId: productId, category: category);
}
