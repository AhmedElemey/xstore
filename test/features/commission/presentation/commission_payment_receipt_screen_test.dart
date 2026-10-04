import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:xstore/core/localization/app_localizations.dart';
import 'package:xstore/features/commission/domain/entities/commission_payment_method.dart';
import 'package:xstore/features/commission/presentation/providers/commission_payment_providers.dart';
import 'package:xstore/features/commission/presentation/screens/commission_payment_receipt_screen.dart';
import 'package:xstore/shared/widgets/xstore_button.dart';

Future<void> _pumpScreen(
  WidgetTester tester, {
  required Map<CommissionPaymentMethod, String> accounts,
  CommissionPaymentMethod method = CommissionPaymentMethod.vodafoneCash,
}) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        commissionPayToAccountsProvider.overrideWith((ref) async => accounts),
      ],
      child: MaterialApp(
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: AppLocalizations.supportedLocales,
        home: CommissionPaymentReceiptScreen(method: method),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

VoidCallback? _submitOnPressed(WidgetTester tester) =>
    tester.widget<XstoreButton>(find.byType(XstoreButton)).onPressed;

void main() {
  testWidgets('shows the configured account for the chosen method', (
    tester,
  ) async {
    await _pumpScreen(
      tester,
      accounts: const {
        CommissionPaymentMethod.vodafoneCash: '01000000000',
        CommissionPaymentMethod.instaPay: 'xstore@instapay',
      },
    );

    expect(find.text('Send the payment to'), findsOneWidget);
    expect(find.text('01000000000'), findsOneWidget);
    expect(find.text('xstore@instapay'), findsNothing);
    expect(find.byTooltip('Copied'), findsOneWidget);
  });

  testWidgets('tells the vendor to contact support when no account is set', (
    tester,
  ) async {
    await _pumpScreen(tester, accounts: const {});

    expect(
      find.text(
        "The Vodafone Cash account isn't set up yet. "
        'Contact xStore support before sending money.',
      ),
      findsOneWidget,
    );
    expect(find.byTooltip('Copied'), findsNothing);
  });

  testWidgets('submit stays disabled until a valid amount and a receipt', (
    tester,
  ) async {
    await _pumpScreen(tester, accounts: const {});
    expect(_submitOnPressed(tester), isNull);

    await tester.enterText(find.byType(TextField), 'abc');
    await tester.pump();
    expect(find.text('Enter the amount you sent'), findsOneWidget);
    expect(_submitOnPressed(tester), isNull);

    await tester.enterText(find.byType(TextField), '0');
    await tester.pump();
    expect(find.text('Enter the amount you sent'), findsOneWidget);

    // A valid amount alone is not enough — the receipt is required too.
    await tester.enterText(find.byType(TextField), '1,250');
    await tester.pump();
    expect(find.text('Enter the amount you sent'), findsNothing);
    expect(_submitOnPressed(tester), isNull);
    expect(find.text('Camera'), findsOneWidget);
    expect(find.text('Gallery'), findsOneWidget);
  });
}
