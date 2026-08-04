import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/network/dio_provider.dart';
import '../../data/datasources/catalog_category_remote_datasource.dart';
import '../../data/repositories/catalog_category_repository_impl.dart';
import '../../domain/entities/catalog_category_entity.dart';
import '../../domain/repositories/catalog_category_repository.dart';
import '../../domain/usecases/get_categories_usecase.dart';

part 'catalog_category_dependencies.g.dart';

@Riverpod(keepAlive: true)
CatalogCategoryRemoteDataSource catalogCategoryRemoteDataSource(
  CatalogCategoryRemoteDataSourceRef ref,
) {
  return CatalogCategoryRemoteDataSourceImpl(ref.watch(dioProvider));
}

@Riverpod(keepAlive: true)
CatalogCategoryRepository catalogCategoryRepository(
  CatalogCategoryRepositoryRef ref,
) {
  return CatalogCategoryRepositoryImpl(
    ref.watch(catalogCategoryRemoteDataSourceProvider),
  );
}

@riverpod
GetCategoriesUseCase getCategoriesUseCase(GetCategoriesUseCaseRef ref) {
  return GetCategoriesUseCase(ref.watch(catalogCategoryRepositoryProvider));
}

/// Stays autoDispose but pins the *successful* result via [Ref.keepAlive] so
/// the values are cached for the app session (re-entering add-listing reads
/// the cache instead of re-fetching). A failed fetch is left unpinned, so
/// leaving and returning retries the request rather than serving a cached
/// error — mirrors allCities/allGovernments/allStoreCategories.
@riverpod
Future<List<CatalogCategoryEntity>> allCatalogCategories(
  AllCatalogCategoriesRef ref,
) async {
  final result = await ref.watch(getCategoriesUseCaseProvider).call();
  return result.fold((failure) => throw failure, (items) {
    ref.keepAlive();
    return items;
  });
}
