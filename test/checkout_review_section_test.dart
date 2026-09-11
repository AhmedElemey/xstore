import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:xstore/core/localization/app_localizations.dart';
import 'package:xstore/core/localization/app_localizations_en.dart';
import 'package:xstore/features/cart/presentation/providers/cart_provider.dart';
import 'package:xstore/features/cart/presentation/providers/cart_state.dart';
import 'package:xstore/features/cart/presentation/providers/checkout_provider.dart';
import 'package:xstore/features/cart/presentation/providers/checkout_state.dart';
import 'package:xstore/features/cart/presentation/widgets/checkout_review_section.dart';
import 'package:xstore/features/orders/domain/entities/order_entity.dart';

class _InertCart extends Cart {
  @override
  CartState build() => const CartState();
}

class _CheckoutWithNote extends Checkout {
  _CheckoutWithNote(this.note);
  final String note;

  @override
  CheckoutState build() => CheckoutState(
        selectedPayment: PaymentMethod.cashOnDelivery,
        deliveryNote: note,
      );
}

void main() {
  final l10n = AppLocalizationsEn();

  Future<void> pumpReview(WidgetTester tester, {required String note}) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          cartProvider.overrideWith(_InertCart.new),
          checkoutProvider.overrideWith(() => _CheckoutWithNote(note)),
        ],
        child: MaterialApp(
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: AppLocalizations.supportedLocales,
          home: const Scaffold(body: CheckoutReviewSection()),
        ),
      ),
    );
  }

  testWidgets('confirm step shows the delivery note when one was entered',
      (tester) async {
    await pumpReview(tester, note: 'Leave at the door');

    expect(find.text(l10n.checkoutDeliveryNoteLabel), findsOneWidget);
    expect(find.text('Leave at the door'), findsOneWidget);
    expect(
      tester.getTopLeft(find.text(l10n.checkoutEstimatedDelivery)).dy,
      lessThan(tester.getTopLeft(find.text(l10n.checkoutDeliveryNoteLabel)).dy),
    );
  });

  testWidgets('confirm step hides the delivery note when it is empty',
      (tester) async {
    await pumpReview(tester, note: '   ');

    expect(find.text(l10n.checkoutDeliveryNoteLabel), findsNothing);
  });
}
