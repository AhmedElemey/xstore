import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/network/dio_provider.dart';
import '../../data/datasources/auth_remote_datasource.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/usecases/login_usecase.dart';
import '../../domain/usecases/logout_usecase.dart';
import '../../domain/usecases/register_usecase.dart';

part 'auth_provider.g.dart';

@Riverpod(keepAlive: true)
FlutterSecureStorage secureStorage(SecureStorageRef ref) {
  return const FlutterSecureStorage();
}

@Riverpod(keepAlive: true)
AuthRemoteDataSource authRemoteDataSource(AuthRemoteDataSourceRef ref) {
  return AuthRemoteDataSourceImpl(ref.watch(dioProvider));
}

@Riverpod(keepAlive: true)
AuthRepository authRepository(AuthRepositoryRef ref) {
  return AuthRepositoryImpl(
    remote: ref.watch(authRemoteDataSourceProvider),
    secureStorage: ref.watch(secureStorageProvider),
  );
}

@riverpod
LoginUseCase loginUseCase(LoginUseCaseRef ref) {
  return LoginUseCase(ref.watch(authRepositoryProvider));
}

@riverpod
RegisterUseCase registerUseCase(RegisterUseCaseRef ref) {
  return RegisterUseCase(ref.watch(authRepositoryProvider));
}

@riverpod
LogoutUseCase logoutUseCase(LogoutUseCaseRef ref) {
  return LogoutUseCase(ref.watch(authRepositoryProvider));
}

@Riverpod(keepAlive: true)
class Auth extends _$Auth {
  @override
  Future<UserEntity?> build() async {
    final repo = ref.read(authRepositoryProvider);
    final result = await repo.restoreSession();
    return result.fold((_) => null, (user) => user);
  }

  Future<void> login({
    required String email,
    required String password,
  }) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final useCase = ref.read(loginUseCaseProvider);
      final result = await useCase(email: email, password: password);
      return result.fold(
        (failure) => throw failure,
        (user) => user,
      );
    });
  }

  Future<void> register({
    required String email,
    required String password,
  }) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final useCase = ref.read(registerUseCaseProvider);
      final result = await useCase(email: email, password: password);
      return result.fold(
        (failure) => throw failure,
        (user) => user,
      );
    });
  }

  Future<void> logout() async {
    await ref.read(logoutUseCaseProvider).call();
    ref.invalidateSelf();
  }
}
