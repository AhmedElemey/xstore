import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/network/dio_provider.dart';
import '../../data/datasources/store_category_remote_datasource.dart';
import '../../data/repositories/store_category_repository_impl.dart';
import '../../domain/entities/store_category_entity.dart';
import '../../domain/repositories/store_category_repository.dart';
import '../../domain/usecases/get_store_categories_usecase.dart';
import '../../domain/usecases/get_store_category_by_id_usecase.dart';

part 'store_category_dependencies.g.dart';

@Riverpod(keepAlive: true)
StoreCategoryRemoteDataSource storeCategoryRemoteDataSource(
  StoreCategoryRemoteDataSourceRef ref,
) {
  return StoreCategoryRemoteDataSourceImpl(ref.watch(dioProvider));
}

@Riverpod(keepAlive: true)
StoreCategoryRepository storeCategoryRepository(
  StoreCategoryRepositoryRef ref,
) {
  return StoreCategoryRepositoryImpl(
    ref.watch(storeCategoryRemoteDataSourceProvider),
  );
}

@riverpod
GetStoreCategoriesUseCase getStoreCategoriesUseCase(
  GetStoreCategoriesUseCaseRef ref,
) {
  return GetStoreCategoriesUseCase(ref.watch(storeCategoryRepositoryProvider));
}

@riverpod
GetStoreCategoryByIdUseCase getStoreCategoryByIdUseCase(
  GetStoreCategoryByIdUseCaseRef ref,
) {
  return GetStoreCategoryByIdUseCase(
    ref.watch(storeCategoryRepositoryProvider),
  );
}

/// Full store-category list for the registration store-setup dropdown.
///
/// Stays autoDispose but pins the *successful* result via [Ref.keepAlive] so
/// the values are cached for the app session (re-entering the register flow
/// reads the cache instead of re-fetching). A failed fetch is left unpinned, so
/// leaving and returning retries the request rather than serving a cached error.
@riverpod
Future<List<StoreCategoryEntity>> allStoreCategories(
  AllStoreCategoriesRef ref,
) async {
  final result = await ref
      .watch(getStoreCategoriesUseCaseProvider)
      .call(page: 1, pageSize: 100);
  return result.fold((failure) => throw failure, (r) {
    ref.keepAlive();
    return r.items;
  });
}
