import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:xstore/core/localization/app_localizations.dart';
import 'package:xstore/features/cart/presentation/providers/cart_provider.dart';
import 'package:xstore/features/cart/presentation/providers/cart_state.dart';
import 'package:xstore/features/cart/presentation/widgets/cart_consumer_body.dart';
import 'package:xstore/features/cart/presentation/widgets/cart_empty_state.dart';
import 'package:xstore/shared/widgets/error_state_widget.dart';

class _ErrorEmptyCart extends Cart {
  @override
  CartState build() => const CartState(error: 'Failed to fetch cart');
}

class _EmptyCart extends Cart {
  @override
  CartState build() => const CartState();
}

Widget _harness(Cart Function() cart) {
  return ProviderScope(
    overrides: [cartProvider.overrideWith(cart)],
    child: const MaterialApp(
      localizationsDelegates: [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(body: CartConsumerBody()),
    ),
  );
}

void main() {
  testWidgets(
    'shows error state, not empty cart, when fetch failed with no items',
    (tester) async {
      await tester.pumpWidget(_harness(_ErrorEmptyCart.new));
      await tester.pumpAndSettle();

      expect(find.byType(ErrorStateWidget), findsOneWidget);
      expect(find.text('Failed to fetch cart'), findsOneWidget);
      expect(find.byType(CartEmptyState), findsNothing);
    },
  );

  testWidgets('shows empty cart when there are no items and no error',
      (tester) async {
    await tester.pumpWidget(_harness(_EmptyCart.new));
    await tester.pumpAndSettle();

    expect(find.byType(CartEmptyState), findsOneWidget);
    expect(find.byType(ErrorStateWidget), findsNothing);
  });
}
