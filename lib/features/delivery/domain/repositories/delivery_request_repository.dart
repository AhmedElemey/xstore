import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failures.dart';
import '../../../orders/domain/entities/order_entity.dart';
import '../entities/delivery_request.dart';

abstract interface class DeliveryRequestRepository {
  /// The consumer's requests, newest first.
  Future<Either<Failure, List<DeliveryRequestEntity>>> getMyRequests(
    String consumerId,
  );

  /// Submits a new request (status starts at `submitted`; the admin prices
  /// it afterwards).
  Future<Either<Failure, DeliveryRequestEntity>> createRequest({
    required String consumerId,
    required String consumerName,
    required String consumerPhone,
    required OrderAddress pickup,
    required OrderAddress dropoff,
    required String packageNote,
  });

  /// Consumer accepts the admin's price (`priced` → `confirmed`); the pilot
  /// assigns the courier at this point.
  Future<Either<Failure, DeliveryRequestEntity>> confirmRequest(String id);

  /// Valid from `submitted`/`priced` only.
  Future<Either<Failure, DeliveryRequestEntity>> cancelRequest(
    String id,
    String reason,
  );

  /// Requests assigned to the courier (confirmed/pickedUp/delivered).
  Future<Either<Failure, List<DeliveryRequestEntity>>> getCourierPackages(
    String courierId,
  );

  /// Courier collected cash + parcel from the sender (`confirmed` →
  /// `pickedUp`).
  Future<Either<Failure, DeliveryRequestEntity>> markPickedUp(String id);

  /// Parcel handed to the recipient (`pickedUp` → `delivered`).
  Future<Either<Failure, DeliveryRequestEntity>> markDelivered(String id);
}
