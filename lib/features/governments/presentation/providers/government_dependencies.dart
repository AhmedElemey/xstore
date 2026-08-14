import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/network/dio_provider.dart';
import '../../data/datasources/government_remote_datasource.dart';
import '../../data/repositories/government_repository_impl.dart';
import '../../domain/entities/government_entity.dart';
import '../../domain/repositories/government_repository.dart';
import '../../domain/usecases/get_governments_usecase.dart';

part 'government_dependencies.g.dart';

@Riverpod(keepAlive: true)
GovernmentRemoteDataSource governmentRemoteDataSource(
  GovernmentRemoteDataSourceRef ref,
) {
  return GovernmentRemoteDataSourceImpl(ref.watch(dioProvider));
}

@Riverpod(keepAlive: true)
GovernmentRepository governmentRepository(GovernmentRepositoryRef ref) {
  return GovernmentRepositoryImpl(ref.watch(governmentRemoteDataSourceProvider));
}

@riverpod
GetGovernmentsUseCase getGovernmentsUseCase(GetGovernmentsUseCaseRef ref) {
  return GetGovernmentsUseCase(ref.watch(governmentRepositoryProvider));
}

/// Full governorate list for dropdowns.
///
/// Stays autoDispose but pins the *successful* result via [Ref.keepAlive] so
/// the values are cached for the app session (re-entering the register/store
/// forms reads the cache instead of re-fetching). A failed fetch is left
/// unpinned, so leaving and returning retries the request rather than serving a
/// cached error.
@riverpod
Future<List<GovernmentEntity>> allGovernments(AllGovernmentsRef ref) async {
  final result = await ref
      .watch(getGovernmentsUseCaseProvider)
      .call(page: 1, pageSize: 100);
  return result.fold((failure) => throw failure, (r) {
    ref.keepAlive();
    return r.items;
  });
}
