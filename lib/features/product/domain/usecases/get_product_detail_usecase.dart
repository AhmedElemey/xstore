import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failures.dart';
import '../entities/product_detail_entity.dart';
import '../repositories/product_repository.dart';

class GetProductDetailUseCase {
  GetProductDetailUseCase(this._repository);

  final ProductRepository _repository;

  Future<Either<Failure, ProductDetailEntity>> call(String id) {
    return _repository.getProductDetail(id);
  }
}
