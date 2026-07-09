import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/network/dio_provider.dart';
import '../../data/datasources/notifications_remote_datasource.dart';
import '../../data/repositories/notifications_repository_impl.dart';
import '../../domain/repositories/notifications_repository.dart';
import '../../domain/usecases/delete_notification_usecase.dart';
import '../../domain/usecases/get_notifications_usecase.dart';
import '../../domain/usecases/mark_all_read_usecase.dart';
import '../../domain/usecases/mark_read_usecase.dart';
import '../../domain/usecases/mark_unread_usecase.dart';

part 'notifications_dependencies.g.dart';

@Riverpod(keepAlive: true)
NotificationsRemoteDataSource notificationsRemoteDataSource(
  NotificationsRemoteDataSourceRef ref,
) {
  return NotificationsRemoteDataSourceImpl(ref.watch(dioProvider));
}

@Riverpod(keepAlive: true)
NotificationsRepository notificationsRepository(
  NotificationsRepositoryRef ref,
) {
  return NotificationsRepositoryImpl(
    ref.watch(notificationsRemoteDataSourceProvider),
  );
}

@riverpod
GetNotificationsUseCase getNotificationsUseCase(
  GetNotificationsUseCaseRef ref,
) {
  return GetNotificationsUseCase(ref.watch(notificationsRepositoryProvider));
}

@riverpod
MarkReadUseCase markReadUseCase(MarkReadUseCaseRef ref) {
  return MarkReadUseCase(ref.watch(notificationsRepositoryProvider));
}

@riverpod
MarkAllReadUseCase markAllReadUseCase(MarkAllReadUseCaseRef ref) {
  return MarkAllReadUseCase(ref.watch(notificationsRepositoryProvider));
}

@riverpod
MarkUnreadUseCase markUnreadUseCase(MarkUnreadUseCaseRef ref) {
  return MarkUnreadUseCase(ref.watch(notificationsRepositoryProvider));
}

@riverpod
DeleteNotificationUseCase deleteNotificationUseCase(
  DeleteNotificationUseCaseRef ref,
) {
  return DeleteNotificationUseCase(ref.watch(notificationsRepositoryProvider));
}
