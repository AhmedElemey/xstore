import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/mock/mock_config.dart';
import '../../../../core/network/dio_provider.dart';
import '../../data/datasources/delivery_request_datasource.dart';
import '../../data/datasources/delivery_request_remote_datasource.dart';
import '../../data/repositories/delivery_request_repository_impl.dart';
import '../../domain/repositories/delivery_request_repository.dart';

/// Package-delivery datasource: the live backend (`/api/delivery-requests`) by
/// default, the in-memory demo store under `--dart-define=MOCK=true`.
///
/// keepAlive (plain [Provider]) so the mock instance — which IS the demo
/// "server" — survives screen navigation for the whole app session. Its state
/// lives in instance fields, so a logout that must clear demo data can
/// `ref.invalidate` this provider. The remote branch is stateless (just wraps
/// the shared Dio) so keepAlive is harmless there.
final deliveryRequestDataSourceProvider =
    Provider<DeliveryRequestDataSource>((ref) {
  if (MockConfig.useMock) {
    return DeliveryRequestMockDataSource();
  }
  return DeliveryRequestRemoteDataSource(ref.watch(dioProvider));
});

final deliveryRequestRepositoryProvider = Provider<DeliveryRequestRepository>(
  (ref) => DeliveryRequestRepositoryImpl(
    ref.watch(deliveryRequestDataSourceProvider),
  ),
);
