import 'package:flutter_test/flutter_test.dart';

import 'package:xstore/features/commission/domain/entities/vendor_commission_wallet.dart';

VendorCommissionWallet _wallet(double outstanding) => VendorCommissionWallet(
      outstandingEgp: outstanding,
      warnThresholdEgp: 100,
      pauseThresholdEgp: 200,
    );

void main() {
  group('VendorCommissionWallet.alertLevel', () {
    test('below warn threshold is none', () {
      expect(_wallet(50).alertLevel, VendorCommissionAlertLevel.none);
      expect(_wallet(50).isPaused, false);
    });

    test('at or above warn but below pause is warn', () {
      expect(_wallet(100).alertLevel, VendorCommissionAlertLevel.warn);
      expect(_wallet(150).alertLevel, VendorCommissionAlertLevel.warn);
      expect(_wallet(150).isPaused, false);
    });

    test('at or above pause threshold is paused', () {
      expect(_wallet(200).alertLevel, VendorCommissionAlertLevel.paused);
      expect(_wallet(500).alertLevel, VendorCommissionAlertLevel.paused);
      expect(_wallet(200).isPaused, true);
    });
  });
}
