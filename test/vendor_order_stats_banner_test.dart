import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:xstore/core/localization/app_localizations.dart';
import 'package:xstore/features/orders/presentation/widgets/vendor_order_stats_banner.dart';

Future<void> _pump(WidgetTester tester, int pending) {
  return tester.pumpWidget(
    MaterialApp(
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(
        body: VendorOrderStatsBanner(
          pendingCount: pending,
          activeCount: 1,
          totalCount: 3,
          totalRevenue: 100,
          onConfirmAllPending: () {},
        ),
      ),
    ),
  );
}

void main() {
  testWidgets('hides Confirm All Pending when nothing is pending', (
    tester,
  ) async {
    await _pump(tester, 0);
    expect(find.text('Confirm All Pending'), findsNothing);
  });

  testWidgets('shows Confirm All Pending when orders are pending', (
    tester,
  ) async {
    await _pump(tester, 2);
    expect(find.text('Confirm All Pending'), findsOneWidget);
  });
}
