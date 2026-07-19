import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/datasources/delivery_request_datasource.dart';
import '../../data/repositories/delivery_request_repository_impl.dart';
import '../../domain/repositories/delivery_request_repository.dart';

/// Session-scoped demo store for package delivery requests.
///
/// Deliberately keepAlive (plain [Provider]): there is no backend, so this
/// instance IS the "server" — created/updated requests must survive screen
/// navigation for the whole app session. State lives in instance fields (not
/// statics), so disposing/invalidating this provider drops all demo data;
/// a logout flow that must clear it can `ref.invalidate` this provider.
final deliveryRequestDataSourceProvider =
    Provider<DeliveryRequestMockDataSource>(
  (ref) => DeliveryRequestMockDataSource(),
);

final deliveryRequestRepositoryProvider = Provider<DeliveryRequestRepository>(
  (ref) => DeliveryRequestRepositoryImpl(
    ref.watch(deliveryRequestDataSourceProvider),
  ),
);
