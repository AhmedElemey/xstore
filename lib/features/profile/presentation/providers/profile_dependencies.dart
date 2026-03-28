import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/network/dio_provider.dart';
import '../../data/datasources/profile_remote_datasource.dart';
import '../../data/repositories/profile_repository_impl.dart';
import '../../domain/repositories/profile_repository.dart';
import '../../domain/usecases/delete_account_usecase.dart';
import '../../domain/usecases/get_profile_usecase.dart';
import '../../domain/usecases/get_vendor_store_profile_usecase.dart';
import '../../domain/usecases/update_avatar_usecase.dart';
import '../../domain/usecases/update_profile_usecase.dart';

part 'profile_dependencies.g.dart';

@Riverpod(keepAlive: true)
ProfileRemoteDataSource profileRemoteDataSource(ProfileRemoteDataSourceRef ref) {
  return ProfileRemoteDataSourceImpl(ref.watch(dioProvider));
}

@Riverpod(keepAlive: true)
ProfileRepository profileRepository(ProfileRepositoryRef ref) {
  return ProfileRepositoryImpl(ref.watch(profileRemoteDataSourceProvider));
}

@riverpod
GetProfileUseCase getProfileUseCase(GetProfileUseCaseRef ref) {
  return GetProfileUseCase(ref.watch(profileRepositoryProvider));
}

@riverpod
GetVendorStoreProfileUseCase getVendorStoreProfileUseCase(
  GetVendorStoreProfileUseCaseRef ref,
) {
  return GetVendorStoreProfileUseCase(ref.watch(profileRepositoryProvider));
}

@riverpod
UpdateProfileUseCase updateProfileUseCase(UpdateProfileUseCaseRef ref) {
  return UpdateProfileUseCase(ref.watch(profileRepositoryProvider));
}

@riverpod
UpdateAvatarUseCase updateAvatarUseCase(UpdateAvatarUseCaseRef ref) {
  return UpdateAvatarUseCase(ref.watch(profileRepositoryProvider));
}

@riverpod
DeleteAccountUseCase deleteAccountUseCase(DeleteAccountUseCaseRef ref) {
  return DeleteAccountUseCase(ref.watch(profileRepositoryProvider));
}
