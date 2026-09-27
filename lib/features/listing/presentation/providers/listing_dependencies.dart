import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/network/dio_provider.dart';
import '../../../../core/utils/validators.dart';
import '../../../app_settings/domain/app_settings.dart';
import '../../../app_settings/presentation/app_settings_providers.dart';
import '../../data/datasources/listing_remote_datasource.dart';
import '../../data/repositories/listing_repository_impl.dart';
import '../../domain/repositories/listing_repository.dart';
import '../../domain/usecases/create_listing_usecase.dart';
import '../../domain/usecases/deactivate_listing_usecase.dart';
import '../../domain/usecases/delete_listing_usecase.dart';
import '../../domain/usecases/get_listing_by_id_usecase.dart';
import '../../domain/usecases/get_my_listings_usecase.dart';
import '../../domain/usecases/resubmit_listing_usecase.dart';
import '../../domain/usecases/update_listing_usecase.dart';

part 'listing_dependencies.g.dart';

@Riverpod(keepAlive: true)
ListingRemoteDataSource listingRemoteDataSource(ListingRemoteDataSourceRef ref) {
  return ListingRemoteDataSourceImpl(ref.watch(dioProvider));
}

/// Clears the listing datasource's offline-scaffold cache on logout, so a
/// new session on the same device never sees the prior vendor's drafts.
/// Call alongside `resetProfileData(ref)` on every forced session clear.
void resetListingLocalCache(Ref ref) {
  ref.read(listingRemoteDataSourceProvider).clearLocalCache();
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
GetListingByIdUseCase getListingByIdUseCase(GetListingByIdUseCaseRef ref) {
  return GetListingByIdUseCase(ref.watch(listingRepositoryProvider));
}

@riverpod
UpdateListingUseCase updateListingUseCase(UpdateListingUseCaseRef ref) {
  return UpdateListingUseCase(ref.watch(listingRepositoryProvider));
}

@riverpod
DeleteListingUseCase deleteListingUseCase(DeleteListingUseCaseRef ref) {
  return DeleteListingUseCase(ref.watch(listingRepositoryProvider));
}

@riverpod
ResubmitListingUseCase resubmitListingUseCase(ResubmitListingUseCaseRef ref) {
  return ResubmitListingUseCase(ref.watch(listingRepositoryProvider));
}

@riverpod
DeactivateListingUseCase deactivateListingUseCase(
  DeactivateListingUseCaseRef ref,
) {
  return DeactivateListingUseCase(ref.watch(listingRepositoryProvider));
}

/// Max listing title length, set by the admin as `listing-title-max-character`
/// (General Settings). Falls back to [kListingTitleMaxLengthDefault] while the
/// settings load, or when the key is missing, not a whole number, or ≤ 0.
@riverpod
int listingTitleMaxLength(ListingTitleMaxLengthRef ref) {
  final settings = ref.watch(appSettingsProvider).valueOrNull;
  final max = settings?.valueOf<int>(
    AppSettingKeys.listingTitleMaxCharacter,
    kListingTitleMaxLengthDefault,
  );
  return max != null && max > 0 ? max : kListingTitleMaxLengthDefault;
}
