// Covers vendorCommissionSnapshotProvider (the only vendor-reachable echo of
// the admin-only commission config, per commission_config_provider.dart's
// own doc comment) and commissionFeeEgpForCategoryProvider's fallback — no
// dedicated test existed for either before this file.
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';

import 'package:xstore/core/error/failures.dart';
import 'package:xstore/core/mock/mock_users.dart';
import 'package:xstore/features/auth/presentation/providers/auth_provider.dart';
import 'package:xstore/features/commission/presentation/providers/commission_config_provider.dart';
import 'package:xstore/features/orders/domain/entities/order_entity.dart';
import 'package:xstore/features/orders/presentation/providers/orders_dependencies.dart';

import '../../../../helpers/fake_async_auth_notifier.dart';
import '../../../../helpers/stub_orders_repository.dart';

const _stats = OrderStatsEntity(
  pendingCount: 3,
  activeCount: 2,
  monthCount: 5,
  totalCount: 10,
  totalRevenue: 4500,
  commissionValueOnOrder: 3.5,
  warnThresholdEgp: 150,
  pauseThresholdEgp: 300,
  exceedsWarnThreshold: true,
  exceedsPauseThreshold: false,
);

ProviderContainer _containerFor(dynamic user, {StubOrdersRepository? repo}) {
  final container = ProviderContainer(
    overrides: [
      authProvider.overrideWith(() => FakeAuth(user)),
      ordersRepositoryProvider.overrideWithValue(repo ?? StubOrdersRepository()),
    ],
  );
  addTearDown(container.dispose);
  // autoDispose FutureProviders need a real listener held open across the
  // awaited fetch below, or the provider can be disposed mid-flight and
  // silently rebuilt (see the 2026-08-29 "bare container.read doesn't keep
  // an autoDispose provider alive across an await" lesson).
  container.listen(vendorCommissionSnapshotProvider, (_, __) {});
  return container;
}

void main() {
  group('vendorCommissionSnapshotProvider', () {
    test('is null for a signed-out session', () async {
      final container = _containerFor(null);
      final snapshot = await container.read(vendorCommissionSnapshotProvider.future);
      expect(snapshot, isNull);
    });

    test('is null for a non-vendor (consumer) session', () async {
      final container = _containerFor(mockConsumerUser);
      final snapshot = await container.read(vendorCommissionSnapshotProvider.future);
      expect(snapshot, isNull);
    });

    test('returns the fetched stats for a vendor session', () async {
      final container = _containerFor(
        mockVendorUser,
        repo: StubOrdersRepository(
          getVendorStatsResult: ({required vendorId}) => const Right(_stats),
        ),
      );
      final snapshot = await container.read(vendorCommissionSnapshotProvider.future);
      expect(snapshot, _stats);
    });

    test('is null when the stats fetch fails', () async {
      final container = _containerFor(
        mockVendorUser,
        repo: StubOrdersRepository(
          getVendorStatsResult: ({required vendorId}) =>
              Left(Failure.network('offline')),
        ),
      );
      final snapshot = await container.read(vendorCommissionSnapshotProvider.future);
      expect(snapshot, isNull);
    });
  });

  group('commissionFeeEgpForCategoryProvider', () {
    // Plain (synchronous) @riverpod provider derived from the async
    // snapshot via .valueOrNull — awaiting the snapshot's own .future first
    // guarantees it has already resolved by the time this is read.
    test('falls back to the starter fee when the snapshot is null', () async {
      final container = _containerFor(mockConsumerUser);
      await container.read(vendorCommissionSnapshotProvider.future);

      final fee = container.read(commissionFeeEgpForCategoryProvider(7));

      expect(fee, kStarterCommissionFeeEgp);
    });

    test('uses the backend commission value once the snapshot loads', () async {
      final container = _containerFor(
        mockVendorUser,
        repo: StubOrdersRepository(
          getVendorStatsResult: ({required vendorId}) => const Right(_stats),
        ),
      );
      await container.read(vendorCommissionSnapshotProvider.future);

      final fee = container.read(commissionFeeEgpForCategoryProvider(7));

      expect(fee, 3.5);
    });

    test('falls back to the starter fee when the backend echoes 0', () async {
      final container = _containerFor(
        mockVendorUser,
        repo: StubOrdersRepository(
          getVendorStatsResult: ({required vendorId}) => const Right(
            OrderStatsEntity(
              pendingCount: 0,
              activeCount: 0,
              monthCount: 0,
              totalCount: 0,
              totalRevenue: 0,
              commissionValueOnOrder: 0,
            ),
          ),
        ),
      );
      await container.read(vendorCommissionSnapshotProvider.future);

      final fee = container.read(commissionFeeEgpForCategoryProvider(null));

      expect(fee, kStarterCommissionFeeEgp);
    });
  });
}
