import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/network/dio_provider.dart';
import '../../data/datasources/home_remote_datasource.dart';
import '../../data/repositories/home_repository_impl.dart';
import '../../domain/repositories/home_repository.dart';
import '../../domain/usecases/get_banners_usecase.dart';
import '../../domain/usecases/get_categories_usecase.dart';
import '../../domain/usecases/get_hot_deals_usecase.dart';

part 'home_dependencies.g.dart';

// Shared HomeRepository / use-case wiring for banners, hot_deals, categories.

@Riverpod(keepAlive: true)
HomeRemoteDataSource homeRemoteDataSource(HomeRemoteDataSourceRef ref) {
  return HomeRemoteDataSourceImpl(ref.watch(dioProvider));
}

@Riverpod(keepAlive: true)
HomeRepository homeRepository(HomeRepositoryRef ref) {
  return HomeRepositoryImpl(ref.watch(homeRemoteDataSourceProvider));
}

@riverpod
GetBannersUseCase getBannersUseCase(GetBannersUseCaseRef ref) {
  return GetBannersUseCase(ref.watch(homeRepositoryProvider));
}

@riverpod
GetHotDealsUseCase getHotDealsUseCase(GetHotDealsUseCaseRef ref) {
  return GetHotDealsUseCase(ref.watch(homeRepositoryProvider));
}

@riverpod
GetCategoriesUseCase getCategoriesUseCase(GetCategoriesUseCaseRef ref) {
  return GetCategoriesUseCase(ref.watch(homeRepositoryProvider));
}
