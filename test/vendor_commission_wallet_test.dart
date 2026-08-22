import 'package:flutter_test/flutter_test.dart';

import 'package:xstore/features/commission/domain/entities/vendor_commission_wallet.dart';

VendorCommissionWallet _wallet({bool warn = false, bool paused = false}) =>
    VendorCommissionWallet(
      exceedsWarnThreshold: warn,
      exceedsPauseThreshold: paused,
      warnThresholdEgp: 100,
      pauseThresholdEgp: 200,
    );

void main() {
  group('VendorCommissionWallet.alertLevel', () {
    test('neither flag set is none', () {
      expect(_wallet().alertLevel, VendorCommissionAlertLevel.none);
      expect(_wallet().isPaused, false);
    });

    test('warn flag set is warn', () {
      expect(_wallet(warn: true).alertLevel, VendorCommissionAlertLevel.warn);
      expect(_wallet(warn: true).isPaused, false);
    });

    test('pause flag set is paused, regardless of warn flag', () {
      expect(
        _wallet(paused: true).alertLevel,
        VendorCommissionAlertLevel.paused,
      );
      expect(
        _wallet(warn: true, paused: true).alertLevel,
        VendorCommissionAlertLevel.paused,
      );
      expect(_wallet(paused: true).isPaused, true);
    });
  });
}
