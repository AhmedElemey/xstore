import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/network/dio_provider.dart';
import '../../data/datasources/listing_remote_datasource.dart';
import '../../data/repositories/listing_repository_impl.dart';
import '../../domain/repositories/listing_repository.dart';
import '../../domain/usecases/create_listing_usecase.dart';
import '../../domain/usecases/delete_listing_usecase.dart';
import '../../domain/usecases/get_my_listings_usecase.dart';
import '../../domain/usecases/update_listing_usecase.dart';

part 'listing_dependencies.g.dart';

@Riverpod(keepAlive: true)
ListingRemoteDataSource listingRemoteDataSource(ListingRemoteDataSourceRef ref) {
  return ListingRemoteDataSourceImpl(ref.watch(dioProvider));
}

@Riverpod(keepAlive: true)
ListingRepository listingRepository(ListingRepositoryRef ref) {
  return ListingRepositoryImpl(ref.watch(listingRemoteDataSourceProvider));
}

@riverpod
CreateListingUseCase createListingUseCase(CreateListingUseCaseRef ref) {
  return CreateListingUseCase(ref.watch(listingRepositoryProvider));
}

@riverpod
GetMyListingsUseCase getMyListingsUseCase(GetMyListingsUseCaseRef ref) {
  return GetMyListingsUseCase(ref.watch(listingRepositoryProvider));
}

@riverpod
UpdateListingUseCase updateListingUseCase(UpdateListingUseCaseRef ref) {
  return UpdateListingUseCase(ref.watch(listingRepositoryProvider));
}

@riverpod
DeleteListingUseCase deleteListingUseCase(DeleteListingUseCaseRef ref) {
  return DeleteListingUseCase(ref.watch(listingRepositoryProvider));
}
