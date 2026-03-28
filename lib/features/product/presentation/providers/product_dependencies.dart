import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../home/presentation/providers/home_dependencies.dart';
import '../../data/repositories/product_repository_impl.dart';
import '../../domain/repositories/product_repository.dart';
import '../../domain/usecases/get_product_detail_usecase.dart';

part 'product_dependencies.g.dart';

@Riverpod(keepAlive: true)
ProductRepository productRepository(ProductRepositoryRef ref) {
  return ProductRepositoryImpl(ref.watch(homeRepositoryProvider));
}

@riverpod
GetProductDetailUseCase getProductDetailUseCase(GetProductDetailUseCaseRef ref) {
  return GetProductDetailUseCase(ref.watch(productRepositoryProvider));
}
