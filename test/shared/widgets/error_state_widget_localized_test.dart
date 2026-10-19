import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:xstore/core/localization/app_localizations.dart';
import 'package:xstore/shared/widgets/error_state_widget.dart';

Widget _app(Locale locale, String message) => MaterialApp(
  locale: locale,
  localizationsDelegates: AppLocalizations.localizationsDelegates,
  supportedLocales: AppLocalizations.supportedLocales,
  home: Scaffold(body: ErrorStateWidget(message: message)),
);

void main() {
  const en = 'Something went wrong. Please try again later.';
  const ar = 'حصلت مشكلة. حاول تاني بعدين.';

  testWidgets('generic error follows the current language', (tester) async {
    // Worded in English when it happened, shown after switching to Arabic.
    await tester.pumpWidget(_app(const Locale('ar'), en));
    await tester.pumpAndSettle();
    expect(find.text(ar), findsOneWidget);
    expect(find.text(en), findsNothing);

    await tester.pumpWidget(_app(const Locale('en'), ar));
    await tester.pumpAndSettle();
    expect(find.text(en), findsOneWidget);
  });

  testWidgets('specific messages are shown as they are', (tester) async {
    await tester.pumpWidget(_app(const Locale('ar'), 'Out of stock'));
    await tester.pumpAndSettle();
    expect(find.text('Out of stock'), findsOneWidget);
  });
}
