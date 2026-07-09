import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/network/dio_provider.dart';
import '../../../home/presentation/providers/home_dependencies.dart';
import '../../data/datasources/product_remote_datasource.dart';
import '../../data/repositories/product_repository_impl.dart';
import '../../domain/repositories/product_repository.dart';
import '../../domain/usecases/create_review_usecase.dart';
import '../../domain/usecases/delete_review_usecase.dart';
import '../../domain/usecases/get_product_detail_usecase.dart';
import '../../domain/usecases/get_product_reviews_usecase.dart';
import '../../domain/usecases/get_similar_products_usecase.dart';
import '../../domain/usecases/update_review_usecase.dart';

part 'product_dependencies.g.dart';

@Riverpod(keepAlive: true)
ProductRemoteDataSource productRemoteDataSource(ProductRemoteDataSourceRef ref) {
  return ProductRemoteDataSourceImpl(ref.watch(dioProvider));
}

@Riverpod(keepAlive: true)
ProductRepository productRepository(ProductRepositoryRef ref) {
  return ProductRepositoryImpl(
    ref.watch(homeRepositoryProvider),
    remote: ref.watch(productRemoteDataSourceProvider),
  );
}

@riverpod
GetProductDetailUseCase getProductDetailUseCase(GetProductDetailUseCaseRef ref) {
  return GetProductDetailUseCase(ref.watch(productRepositoryProvider));
}

@riverpod
GetSimilarProductsUseCase getSimilarProductsUseCase(GetSimilarProductsUseCaseRef ref) {
  return GetSimilarProductsUseCase(ref.watch(productRepositoryProvider));
}

@riverpod
GetProductReviewsUseCase getProductReviewsUseCase(GetProductReviewsUseCaseRef ref) {
  return GetProductReviewsUseCase(ref.watch(productRepositoryProvider));
}

@riverpod
CreateReviewUseCase createReviewUseCase(CreateReviewUseCaseRef ref) {
  return CreateReviewUseCase(ref.watch(productRepositoryProvider));
}

@riverpod
UpdateReviewUseCase updateReviewUseCase(UpdateReviewUseCaseRef ref) {
  return UpdateReviewUseCase(ref.watch(productRepositoryProvider));
}

@riverpod
DeleteReviewUseCase deleteReviewUseCase(DeleteReviewUseCaseRef ref) {
  return DeleteReviewUseCase(ref.watch(productRepositoryProvider));
}
