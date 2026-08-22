import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:xstore/core/localization/app_localizations.dart';
import 'package:xstore/core/localization/app_localizations_en.dart';
import 'package:xstore/features/cart/presentation/providers/checkout_provider.dart';
import 'package:xstore/features/cart/presentation/providers/checkout_state.dart';
import 'package:xstore/features/cart/presentation/widgets/checkout_payment_section.dart';
import 'package:xstore/features/orders/domain/entities/order_entity.dart';

class _SilentCheckout extends Checkout {
  @override
  CheckoutState build() => const CheckoutState(
        selectedPayment: PaymentMethod.cashOnDelivery,
      );

  @override
  void updateDeliveryNote(String v) {}
}

void main() {
  final l10n = AppLocalizationsEn();

  testWidgets('checkout payment step is COD-only with no card fields',
      (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          checkoutProvider.overrideWith(_SilentCheckout.new),
        ],
        child: MaterialApp(
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: AppLocalizations.supportedLocales,
          home: const Scaffold(body: CheckoutPaymentSection()),
        ),
      ),
    );

    expect(find.text(l10n.checkoutPayCodTitle), findsOneWidget);
    expect(find.text(l10n.checkoutPayCibTitle), findsNothing);
    expect(find.text(l10n.checkoutCardNumber), findsNothing);
    expect(find.text(l10n.checkoutCardCvv), findsNothing);
    expect(find.text(l10n.checkoutCardExpiry), findsNothing);

    final ctx = tester.element(find.byType(CheckoutPaymentSection));
    expect(
      checkoutPaymentLabel(ctx, PaymentMethod.cashOnDelivery),
      l10n.ordersPaymentCashOnDelivery,
    );
    expect(
      checkoutPaymentLabel(ctx, PaymentMethod.cibCard),
      l10n.ordersPaymentCib,
    );
  });
}
