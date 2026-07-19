import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failures.dart';
import '../../../orders/domain/entities/order_entity.dart';
import '../../domain/entities/delivery_request.dart';
import '../../domain/repositories/delivery_request_repository.dart';
import '../datasources/delivery_request_datasource.dart';

class DeliveryRequestRepositoryImpl implements DeliveryRequestRepository {
  DeliveryRequestRepositoryImpl(this._dataSource);

  final DeliveryRequestMockDataSource _dataSource;

  /// Maps datasource throws to typed failures: [StateError] carries the
  /// not-found / invalid-transition messages, anything else is unexpected.
  Future<Either<Failure, T>> _guard<T>(Future<T> Function() run) async {
    try {
      return Right(await run());
    } on StateError catch (e) {
      return Left(Failure.validation(e.message));
    } catch (e) {
      return Left(Failure.server(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<DeliveryRequestEntity>>> getMyRequests(
    String consumerId,
  ) =>
      _guard(() => _dataSource.getMyRequests(consumerId));

  @override
  Future<Either<Failure, DeliveryRequestEntity>> createRequest({
    required String consumerId,
    required String consumerName,
    required String consumerPhone,
    required OrderAddress pickup,
    required OrderAddress dropoff,
    required String packageNote,
  }) =>
      _guard(
        () => _dataSource.createRequest(
          consumerId: consumerId,
          consumerName: consumerName,
          consumerPhone: consumerPhone,
          pickup: pickup,
          dropoff: dropoff,
          packageNote: packageNote,
        ),
      );

  @override
  Future<Either<Failure, DeliveryRequestEntity>> confirmRequest(String id) =>
      _guard(() => _dataSource.confirmRequest(id));

  @override
  Future<Either<Failure, DeliveryRequestEntity>> cancelRequest(
    String id,
    String reason,
  ) =>
      _guard(() => _dataSource.cancelRequest(id, reason));

  @override
  Future<Either<Failure, List<DeliveryRequestEntity>>> getCourierPackages(
    String courierId,
  ) =>
      _guard(() => _dataSource.getCourierPackages(courierId));

  @override
  Future<Either<Failure, DeliveryRequestEntity>> markPickedUp(String id) =>
      _guard(() => _dataSource.markPickedUp(id));

  @override
  Future<Either<Failure, DeliveryRequestEntity>> markDelivered(String id) =>
      _guard(() => _dataSource.markDelivered(id));
}
