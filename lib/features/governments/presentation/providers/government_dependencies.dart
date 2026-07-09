import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/network/dio_provider.dart';
import '../../data/datasources/government_remote_datasource.dart';
import '../../data/repositories/government_repository_impl.dart';
import '../../domain/entities/government_entity.dart';
import '../../domain/repositories/government_repository.dart';
import '../../domain/usecases/get_government_by_id_usecase.dart';
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

@riverpod
GetGovernmentByIdUseCase getGovernmentByIdUseCase(
  GetGovernmentByIdUseCaseRef ref,
) {
  return GetGovernmentByIdUseCase(ref.watch(governmentRepositoryProvider));
}

@riverpod
Future<List<GovernmentEntity>> allGovernments(AllGovernmentsRef ref) async {
  final result = await ref
      .watch(getGovernmentsUseCaseProvider)
      .call(page: 0, pageSize: 200);
  return result.fold((failure) => throw failure, (r) => r.items);
}
