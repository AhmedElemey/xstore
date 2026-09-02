// VendorCommissionAlertBanner is pure (no ref reads) but had no widget test
// covering its three render states — none/warn/paused — before this file.
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:xstore/core/localization/app_localizations.dart';
import 'package:xstore/features/commission/domain/entities/vendor_commission_wallet.dart';
import 'package:xstore/features/commission/presentation/widgets/vendor_commission_alert_banner.dart';

Future<void> _pump(WidgetTester tester, VendorCommissionWallet wallet) {
  return tester.pumpWidget(
    MaterialApp(
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(body: VendorCommissionAlertBanner(wallet: wallet)),
    ),
  );
}

void main() {
  group('VendorCommissionAlertBanner', () {
    testWidgets('renders nothing at alertLevel.none', (tester) async {
      await _pump(
        tester,
        const VendorCommissionWallet(
          exceedsWarnThreshold: false,
          exceedsPauseThreshold: false,
          warnThresholdEgp: 100,
          pauseThresholdEgp: 200,
        ),
      );

      expect(find.byType(VendorCommissionAlertBanner), findsOneWidget);
      expect(find.text('Pay your platform fees soon'), findsNothing);
      expect(find.text('New listings are paused'), findsNothing);
    });

    testWidgets('shows the warn title and the warn threshold at alertLevel.warn',
        (tester) async {
      await _pump(
        tester,
        const VendorCommissionWallet(
          exceedsWarnThreshold: true,
          exceedsPauseThreshold: false,
          warnThresholdEgp: 100,
          pauseThresholdEgp: 200,
        ),
      );

      expect(find.text('Pay your platform fees soon'), findsOneWidget);
      expect(find.textContaining('100'), findsOneWidget);
      expect(find.text('New listings are paused'), findsNothing);
    });

    testWidgets(
        'shows the paused title and the pause threshold at alertLevel.paused',
        (tester) async {
      await _pump(
        tester,
        const VendorCommissionWallet(
          exceedsWarnThreshold: true,
          exceedsPauseThreshold: true,
          warnThresholdEgp: 100,
          pauseThresholdEgp: 200,
        ),
      );

      // Paused takes precedence — the banner shows the pause copy/threshold,
      // not the warn one, even though both flags are set.
      expect(find.text('New listings are paused'), findsOneWidget);
      expect(find.textContaining('200'), findsOneWidget);
      expect(find.text('Pay your platform fees soon'), findsNothing);
    });
  });
}
