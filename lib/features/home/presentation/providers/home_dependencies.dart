import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/network/dio_provider.dart';
import '../../data/datasources/home_remote_datasource.dart';
import '../../data/repositories/home_repository_impl.dart';
import '../../domain/repositories/home_repository.dart';
import '../../domain/usecases/get_banners_usecase.dart';
import '../../domain/usecases/get_categories_usecase.dart';
import '../../domain/usecases/get_home_feed_usecase.dart';

part 'home_dependencies.g.dart';

// Shared HomeRepository / use-case wiring for banners, categories and the
// home feed.

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
GetCategoriesUseCase getCategoriesUseCase(GetCategoriesUseCaseRef ref) {
  return GetCategoriesUseCase(ref.watch(homeRepositoryProvider));
}

@riverpod
GetHomeFeedUseCase getHomeFeedUseCase(GetHomeFeedUseCaseRef ref) {
  return GetHomeFeedUseCase(ref.watch(homeRepositoryProvider));
}

/// One `GET /api/home` shared by the hot deals, new arrivals and
/// recommended providers. Invalidate this (not a section provider) to
/// refetch — the sections rebuild from it.
@riverpod
Future<HomeFeed> homeFeed(HomeFeedRef ref) async {
  final result = await ref.watch(getHomeFeedUseCaseProvider).call();
  return result.fold((failure) => throw failure, (feed) => feed);
}
