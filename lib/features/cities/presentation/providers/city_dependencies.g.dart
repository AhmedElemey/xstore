// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'city_dependencies.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$cityRemoteDataSourceHash() =>
    r'6405afb9a6671b3e79648600d052044a8432f77b';

/// See also [cityRemoteDataSource].
@ProviderFor(cityRemoteDataSource)
final cityRemoteDataSourceProvider = Provider<CityRemoteDataSource>.internal(
  cityRemoteDataSource,
  name: r'cityRemoteDataSourceProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$cityRemoteDataSourceHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef CityRemoteDataSourceRef = ProviderRef<CityRemoteDataSource>;
String _$cityRepositoryHash() => r'4071bef743c98dcde7f1ad491cb2484e1c509bd9';

/// See also [cityRepository].
@ProviderFor(cityRepository)
final cityRepositoryProvider = Provider<CityRepository>.internal(
  cityRepository,
  name: r'cityRepositoryProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$cityRepositoryHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef CityRepositoryRef = ProviderRef<CityRepository>;
String _$getCitiesUseCaseHash() => r'896c800dbea26548c478d8989bad8186b4afb607';

/// See also [getCitiesUseCase].
@ProviderFor(getCitiesUseCase)
final getCitiesUseCaseProvider = AutoDisposeProvider<GetCitiesUseCase>.internal(
  getCitiesUseCase,
  name: r'getCitiesUseCaseProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$getCitiesUseCaseHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef GetCitiesUseCaseRef = AutoDisposeProviderRef<GetCitiesUseCase>;
String _$getCityByIdUseCaseHash() =>
    r'ac6fbcbd2516aaf78af33626bec8dff71fc24d22';

/// See also [getCityByIdUseCase].
@ProviderFor(getCityByIdUseCase)
final getCityByIdUseCaseProvider =
    AutoDisposeProvider<GetCityByIdUseCase>.internal(
  getCityByIdUseCase,
  name: r'getCityByIdUseCaseProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$getCityByIdUseCaseHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef GetCityByIdUseCaseRef = AutoDisposeProviderRef<GetCityByIdUseCase>;
String _$allCitiesHash() => r'0d2d0f87abff04afa59d5f14be0f8d3ec213d839';

/// Full city list for dropdowns. Small reference table — a single
/// page-size-100 fetch (API max) avoids re-implementing pagination in every screen.
///
/// Stays autoDispose but pins the *successful* result via [Ref.keepAlive] so
/// the values are cached for the app session (re-entering the register/store
/// forms reads the cache instead of re-fetching). A failed fetch is left
/// unpinned, so leaving and returning retries the request rather than serving a
/// cached error.
///
/// Copied from [allCities].
@ProviderFor(allCities)
final allCitiesProvider = AutoDisposeFutureProvider<List<CityEntity>>.internal(
  allCities,
  name: r'allCitiesProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$allCitiesHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef AllCitiesRef = AutoDisposeFutureProviderRef<List<CityEntity>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
