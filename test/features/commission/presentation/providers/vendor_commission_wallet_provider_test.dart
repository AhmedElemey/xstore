// Covers vendorCommissionWalletProvider's mapping from the vendor-order-stats
// snapshot to VendorCommissionWallet, including its fallback thresholds when
// the backend sends null/no snapshot — no dedicated test existed before.
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';

import 'package:xstore/core/error/failures.dart';
import 'package:xstore/core/mock/mock_users.dart';
import 'package:xstore/features/auth/presentation/providers/auth_provider.dart';
import 'package:xstore/features/commission/domain/entities/vendor_commission_wallet.dart';
import 'package:xstore/features/commission/presentation/providers/commission_config_provider.dart';
import 'package:xstore/features/commission/presentation/providers/vendor_commission_wallet_provider.dart';
import 'package:xstore/features/orders/domain/entities/order_entity.dart';
import 'package:xstore/features/orders/presentation/providers/orders_dependencies.dart';

import '../../../../helpers/fake_async_auth_notifier.dart';
import '../../../../helpers/stub_orders_repository.dart';

ProviderContainer _containerFor(dynamic user, {StubOrdersRepository? repo}) {
  final container = ProviderContainer(
    overrides: [
      authProvider.overrideWith(() => FakeAuth(user)),
      ordersRepositoryProvider.overrideWithValue(repo ?? StubOrdersRepository()),
    ],
  );
  addTearDown(container.dispose);
  container.listen(vendorCommissionWalletProvider, (_, __) {});
  return container;
}

void main() {
  group('vendorCommissionWalletProvider', () {
    test('is the empty wallet with default thresholds for a signed-out session',
        () async {
      final container = _containerFor(null);

      final wallet = await container.read(vendorCommissionWalletProvider.future);

      expect(wallet.exceedsWarnThreshold, isFalse);
      expect(wallet.exceedsPauseThreshold, isFalse);
      expect(wallet.warnThresholdEgp, kCommissionWarnThresholdEgp);
      expect(wallet.pauseThresholdEgp, kCommissionPauseThresholdEgp);
      expect(wallet.alertLevel, VendorCommissionAlertLevel.none);
    });

    test('falls back to default thresholds when the snapshot fetch fails', () async {
      final container = _containerFor(
        mockVendorUser,
        repo: StubOrdersRepository(
          getVendorStatsResult: ({required vendorId}) =>
              Left(Failure.server('down')),
        ),
      );

      final wallet = await container.read(vendorCommissionWalletProvider.future);

      expect(wallet.warnThresholdEgp, kCommissionWarnThresholdEgp);
      expect(wallet.pauseThresholdEgp, kCommissionPauseThresholdEgp);
      expect(wallet.alertLevel, VendorCommissionAlertLevel.none);
    });

    test('maps the backend exceeds-threshold flags and thresholds through', () async {
      final container = _containerFor(
        mockVendorUser,
        repo: StubOrdersRepository(
          getVendorStatsResult: ({required vendorId}) => const Right(
            OrderStatsEntity(
              warnThresholdEgp: 150,
              pauseThresholdEgp: 300,
              exceedsWarnThreshold: true,
              exceedsPauseThreshold: true,
            ),
          ),
        ),
      );

      final wallet = await container.read(vendorCommissionWalletProvider.future);

      expect(wallet.warnThresholdEgp, 150);
      expect(wallet.pauseThresholdEgp, 300);
      expect(wallet.exceedsWarnThreshold, isTrue);
      expect(wallet.exceedsPauseThreshold, isTrue);
      // Paused takes precedence over warn regardless of both flags being set.
      expect(wallet.alertLevel, VendorCommissionAlertLevel.paused);
    });

    test(
        'falls back to default thresholds when the backend sends the flags '
        'but omits the threshold numbers', () async {
      final container = _containerFor(
        mockVendorUser,
        repo: StubOrdersRepository(
          getVendorStatsResult: ({required vendorId}) => const Right(
            OrderStatsEntity(exceedsWarnThreshold: true),
          ),
        ),
      );

      final wallet = await container.read(vendorCommissionWalletProvider.future);

      expect(wallet.warnThresholdEgp, kCommissionWarnThresholdEgp);
      expect(wallet.pauseThresholdEgp, kCommissionPauseThresholdEgp);
      expect(wallet.alertLevel, VendorCommissionAlertLevel.warn);
    });
  });
}
