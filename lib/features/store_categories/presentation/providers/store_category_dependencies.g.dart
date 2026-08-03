// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'store_category_dependencies.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$storeCategoryRemoteDataSourceHash() =>
    r'4d5fc92fda22dd139327e970dddb92de039c41e0';

/// See also [storeCategoryRemoteDataSource].
@ProviderFor(storeCategoryRemoteDataSource)
final storeCategoryRemoteDataSourceProvider =
    Provider<StoreCategoryRemoteDataSource>.internal(
  storeCategoryRemoteDataSource,
  name: r'storeCategoryRemoteDataSourceProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$storeCategoryRemoteDataSourceHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef StoreCategoryRemoteDataSourceRef
    = ProviderRef<StoreCategoryRemoteDataSource>;
String _$storeCategoryRepositoryHash() =>
    r'6c8f287b6cf2aefcb2e2e9338df0a555ae3f26a9';

/// See also [storeCategoryRepository].
@ProviderFor(storeCategoryRepository)
final storeCategoryRepositoryProvider =
    Provider<StoreCategoryRepository>.internal(
  storeCategoryRepository,
  name: r'storeCategoryRepositoryProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$storeCategoryRepositoryHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef StoreCategoryRepositoryRef = ProviderRef<StoreCategoryRepository>;
String _$getStoreCategoriesUseCaseHash() =>
    r'36ba447990d62482684dff48b94136e6f1743eed';

/// See also [getStoreCategoriesUseCase].
@ProviderFor(getStoreCategoriesUseCase)
final getStoreCategoriesUseCaseProvider =
    AutoDisposeProvider<GetStoreCategoriesUseCase>.internal(
  getStoreCategoriesUseCase,
  name: r'getStoreCategoriesUseCaseProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$getStoreCategoriesUseCaseHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef GetStoreCategoriesUseCaseRef
    = AutoDisposeProviderRef<GetStoreCategoriesUseCase>;
String _$getStoreCategoryByIdUseCaseHash() =>
    r'c0f1425195a83a1120f6dd9587ffe3e0bd83b26d';

/// See also [getStoreCategoryByIdUseCase].
@ProviderFor(getStoreCategoryByIdUseCase)
final getStoreCategoryByIdUseCaseProvider =
    AutoDisposeProvider<GetStoreCategoryByIdUseCase>.internal(
  getStoreCategoryByIdUseCase,
  name: r'getStoreCategoryByIdUseCaseProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$getStoreCategoryByIdUseCaseHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef GetStoreCategoryByIdUseCaseRef
    = AutoDisposeProviderRef<GetStoreCategoryByIdUseCase>;
String _$allStoreCategoriesHash() =>
    r'1ddf9512568c2d3f12e23be901fddfcfa87f276b';

/// Full store-category list for the registration store-setup dropdown.
///
/// Stays autoDispose but pins the *successful* result via [Ref.keepAlive] so
/// the values are cached for the app session (re-entering the register flow
/// reads the cache instead of re-fetching). A failed fetch is left unpinned, so
/// leaving and returning retries the request rather than serving a cached error.
///
/// Copied from [allStoreCategories].
@ProviderFor(allStoreCategories)
final allStoreCategoriesProvider =
    AutoDisposeFutureProvider<List<StoreCategoryEntity>>.internal(
  allStoreCategories,
  name: r'allStoreCategoriesProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$allStoreCategoriesHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef AllStoreCategoriesRef
    = AutoDisposeFutureProviderRef<List<StoreCategoryEntity>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
