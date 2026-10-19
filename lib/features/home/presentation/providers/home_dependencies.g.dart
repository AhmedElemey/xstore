// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'home_dependencies.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$homeRemoteDataSourceHash() =>
    r'bcf5f8482ea0830f596d56c5b751fecd98312f70';

/// See also [homeRemoteDataSource].
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
String _$getHomeFeedUseCaseHash() =>
    r'b40b73805d851d48ba32b25cf98fccdc8f85a2d0';

/// See also [getHomeFeedUseCase].
@ProviderFor(getHomeFeedUseCase)
final getHomeFeedUseCaseProvider =
    AutoDisposeProvider<GetHomeFeedUseCase>.internal(
  getHomeFeedUseCase,
  name: r'getHomeFeedUseCaseProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$getHomeFeedUseCaseHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef GetHomeFeedUseCaseRef = AutoDisposeProviderRef<GetHomeFeedUseCase>;
String _$homeFeedHash() => r'dc7bd891b2002c046740cecc3353891818357b2d';

/// One `GET /api/home` shared by the hot deals, new arrivals and
/// recommended providers. Invalidate this (not a section provider) to
/// refetch — the sections rebuild from it.
///
/// Copied from [homeFeed].
@ProviderFor(homeFeed)
final homeFeedProvider = AutoDisposeFutureProvider<HomeFeed>.internal(
  homeFeed,
  name: r'homeFeedProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$homeFeedHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef HomeFeedRef = AutoDisposeFutureProviderRef<HomeFeed>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
