// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'catalog_category_dependencies.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$catalogCategoryRemoteDataSourceHash() =>
    r'946bcd9435f70fbb77cae80ae066a1dd281fc672';

/// See also [catalogCategoryRemoteDataSource].
@ProviderFor(catalogCategoryRemoteDataSource)
final catalogCategoryRemoteDataSourceProvider =
    Provider<CatalogCategoryRemoteDataSource>.internal(
  catalogCategoryRemoteDataSource,
  name: r'catalogCategoryRemoteDataSourceProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$catalogCategoryRemoteDataSourceHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef CatalogCategoryRemoteDataSourceRef
    = ProviderRef<CatalogCategoryRemoteDataSource>;
String _$catalogCategoryRepositoryHash() =>
    r'0f625a9260dba55a8b060f4b356a7dd7a69fc1a0';

/// See also [catalogCategoryRepository].
@ProviderFor(catalogCategoryRepository)
final catalogCategoryRepositoryProvider =
    Provider<CatalogCategoryRepository>.internal(
  catalogCategoryRepository,
  name: r'catalogCategoryRepositoryProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$catalogCategoryRepositoryHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef CatalogCategoryRepositoryRef = ProviderRef<CatalogCategoryRepository>;
String _$getCategoriesUseCaseHash() =>
    r'23fafb9a4997f2ea4002579c33fa94fd4ada151e';

/// See also [getCategoriesUseCase].
@ProviderFor(getCategoriesUseCase)
final getCategoriesUseCaseProvider =
    AutoDisposeProvider<GetCategoriesUseCase>.internal(
  getCategoriesUseCase,
  name: r'getCategoriesUseCaseProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$getCategoriesUseCaseHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef GetCategoriesUseCaseRef = AutoDisposeProviderRef<GetCategoriesUseCase>;
String _$getCategoryByIdUseCaseHash() =>
    r'4d77e50916de9fd83677e50cbdbd6ae85a6c1d73';

/// See also [getCategoryByIdUseCase].
@ProviderFor(getCategoryByIdUseCase)
final getCategoryByIdUseCaseProvider =
    AutoDisposeProvider<GetCategoryByIdUseCase>.internal(
  getCategoryByIdUseCase,
  name: r'getCategoryByIdUseCaseProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$getCategoryByIdUseCaseHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef GetCategoryByIdUseCaseRef
    = AutoDisposeProviderRef<GetCategoryByIdUseCase>;
String _$allCatalogCategoriesHash() =>
    r'c5558cd3e92174394c8b0495e2ac06d0fa1b3b60';

/// See also [allCatalogCategories].
@ProviderFor(allCatalogCategories)
final allCatalogCategoriesProvider =
    AutoDisposeFutureProvider<List<CatalogCategoryEntity>>.internal(
  allCatalogCategories,
  name: r'allCatalogCategoriesProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$allCatalogCategoriesHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef AllCatalogCategoriesRef
    = AutoDisposeFutureProviderRef<List<CatalogCategoryEntity>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
