import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/network/dio_provider.dart';
import '../../data/datasources/orders_remote_datasource.dart';
import '../../data/repositories/orders_repository_impl.dart';
import '../../domain/repositories/orders_repository.dart';
import '../../domain/usecases/cancel_order_usecase.dart';
import '../../domain/usecases/confirm_order_usecase.dart';
import '../../domain/usecases/get_consumer_orders_usecase.dart';
import '../../domain/usecases/get_courier_orders_usecase.dart';
import '../../domain/usecases/get_order_detail_usecase.dart';
import '../../domain/usecases/get_vendor_order_stats_usecase.dart';
import '../../domain/usecases/get_vendor_orders_usecase.dart';
import '../../domain/usecases/mark_delivered_usecase.dart';
import '../../domain/usecases/mark_processing_usecase.dart';
import '../../domain/usecases/mark_shipped_usecase.dart';
import '../../domain/usecases/reject_order_usecase.dart';

part 'orders_dependencies.g.dart';

@Riverpod(keepAlive: true)
OrdersRemoteDataSource ordersRemoteDataSource(OrdersRemoteDataSourceRef ref) {
  return OrdersRemoteDataSourceImpl(ref.watch(dioProvider));
}

@Riverpod(keepAlive: true)
OrdersRepository ordersRepository(OrdersRepositoryRef ref) {
  return OrdersRepositoryImpl(ref.watch(ordersRemoteDataSourceProvider));
}

@riverpod
GetConsumerOrdersUseCase getConsumerOrdersUseCase(
  GetConsumerOrdersUseCaseRef ref,
) {
  return GetConsumerOrdersUseCase(ref.watch(ordersRepositoryProvider));
}

@riverpod
GetVendorOrdersUseCase getVendorOrdersUseCase(GetVendorOrdersUseCaseRef ref) {
  return GetVendorOrdersUseCase(ref.watch(ordersRepositoryProvider));
}

@riverpod
GetCourierOrdersUseCase getCourierOrdersUseCase(
  GetCourierOrdersUseCaseRef ref,
) {
  return GetCourierOrdersUseCase(ref.watch(ordersRepositoryProvider));
}

@riverpod
GetOrderDetailUseCase getOrderDetailUseCase(GetOrderDetailUseCaseRef ref) {
  return GetOrderDetailUseCase(ref.watch(ordersRepositoryProvider));
}

@riverpod
GetVendorOrderStatsUseCase getVendorOrderStatsUseCase(
  GetVendorOrderStatsUseCaseRef ref,
) {
  return GetVendorOrderStatsUseCase(ref.watch(ordersRepositoryProvider));
}

@riverpod
CancelOrderUseCase cancelOrderUseCase(CancelOrderUseCaseRef ref) {
  return CancelOrderUseCase(ref.watch(ordersRepositoryProvider));
}

@riverpod
ConfirmOrderUseCase confirmOrderUseCase(ConfirmOrderUseCaseRef ref) {
  return ConfirmOrderUseCase(ref.watch(ordersRepositoryProvider));
}

@riverpod
RejectOrderUseCase rejectOrderUseCase(RejectOrderUseCaseRef ref) {
  return RejectOrderUseCase(ref.watch(ordersRepositoryProvider));
}

@riverpod
MarkProcessingUseCase markProcessingUseCase(MarkProcessingUseCaseRef ref) {
  return MarkProcessingUseCase(ref.watch(ordersRepositoryProvider));
}

@riverpod
MarkShippedUseCase markShippedUseCase(MarkShippedUseCaseRef ref) {
  return MarkShippedUseCase(ref.watch(ordersRepositoryProvider));
}

@riverpod
MarkDeliveredUseCase markDeliveredUseCase(MarkDeliveredUseCaseRef ref) {
  return MarkDeliveredUseCase(ref.watch(ordersRepositoryProvider));
}
