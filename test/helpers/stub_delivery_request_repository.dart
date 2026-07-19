import 'package:fpdart/fpdart.dart';

import 'package:xstore/core/error/failures.dart';
import 'package:xstore/features/delivery/domain/entities/delivery_request.dart';
import 'package:xstore/features/delivery/domain/repositories/delivery_request_repository.dart';
import 'package:xstore/features/orders/domain/entities/order_entity.dart';

/// Zero-latency stand-in for the package-request store: widget tests override
/// `deliveryRequestRepositoryProvider` with this so the mock datasource's
/// simulated network delay (a pending Timer at teardown) and its demo seeds
/// stay out of test scenarios.
class StubDeliveryRequestRepository implements DeliveryRequestRepository {
  StubDeliveryRequestRepository({
    this.myRequests = const [],
    this.courierPackages = const [],
  });

  final List<DeliveryRequestEntity> myRequests;
  final List<DeliveryRequestEntity> courierPackages;

  DeliveryRequestEntity _byId(List<DeliveryRequestEntity> list, String id) =>
      list.firstWhere((r) => r.id == id);

  @override
  Future<Either<Failure, List<DeliveryRequestEntity>>> getMyRequests(
    String consumerId,
  ) async =>
      Right(myRequests);

  @override
  Future<Either<Failure, DeliveryRequestEntity>> createRequest({
    required String consumerId,
    required String consumerName,
    required String consumerPhone,
    required OrderAddress pickup,
    required OrderAddress dropoff,
    required String packageNote,
  }) async =>
      Right(
        DeliveryRequestEntity(
          id: 'pkg_test_new',
          consumerId: consumerId,
          consumerName: consumerName,
          consumerPhone: consumerPhone,
          pickup: pickup,
          dropoff: dropoff,
          packageNote: packageNote,
          status: DeliveryRequestStatus.submitted,
          createdAt: DateTime(2026, 7, 19),
          updatedAt: DateTime(2026, 7, 19),
        ),
      );

  @override
  Future<Either<Failure, DeliveryRequestEntity>> confirmRequest(
    String id,
  ) async =>
      Right(
        _byId(myRequests, id).copyWith(
          status: DeliveryRequestStatus.confirmed,
          confirmedAt: DateTime(2026, 7, 19),
          courierId: 'courier_001',
        ),
      );

  @override
  Future<Either<Failure, DeliveryRequestEntity>> cancelRequest(
    String id,
    String reason,
  ) async =>
      Right(
        _byId(myRequests, id).copyWith(
          status: DeliveryRequestStatus.cancelled,
          cancelReason: reason,
        ),
      );

  @override
  Future<Either<Failure, List<DeliveryRequestEntity>>> getCourierPackages(
    String courierId,
  ) async =>
      Right(courierPackages);

  @override
  Future<Either<Failure, DeliveryRequestEntity>> markPickedUp(
    String id,
  ) async =>
      Right(
        _byId(courierPackages, id).copyWith(
          status: DeliveryRequestStatus.pickedUp,
          pickedUpAt: DateTime(2026, 7, 19),
        ),
      );

  @override
  Future<Either<Failure, DeliveryRequestEntity>> markDelivered(
    String id,
  ) async =>
      Right(
        _byId(courierPackages, id).copyWith(
          status: DeliveryRequestStatus.delivered,
          deliveredAt: DateTime(2026, 7, 19),
        ),
      );
}

/// A package request in an arbitrary lifecycle state for widget tests.
DeliveryRequestEntity testPackageRequest({
  String id = 'pkg_test_1',
  DeliveryRequestStatus status = DeliveryRequestStatus.priced,
  double? price = 80,
  String? courierId,
  String note = 'Test parcel',
  String? cancelReason,
}) {
  final created = DateTime(2026, 7, 18);
  const pickup = OrderAddress(
    fullName: 'Sender Person',
    phone: '+201055500002',
    street: '15 Abbas El Akkad St',
    city: 'Nasr City',
    wilaya: 'Cairo',
  );
  const dropoff = OrderAddress(
    fullName: 'Recipient Person',
    phone: '+201155500010',
    street: '8 El Merghany St',
    city: 'Heliopolis',
    wilaya: 'Cairo',
  );
  return DeliveryRequestEntity(
    id: id,
    consumerId: 'consumer_001',
    consumerName: 'Sender Person',
    consumerPhone: '+201055500002',
    pickup: pickup,
    dropoff: dropoff,
    packageNote: note,
    price: status == DeliveryRequestStatus.submitted ? null : price,
    status: status,
    courierId: courierId,
    cancelReason: cancelReason,
    createdAt: created,
    updatedAt: created,
  );
}
