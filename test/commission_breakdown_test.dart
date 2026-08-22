import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:xstore/core/localization/app_localizations.dart';
import 'package:xstore/features/commission/domain/entities/commission_breakdown.dart';
import 'package:xstore/features/commission/presentation/widgets/commission_breakdown_card.dart';

void main() {
  group('CommissionBreakdown.forPrice', () {
    test('subtracts flat fee from price for vendor earnings', () {
      final b = CommissionBreakdown.forPrice(1000, feeEgp: 2.0);

      expect(b.feeAmount, 2.0);
      expect(b.vendorEarns, 998.0);
      expect(b.price, 1000.0);
    });

    test('zero fee means vendor keeps the full price', () {
      final b = CommissionBreakdown.forPrice(500, feeEgp: 0);

      expect(b.feeAmount, 0.0);
      expect(b.vendorEarns, 500.0);
    });
  });

  group('CommissionBreakdownCard', () {
    testWidgets('renders vendor earnings and platform fee with currency',
        (tester) async {
      final breakdown = CommissionBreakdown.forPrice(1000, feeEgp: 2.0);

      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(
            body: CommissionBreakdownCard(
              breakdown: breakdown,
              currencyCode: 'EGP',
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.textContaining('998.00'), findsOneWidget);
      expect(find.textContaining('2.00'), findsOneWidget);
      expect(find.textContaining('%'), findsNothing);
    });
  });
}
