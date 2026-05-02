import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/network/dio_provider.dart';
import '../data/datasources/explore_remote_datasource.dart';
import '../data/repositories/explore_repository_impl.dart';
import '../domain/repositories/explore_repository.dart';
import '../domain/usecases/get_suggestions_usecase.dart';
import '../domain/usecases/search_listings_usecase.dart';

part 'explore_dependencies.g.dart';

@Riverpod(keepAlive: true)
ExploreRemoteDataSource exploreRemoteDataSource(ExploreRemoteDataSourceRef ref) {
  return ExploreRemoteDataSourceImpl(ref.watch(dioProvider));
}

@Riverpod(keepAlive: true)
ExploreRepository exploreRepository(ExploreRepositoryRef ref) {
  return ExploreRepositoryImpl(ref.watch(exploreRemoteDataSourceProvider));
}

@riverpod
SearchListingsUseCase searchListingsUseCase(SearchListingsUseCaseRef ref) {
  return SearchListingsUseCase(ref.watch(exploreRepositoryProvider));
}

@riverpod
GetSuggestionsUseCase getSuggestionsUseCase(GetSuggestionsUseCaseRef ref) {
  return GetSuggestionsUseCase(ref.watch(exploreRepositoryProvider));
}
