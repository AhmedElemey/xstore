// Regression test for: the Wallet screen (and every other screen using
// context.formatCurrency) showed "EGP 2,000" (symbol first). Changed to
// "2,000 LE" (symbol trailing) to match the convention Arabic already used
// ("٢٬٠٠٠ ج.م" — the 'ar_EG' currency pattern already trails the symbol).
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/intl.dart';

import 'package:xstore/core/localization/app_localizations.dart';
import 'package:xstore/core/utils/extensions/context_extensions.dart';

void main() {
  Future<String> formatted(
    WidgetTester tester,
    double amount, {
    required Locale locale,
  }) async {
    late String result;
    await tester.pumpWidget(
      MaterialApp(
        locale: locale,
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: AppLocalizations.supportedLocales,
        home: Builder(
          builder: (context) {
            result = context.formatCurrency(amount);
            return const SizedBox.shrink();
          },
        ),
      ),
    );
    await tester.pump();
    return result;
  }

  testWidgets('English shows the amount followed by LE, not EGP first', (
    tester,
  ) async {
    expect(
      await formatted(tester, 2000, locale: const Locale('en')),
      '2,000 LE',
    );
    expect(
      await formatted(tester, 3, locale: const Locale('en')),
      '3 LE',
    );
    // Negative amounts (e.g. a discounted "you earn" going below zero)
    // still round and suffix correctly.
    expect(
      await formatted(tester, -3, locale: const Locale('en')),
      '-3 LE',
    );
  });

  testWidgets(
    'Arabic keeps its existing trailing-symbol format, untouched',
    (tester) async {
      // Compares against the same NumberFormat.currency call this branch
      // was already using — proves the Arabic path is untouched by this
      // change, without pinning fragile invisible RTL-mark/NBSP characters
      // that call produces (confirmed via codeUnits: it already trails the
      // symbol, e.g. U+200F + "٢٬٠٠٠" + U+00A0 + "ج.م ").
      final reference = NumberFormat.currency(
        locale: 'ar_EG',
        symbol: 'ج.م ',
        decimalDigits: 0,
      ).format(2000);
      expect(
        await formatted(tester, 2000, locale: const Locale('ar')),
        reference,
      );
      expect(reference, contains('ج.م'));
      expect(reference, isNot(startsWith('ج.م')));
    },
  );
}
