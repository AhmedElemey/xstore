import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failures.dart';
import '../../../orders/domain/entities/order_entity.dart';
import '../entities/delivery_request.dart';

abstract interface class DeliveryRequestRepository {
  /// The requester's (consumer or vendor) requests, newest first.
  Future<Either<Failure, List<DeliveryRequestEntity>>> getMyRequests(
    String requesterId,
  );

  /// Submits a new request (status starts at `submitted`; the admin prices
  /// it afterwards).
  Future<Either<Failure, DeliveryRequestEntity>> createRequest({
    required String requesterId,
    required String requesterName,
    required String requesterPhone,
    required OrderAddress pickup,
    required OrderAddress dropoff,
    required String packageNote,
    /// Set when a vendor raises this for an order whose pickup/dropoff
    /// doesn't fit the order's standard route. Null for a standalone
    /// consumer package.
    String? orderId,
  });

  /// Requester accepts the admin's price (`priced` → `confirmed`); the pilot
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
