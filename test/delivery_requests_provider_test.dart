import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:xstore/core/mock/mock_users.dart';
import 'package:xstore/features/auth/presentation/providers/auth_provider.dart';
import 'package:xstore/features/delivery/presentation/providers/delivery_request_dependencies.dart';
import 'package:xstore/features/delivery/presentation/providers/delivery_requests_provider.dart';
import 'package:xstore/features/orders/domain/entities/order_entity.dart';

import 'helpers/fake_async_auth_notifier.dart';
import 'helpers/stub_delivery_request_repository.dart';

void main() {
  test('consumer and vendor sessions can both fetch their own requests',
      () async {
    for (final user in [mockConsumerUser, mockVendorUser]) {
      final container = ProviderContainer(
        overrides: [
          authProvider.overrideWith(() => FakeAuth(user)),
          deliveryRequestRepositoryProvider.overrideWithValue(
            StubDeliveryRequestRepository(
              myRequests: [
                testPackageRequest(id: 'pkg_${user.id}'),
              ],
            ),
          ),
        ],
      );
      addTearDown(container.dispose);
      // Pin the autoDispose notifier alive across the awaits below (mirrors
      // the widget tree's implicit watch in the real app).
      container.listen(deliveryRequestsProvider, (_, __) {});

      await container.read(authProvider.future);
      await container
          .read(deliveryRequestsProvider.notifier)
          .fetchRequests();

      final state = container.read(deliveryRequestsProvider);
      expect(
        state.requests.map((r) => r.id),
        ['pkg_${user.id}'],
        reason: '${user.role} should see their own requests',
      );
    }
  });

  test('courier session fetches nothing (couriers use their own tab)',
      () async {
    final container = ProviderContainer(
      overrides: [
        authProvider.overrideWith(() => FakeAuth(mockCourierUser)),
        deliveryRequestRepositoryProvider.overrideWithValue(
          StubDeliveryRequestRepository(
            myRequests: [testPackageRequest()],
          ),
        ),
      ],
    );
    addTearDown(container.dispose);
    container.listen(deliveryRequestsProvider, (_, __) {});

    await container.read(authProvider.future);
    await container.read(deliveryRequestsProvider.notifier).fetchRequests();

    final state = container.read(deliveryRequestsProvider);
    expect(state.requests, isEmpty);
    expect(state.isLoading, isFalse);
  });

  test('vendor session can submit a new request', () async {
    final container = ProviderContainer(
      overrides: [
        authProvider.overrideWith(() => FakeAuth(mockVendorUser)),
        deliveryRequestRepositoryProvider.overrideWithValue(
          StubDeliveryRequestRepository(),
        ),
      ],
    );
    addTearDown(container.dispose);
    container.listen(deliveryRequestsProvider, (_, __) {});

    await container.read(authProvider.future);
    final ok =
        await container.read(deliveryRequestsProvider.notifier).createRequest(
              pickup: const OrderAddress(
                fullName: 'Vendor Store',
                phone: '+201055500001',
                street: '3 Talaat Harb St',
                city: 'Downtown Cairo',
                wilaya: 'Cairo',
              ),
              dropoff: const OrderAddress(
                fullName: 'Supplier',
                phone: '+201155500014',
                street: '40 El Haram St',
                city: 'Giza',
                wilaya: 'Giza',
              ),
              packageNote: 'Return parcel',
            );

    expect(ok, isTrue);
    final state = container.read(deliveryRequestsProvider);
    expect(state.requests.single.requesterId, mockVendorUser.id);
  });
}
