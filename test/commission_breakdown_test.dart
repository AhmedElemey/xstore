import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:xstore/core/localization/app_localizations.dart';
import 'package:xstore/features/commission/domain/entities/commission_breakdown.dart';
import 'package:xstore/features/commission/presentation/widgets/commission_breakdown_card.dart';

void main() {
  group('CommissionBreakdown.forPrice', () {
    test('splits price into vendor earnings and platform fee', () {
      final b = CommissionBreakdown.forPrice(1000, ratePercent: 2.0);

      expect(b.feeAmount, 20.0);
      expect(b.vendorEarns, 980.0);
      expect(b.price, 1000.0);
      expect(b.ratePercent, 2.0);
    });

    test('zero rate means vendor keeps the full price', () {
      final b = CommissionBreakdown.forPrice(500, ratePercent: 0);

      expect(b.feeAmount, 0.0);
      expect(b.vendorEarns, 500.0);
    });
  });

  group('CommissionBreakdownCard', () {
    testWidgets('renders vendor earnings and platform fee with currency',
        (tester) async {
      final breakdown = CommissionBreakdown.forPrice(1000, ratePercent: 2.0);

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

      expect(find.textContaining('980.00'), findsOneWidget);
      expect(find.textContaining('20.00'), findsOneWidget);
      expect(find.textContaining('2%'), findsOneWidget);
    });
  });
}
