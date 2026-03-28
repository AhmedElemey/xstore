import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failures.dart';
import '../entities/product_detail_entity.dart';

abstract interface class ProductRepository {
  Future<Either<Failure, ProductDetailEntity>> getProductDetail(String id);
}
