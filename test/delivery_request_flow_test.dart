import 'package:flutter_test/flutter_test.dart';
import 'package:xstore/features/delivery/data/datasources/delivery_request_datasource.dart';
import 'package:xstore/features/delivery/data/repositories/delivery_request_repository_impl.dart';
import 'package:xstore/features/delivery/domain/delivery_request_flow.dart';
import 'package:xstore/features/delivery/domain/entities/delivery_request.dart';
import 'package:xstore/features/orders/domain/entities/order_entity.dart';

const _pickup = OrderAddress(
  fullName: 'Sender Name',
  phone: '+201255500002',
  street: '1 Test St',
  city: 'Nasr City',
  wilaya: 'Cairo',
);

const _dropoffSameCity = OrderAddress(
  fullName: 'Recipient Name',
  phone: '+201155500099',
  street: '2 Test St',
  city: 'Nasr City',
  wilaya: 'Cairo',
);

const _dropoffCrossCity = OrderAddress(
  fullName: 'Recipient Name',
  phone: '+201155500099',
  street: '3 Test St',
  city: 'Mohandessin',
  wilaya: 'Giza',
);

DeliveryRequestEntity _request({
  DeliveryRequestStatus status = DeliveryRequestStatus.submitted,
  double? price,
}) {
  final now = DateTime(2026, 7, 19);
  return DeliveryRequestEntity(
    id: 'pkg_test',
    consumerId: 'consumer_001',
    consumerName: 'Sara Khelifi',
    consumerPhone: '+201255500002',
    pickup: _pickup,
    dropoff: _dropoffSameCity,
    packageNote: 'test package',
    price: price,
    status: status,
    createdAt: now,
    updatedAt: now,
  );
}

void main() {
  group('cashToCollectFromSender', () {
    test('is the price once confirmed and through delivery', () {
      for (final status in [
        DeliveryRequestStatus.confirmed,
        DeliveryRequestStatus.pickedUp,
        DeliveryRequestStatus.delivered,
      ]) {
        expect(
          cashToCollectFromSender(_request(status: status, price: 100)),
          100,
          reason: '$status should collect the price',
        );
      }
    });

    test('is zero before confirmation and when cancelled', () {
      for (final status in [
        DeliveryRequestStatus.submitted,
        DeliveryRequestStatus.priced,
        DeliveryRequestStatus.cancelled,
      ]) {
        expect(
          cashToCollectFromSender(_request(status: status, price: 100)),
          0,
          reason: '$status should collect nothing',
        );
      }
    });

    test('is zero when no price is set', () {
      expect(
        cashToCollectFromSender(
          _request(status: DeliveryRequestStatus.confirmed),
        ),
        0,
      );
    });
  });

  group('courierHoldsPackageCash', () {
    test('true only after pickup with a price', () {
      expect(
        courierHoldsPackageCash(
          _request(status: DeliveryRequestStatus.pickedUp, price: 80),
        ),
        isTrue,
      );
      expect(
        courierHoldsPackageCash(
          _request(status: DeliveryRequestStatus.delivered, price: 80),
        ),
        isTrue,
      );
      expect(
        courierHoldsPackageCash(
          _request(status: DeliveryRequestStatus.confirmed, price: 80),
        ),
        isFalse,
      );
      expect(
        courierHoldsPackageCash(
          _request(status: DeliveryRequestStatus.pickedUp),
        ),
        isFalse,
        reason: 'no price means nothing was collected',
      );
    });
  });

  group('courierSeesCustomerIdentity', () {
    test('identity hidden until the request is confirmed', () {
      const visible = {
        DeliveryRequestStatus.confirmed,
        DeliveryRequestStatus.pickedUp,
        DeliveryRequestStatus.delivered,
      };
      for (final status in DeliveryRequestStatus.values) {
        expect(
          courierSeesCustomerIdentity(status),
          visible.contains(status),
          reason: 'wrong visibility for $status',
        );
      }
    });
  });

  group('courierSeesOrderCustomerIdentity', () {
    test('hidden only while the marketplace order is pending', () {
      for (final status in OrderStatus.values) {
        expect(
          courierSeesOrderCustomerIdentity(status),
          status != OrderStatus.pending,
          reason: 'wrong visibility for $status',
        );
      }
    });
  });

  group('courierPackageNextAction', () {
    test('maps statuses to the courier next step', () {
      expect(
        courierPackageNextAction(DeliveryRequestStatus.confirmed),
        CourierPackageAction.collectAndPickUp,
      );
      expect(
        courierPackageNextAction(DeliveryRequestStatus.pickedUp),
        CourierPackageAction.deliver,
      );
      for (final status in [
        DeliveryRequestStatus.submitted,
        DeliveryRequestStatus.priced,
        DeliveryRequestStatus.delivered,
        DeliveryRequestStatus.cancelled,
      ]) {
        expect(
          courierPackageNextAction(status),
          CourierPackageAction.none,
          reason: '$status is not actionable',
        );
      }
    });

    test('isActivePackageTask follows the next action', () {
      expect(
        isActivePackageTask(_request(status: DeliveryRequestStatus.confirmed)),
        isTrue,
      );
      expect(
        isActivePackageTask(_request(status: DeliveryRequestStatus.pickedUp)),
        isTrue,
      );
      expect(
        isActivePackageTask(_request(status: DeliveryRequestStatus.delivered)),
        isFalse,
      );
      expect(
        isActivePackageTask(_request(status: DeliveryRequestStatus.priced)),
        isFalse,
      );
    });
  });

  group('mockPackagePrice', () {
    test('base fare within one city, surcharge across cities', () {
      expect(mockPackagePrice(_pickup, _dropoffSameCity),
          kMockPackageBaseFareEgp);
      expect(
        mockPackagePrice(_pickup, _dropoffCrossCity),
        kMockPackageBaseFareEgp + kMockPackageCrossCitySurchargeEgp,
      );
    });
  });

  group('DeliveryRequestRepository lifecycle', () {
    test(
        'create -> lazy auto-price -> confirm assigns courier_001 -> '
        'pickedUp -> delivered, invalid transitions rejected', () async {
      // Pricing delay shorter than the mock network latency (800ms), so the
      // "admin" has always priced a submitted request by the next read.
      final repo = DeliveryRequestRepositoryImpl(
        DeliveryRequestMockDataSource(
          adminPricingDelay: const Duration(milliseconds: 200),
        ),
      );

      final created = await repo.createRequest(
        consumerId: 'consumer_test',
        consumerName: 'Test Consumer',
        consumerPhone: '+201000000000',
        pickup: _pickup,
        dropoff: _dropoffCrossCity,
        packageNote: 'lifecycle test parcel',
      );
      final request = created.getOrElse((f) => fail('create failed: $f'));
      expect(request.status, DeliveryRequestStatus.submitted);
      expect(request.price, isNull);

      // Lazy admin pricing kicks in on the next read.
      final listed = await repo.getMyRequests('consumer_test');
      final priced = listed
          .getOrElse((f) => fail('getMyRequests failed: $f'))
          .singleWhere((r) => r.id == request.id);
      expect(priced.status, DeliveryRequestStatus.priced);
      expect(
        priced.price,
        kMockPackageBaseFareEgp + kMockPackageCrossCitySurchargeEgp,
      );
      expect(priced.pricedAt, isNotNull);

      // Delivering before pickup is rejected.
      expect((await repo.markDelivered(request.id)).isLeft(), isTrue);

      final confirmed = (await repo.confirmRequest(request.id))
          .getOrElse((f) => fail('confirm failed: $f'));
      expect(confirmed.status, DeliveryRequestStatus.confirmed);
      expect(confirmed.courierId, 'courier_001');
      expect(confirmed.confirmedAt, isNotNull);

      // Confirming twice is rejected; so is cancelling after confirmation.
      expect((await repo.confirmRequest(request.id)).isLeft(), isTrue);
      expect(
        (await repo.cancelRequest(request.id, 'changed my mind')).isLeft(),
        isTrue,
      );

      // The confirmed request shows up on the courier's list.
      final packages = (await repo.getCourierPackages('courier_001'))
          .getOrElse((f) => fail('getCourierPackages failed: $f'));
      expect(packages.map((p) => p.id), contains(request.id));

      final pickedUp = (await repo.markPickedUp(request.id))
          .getOrElse((f) => fail('markPickedUp failed: $f'));
      expect(pickedUp.status, DeliveryRequestStatus.pickedUp);
      expect(pickedUp.pickedUpAt, isNotNull);
      expect((await repo.markPickedUp(request.id)).isLeft(), isTrue);

      final delivered = (await repo.markDelivered(request.id))
          .getOrElse((f) => fail('markDelivered failed: $f'));
      expect(delivered.status, DeliveryRequestStatus.delivered);
      expect(delivered.deliveredAt, isNotNull);

      // Terminal: no further transitions.
      expect(
        (await repo.cancelRequest(request.id, 'too late')).isLeft(),
        isTrue,
      );
    }, timeout: const Timeout(Duration(minutes: 1)));

    test('confirm is rejected while still submitted (not yet priced)',
        () async {
      // Default 10s admin delay: the request is still unpriced at confirm
      // time.
      final repo =
          DeliveryRequestRepositoryImpl(DeliveryRequestMockDataSource());
      final created = await repo.createRequest(
        consumerId: 'consumer_test',
        consumerName: 'Test Consumer',
        consumerPhone: '+201000000000',
        pickup: _pickup,
        dropoff: _dropoffSameCity,
        packageNote: 'unpriced parcel',
      );
      final request = created.getOrElse((f) => fail('create failed: $f'));
      expect((await repo.confirmRequest(request.id)).isLeft(), isTrue);
      // Cancelling a submitted request is allowed.
      final cancelled =
          (await repo.cancelRequest(request.id, 'no longer needed'))
              .getOrElse((f) => fail('cancel failed: $f'));
      expect(cancelled.status, DeliveryRequestStatus.cancelled);
      expect(cancelled.cancelReason, 'no longer needed');
    });

    test('unknown request id returns a failure', () async {
      final repo =
          DeliveryRequestRepositoryImpl(DeliveryRequestMockDataSource());
      expect((await repo.confirmRequest('pkg_missing')).isLeft(), isTrue);
    });

    test('seed data covers consumer and courier demo states', () async {
      final repo =
          DeliveryRequestRepositoryImpl(DeliveryRequestMockDataSource());

      final mine = (await repo.getMyRequests('consumer_001'))
          .getOrElse((f) => fail('getMyRequests failed: $f'));
      expect(mine, isNotEmpty);
      expect(
        mine.map((r) => r.status),
        containsAll(const [
          DeliveryRequestStatus.submitted,
          DeliveryRequestStatus.priced,
          DeliveryRequestStatus.confirmed,
        ]),
      );
      // Newest first.
      for (var i = 0; i < mine.length - 1; i++) {
        expect(
          mine[i].createdAt.isBefore(mine[i + 1].createdAt),
          isFalse,
          reason: 'getMyRequests must sort newest first',
        );
      }

      final packages = (await repo.getCourierPackages('courier_001'))
          .getOrElse((f) => fail('getCourierPackages failed: $f'));
      expect(
        packages.map((p) => p.status),
        containsAll(const [
          DeliveryRequestStatus.confirmed,
          DeliveryRequestStatus.pickedUp,
        ]),
      );
      // Every courier-visible package has a price to collect or hold.
      for (final p in packages) {
        expect(p.price, isNotNull);
      }
    });
  });
}
