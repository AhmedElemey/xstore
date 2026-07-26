import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/network/dio_provider.dart';
import '../../data/datasources/city_remote_datasource.dart';
import '../../data/repositories/city_repository_impl.dart';
import '../../domain/entities/city_entity.dart';
import '../../domain/repositories/city_repository.dart';
import '../../domain/usecases/get_cities_usecase.dart';
import '../../domain/usecases/get_city_by_id_usecase.dart';

part 'city_dependencies.g.dart';

@Riverpod(keepAlive: true)
CityRemoteDataSource cityRemoteDataSource(CityRemoteDataSourceRef ref) {
  return CityRemoteDataSourceImpl(ref.watch(dioProvider));
}

@Riverpod(keepAlive: true)
CityRepository cityRepository(CityRepositoryRef ref) {
  return CityRepositoryImpl(ref.watch(cityRemoteDataSourceProvider));
}

@riverpod
GetCitiesUseCase getCitiesUseCase(GetCitiesUseCaseRef ref) {
  return GetCitiesUseCase(ref.watch(cityRepositoryProvider));
}

@riverpod
GetCityByIdUseCase getCityByIdUseCase(GetCityByIdUseCaseRef ref) {
  return GetCityByIdUseCase(ref.watch(cityRepositoryProvider));
}

/// Full city list for dropdowns. Small reference table — a single
/// page-size-100 fetch (API max) avoids re-implementing pagination in every screen.
///
/// Stays autoDispose but pins the *successful* result via [Ref.keepAlive] so
/// the values are cached for the app session (re-entering the register/store
/// forms reads the cache instead of re-fetching). A failed fetch is left
/// unpinned, so leaving and returning retries the request rather than serving a
/// cached error.
@riverpod
Future<List<CityEntity>> allCities(AllCitiesRef ref) async {
  final result =
      await ref.watch(getCitiesUseCaseProvider).call(page: 1, pageSize: 100);
  return result.fold((failure) => throw failure, (r) {
    ref.keepAlive();
    return r.items;
  });
}
