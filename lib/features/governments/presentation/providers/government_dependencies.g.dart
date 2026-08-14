// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'government_dependencies.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$governmentRemoteDataSourceHash() =>
    r'9da6eb97019e024295b90273719eeb3211211c7b';

/// See also [governmentRemoteDataSource].
@ProviderFor(governmentRemoteDataSource)
final governmentRemoteDataSourceProvider =
    Provider<GovernmentRemoteDataSource>.internal(
  governmentRemoteDataSource,
  name: r'governmentRemoteDataSourceProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$governmentRemoteDataSourceHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef GovernmentRemoteDataSourceRef = ProviderRef<GovernmentRemoteDataSource>;
String _$governmentRepositoryHash() =>
    r'313c4a959fc51bf82c510b4ef90eeec039e6ae23';

/// See also [governmentRepository].
@ProviderFor(governmentRepository)
final governmentRepositoryProvider = Provider<GovernmentRepository>.internal(
  governmentRepository,
  name: r'governmentRepositoryProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$governmentRepositoryHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef GovernmentRepositoryRef = ProviderRef<GovernmentRepository>;
String _$getGovernmentsUseCaseHash() =>
    r'ec0ff6624245373ad263e361527f48b1c9708f37';

/// See also [getGovernmentsUseCase].
@ProviderFor(getGovernmentsUseCase)
final getGovernmentsUseCaseProvider =
    AutoDisposeProvider<GetGovernmentsUseCase>.internal(
  getGovernmentsUseCase,
  name: r'getGovernmentsUseCaseProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$getGovernmentsUseCaseHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef GetGovernmentsUseCaseRef
    = AutoDisposeProviderRef<GetGovernmentsUseCase>;
String _$allGovernmentsHash() => r'44b57b4bda1d8c96d659f375412160bb627b672f';

/// Full governorate list for dropdowns.
///
/// Stays autoDispose but pins the *successful* result via [Ref.keepAlive] so
/// the values are cached for the app session (re-entering the register/store
/// forms reads the cache instead of re-fetching). A failed fetch is left
/// unpinned, so leaving and returning retries the request rather than serving a
/// cached error.
///
/// Copied from [allGovernments].
@ProviderFor(allGovernments)
final allGovernmentsProvider =
    AutoDisposeFutureProvider<List<GovernmentEntity>>.internal(
  allGovernments,
  name: r'allGovernmentsProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$allGovernmentsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef AllGovernmentsRef
    = AutoDisposeFutureProviderRef<List<GovernmentEntity>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
