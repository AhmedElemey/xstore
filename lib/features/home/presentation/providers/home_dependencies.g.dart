// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'home_dependencies.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$homeRemoteDataSourceHash() =>
    r'bcf5f8482ea0830f596d56c5b751fecd98312f70';

/// Shared [HomeRepository] / use-case wiring for home feature providers
/// (keeps `banners` / `hot_deals` / `categories` files focused on notifiers).
///
/// Copied from [homeRemoteDataSource].
@ProviderFor(homeRemoteDataSource)
final homeRemoteDataSourceProvider = Provider<HomeRemoteDataSource>.internal(
  homeRemoteDataSource,
  name: r'homeRemoteDataSourceProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$homeRemoteDataSourceHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef HomeRemoteDataSourceRef = ProviderRef<HomeRemoteDataSource>;
String _$homeRepositoryHash() => r'2fad2ed20f9cd8669625eb018c1d23854723002e';

/// See also [homeRepository].
@ProviderFor(homeRepository)
final homeRepositoryProvider = Provider<HomeRepository>.internal(
  homeRepository,
  name: r'homeRepositoryProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$homeRepositoryHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef HomeRepositoryRef = ProviderRef<HomeRepository>;
String _$getBannersUseCaseHash() => r'7e5ff7b7357b086012e1c8cb12f388126ea39c8c';

/// See also [getBannersUseCase].
@ProviderFor(getBannersUseCase)
final getBannersUseCaseProvider =
    AutoDisposeProvider<GetBannersUseCase>.internal(
  getBannersUseCase,
  name: r'getBannersUseCaseProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$getBannersUseCaseHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef GetBannersUseCaseRef = AutoDisposeProviderRef<GetBannersUseCase>;
String _$getHotDealsUseCaseHash() =>
    r'0d855d39f65b6a7c6895c257f079aa625452525d';

/// See also [getHotDealsUseCase].
@ProviderFor(getHotDealsUseCase)
final getHotDealsUseCaseProvider =
    AutoDisposeProvider<GetHotDealsUseCase>.internal(
  getHotDealsUseCase,
  name: r'getHotDealsUseCaseProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$getHotDealsUseCaseHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef GetHotDealsUseCaseRef = AutoDisposeProviderRef<GetHotDealsUseCase>;
String _$getCategoriesUseCaseHash() =>
    r'7cd644e8fc528d03b39a699cdd034986d88ef7f6';

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
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
