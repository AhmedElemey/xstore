import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/mock/mock_config.dart';
import '../../data/datasources/delivery_request_datasource.dart';
import '../../data/datasources/delivery_request_remote_datasource.dart';
import '../../data/delivery_dio_provider.dart';
import '../../data/repositories/delivery_request_repository_impl.dart';
import '../../domain/repositories/delivery_request_repository.dart';

/// Mock mode: session-scoped in-memory demo store (deliberately keepAlive —
/// there is no backend to hit, so this instance IS the "server"; state lives
/// in instance fields, so disposing/invalidating this provider drops all
/// demo data). Live mode: real calls to the delivery-backend service — see
/// `delivery_backend_session.dart` for how the app's session gets a token
/// for it.
final deliveryRequestDataSourceProvider =
    Provider<DeliveryRequestDataSource>((ref) {
  if (MockConfig.useMock) return DeliveryRequestMockDataSource();
  return DeliveryRequestRemoteDataSource(ref.watch(deliveryDioProvider));
});

final deliveryRequestRepositoryProvider = Provider<DeliveryRequestRepository>(
  (ref) => DeliveryRequestRepositoryImpl(
    ref.watch(deliveryRequestDataSourceProvider),
  ),
);
