import '../../../../core/mock/mock_config.dart';
import '../../../../core/mock/mock_users.dart';
import '../../../orders/domain/entities/order_entity.dart';
import '../../domain/entities/delivery_request.dart';

/// ADMIN PRICING SIMULATION — the single place the mock formula lives.
///
/// There is no backend for package requests yet; the "admin sets the price"
/// step is simulated lazily: on any read, a `submitted` request older than
/// [kMockAdminPricingDelay] is auto-priced with [mockPackagePrice]
/// (no timers involved).
const Duration kMockAdminPricingDelay = Duration(seconds: 10);

/// Base fare for a package delivery (EGP).
const double kMockPackageBaseFareEgp = 60;

/// Surcharge when pickup and dropoff are in different cities (EGP).
const double kMockPackageCrossCitySurchargeEgp = 20;

double mockPackagePrice(OrderAddress pickup, OrderAddress dropoff) {
  final sameCity = pickup.city.trim().toLowerCase() ==
      dropoff.city.trim().toLowerCase();
  return kMockPackageBaseFareEgp +
      (sameCity ? 0 : kMockPackageCrossCitySurchargeEgp);
}

/// In-memory store for package delivery requests (no backend exists — this
/// is the pilot's demo data path, always active regardless of
/// `MockConfig.useMock`).
///
/// All state is INSTANCE fields: the store lives exactly as long as the
/// provider that owns it (see `deliveryRequestDataSourceProvider`), so a
/// logout that rebuilds the provider drops the previous user's data — never
/// use static fields for user-scoped caches.
class DeliveryRequestMockDataSource {
  DeliveryRequestMockDataSource({
    this.adminPricingDelay = kMockAdminPricingDelay,
  }) {
    _seed();
  }

  /// Overridable so tests don't wait 10 real seconds.
  final Duration adminPricingDelay;

  final List<DeliveryRequestEntity> _requests = [];
  int _idSeq = 0;

  String _nextId() =>
      'pkg_${(++_idSeq).toString().padLeft(3, '0')}';

  void _seed() {
    final now = DateTime.now();

    OrderAddress addr({
      required String name,
      required String phone,
      required String street,
      required String city,
    }) =>
        OrderAddress(
          fullName: name,
          phone: phone,
          street: street,
          city: city,
          wilaya: 'Cairo',
        );

    final senderAddr = addr(
      name: mockConsumerUser.name,
      phone: mockConsumerUser.phoneNumber,
      street: '15 Abbas El Akkad St',
      city: 'Nasr City',
    );

    DeliveryRequestEntity request({
      required DeliveryRequestStatus status,
      required OrderAddress dropoff,
      required String note,
      required Duration age,
      String? courierId,
      Duration? pickedUpAge,
    }) {
      final createdAt = now.subtract(age);
      final priced = status != DeliveryRequestStatus.submitted;
      final price = priced ? mockPackagePrice(senderAddr, dropoff) : null;
      final confirmed = status == DeliveryRequestStatus.confirmed ||
          status == DeliveryRequestStatus.pickedUp ||
          status == DeliveryRequestStatus.delivered;
      return DeliveryRequestEntity(
        id: _nextId(),
        consumerId: mockConsumerUser.id,
        consumerName: mockConsumerUser.name,
        consumerPhone: mockConsumerUser.phoneNumber,
        pickup: senderAddr,
        dropoff: dropoff,
        packageNote: note,
        price: price,
        status: status,
        courierId: courierId,
        createdAt: createdAt,
        updatedAt: now.subtract(pickedUpAge ?? age),
        pricedAt: priced ? createdAt.add(const Duration(minutes: 5)) : null,
        confirmedAt:
            confirmed ? createdAt.add(const Duration(minutes: 10)) : null,
        pickedUpAt: pickedUpAge != null ? now.subtract(pickedUpAge) : null,
      );
    }

    _requests.addAll([
      // Fresh submitted request — auto-prices ~10s after the store is first
      // read, so the consumer demo shows the submitted → priced transition.
      request(
        status: DeliveryRequestStatus.submitted,
        dropoff: addr(
          name: 'Laila Hassan',
          phone: '+201155500010',
          street: '8 El Merghany St',
          city: 'Heliopolis',
        ),
        note: 'Envelope with signed contract — handle with care',
        age: Duration.zero,
      ),
      // Priced, waiting for the consumer to confirm (cross-city: 80 EGP).
      request(
        status: DeliveryRequestStatus.priced,
        dropoff: addr(
          name: 'Omar Fathy',
          phone: '+201155500011',
          street: '22 Gameat El Dewal St',
          city: 'Mohandessin',
        ),
        note: 'Small box of homemade sweets',
        age: const Duration(minutes: 30),
      ),
      // Confirmed and assigned — appears in the courier's active run.
      request(
        status: DeliveryRequestStatus.confirmed,
        dropoff: addr(
          name: 'Nour El-Din',
          phone: '+201155500012',
          street: '5 Makram Ebeid St',
          city: 'Nasr City',
        ),
        note: 'Spare laptop charger',
        age: const Duration(hours: 2),
        courierId: mockCourierUser.id,
      ),
      // Picked up — cash already collected, courier is on the way.
      request(
        status: DeliveryRequestStatus.pickedUp,
        dropoff: addr(
          name: 'Hana Mahmoud',
          phone: '+201155500013',
          street: '12 Baghdad St',
          city: 'Heliopolis',
        ),
        note: 'Birthday gift, fragile',
        age: const Duration(hours: 4),
        courierId: mockCourierUser.id,
        pickedUpAge: const Duration(hours: 1),
      ),
    ]);
  }

  /// Lazy admin simulation: prices every `submitted` request older than
  /// [adminPricingDelay]. Runs on every public call so no timers are needed.
  void _autoPriceStaleSubmitted() {
    final now = DateTime.now();
    for (var i = 0; i < _requests.length; i++) {
      final r = _requests[i];
      if (r.status != DeliveryRequestStatus.submitted) continue;
      if (now.difference(r.createdAt) < adminPricingDelay) continue;
      _requests[i] = r.copyWith(
        status: DeliveryRequestStatus.priced,
        price: mockPackagePrice(r.pickup, r.dropoff),
        pricedAt: now,
        updatedAt: now,
      );
    }
  }

  Future<List<DeliveryRequestEntity>> getMyRequests(String consumerId) {
    _autoPriceStaleSubmitted();
    final mine = _requests.where((r) => r.consumerId == consumerId).toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return MockConfig.simulate(mine);
  }

  Future<DeliveryRequestEntity> createRequest({
    required String consumerId,
    required String consumerName,
    required String consumerPhone,
    required OrderAddress pickup,
    required OrderAddress dropoff,
    required String packageNote,
  }) {
    _autoPriceStaleSubmitted();
    final now = DateTime.now();
    final request = DeliveryRequestEntity(
      id: _nextId(),
      consumerId: consumerId,
      consumerName: consumerName,
      consumerPhone: consumerPhone,
      pickup: pickup,
      dropoff: dropoff,
      packageNote: packageNote,
      status: DeliveryRequestStatus.submitted,
      createdAt: now,
      updatedAt: now,
    );
    _requests.add(request);
    return MockConfig.simulate(request);
  }

  Future<DeliveryRequestEntity> confirmRequest(String id) {
    _autoPriceStaleSubmitted();
    final now = DateTime.now();
    final next = _transition(
      id,
      from: const {DeliveryRequestStatus.priced},
      patch: (r) => r.copyWith(
        status: DeliveryRequestStatus.confirmed,
        confirmedAt: now,
        updatedAt: now,
        // Pilot: admin assigns the single demo courier on confirmation.
        courierId: mockCourierUser.id,
      ),
    );
    return MockConfig.simulate(next);
  }

  Future<DeliveryRequestEntity> cancelRequest(String id, String reason) {
    _autoPriceStaleSubmitted();
    final now = DateTime.now();
    final next = _transition(
      id,
      from: const {
        DeliveryRequestStatus.submitted,
        DeliveryRequestStatus.priced,
      },
      patch: (r) => r.copyWith(
        status: DeliveryRequestStatus.cancelled,
        cancelReason: reason,
        updatedAt: now,
      ),
    );
    return MockConfig.simulate(next);
  }

  Future<List<DeliveryRequestEntity>> getCourierPackages(String courierId) {
    _autoPriceStaleSubmitted();
    const courierVisible = {
      DeliveryRequestStatus.confirmed,
      DeliveryRequestStatus.pickedUp,
      DeliveryRequestStatus.delivered,
    };
    final assigned = _requests
        .where((r) =>
            r.courierId == courierId && courierVisible.contains(r.status))
        .toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return MockConfig.simulate(assigned);
  }

  Future<DeliveryRequestEntity> markPickedUp(String id) {
    _autoPriceStaleSubmitted();
    final now = DateTime.now();
    final next = _transition(
      id,
      from: const {DeliveryRequestStatus.confirmed},
      patch: (r) => r.copyWith(
        status: DeliveryRequestStatus.pickedUp,
        pickedUpAt: now,
        updatedAt: now,
      ),
    );
    return MockConfig.simulate(next);
  }

  Future<DeliveryRequestEntity> markDelivered(String id) {
    _autoPriceStaleSubmitted();
    final now = DateTime.now();
    final next = _transition(
      id,
      from: const {DeliveryRequestStatus.pickedUp},
      patch: (r) => r.copyWith(
        status: DeliveryRequestStatus.delivered,
        deliveredAt: now,
        updatedAt: now,
      ),
    );
    return MockConfig.simulate(next);
  }

  DeliveryRequestEntity _transition(
    String id, {
    required Set<DeliveryRequestStatus> from,
    required DeliveryRequestEntity Function(DeliveryRequestEntity) patch,
  }) {
    final index = _requests.indexWhere((r) => r.id == id);
    if (index < 0) {
      throw StateError('Delivery request not found: $id');
    }
    final current = _requests[index];
    if (!from.contains(current.status)) {
      throw StateError(
        'Invalid transition from ${current.status.name} for request $id',
      );
    }
    final next = patch(current);
    _requests[index] = next;
    return next;
  }
}
