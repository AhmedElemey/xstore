import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:xstore/app.dart';

void main() {
  testWidgets('App starts on splash with xStore branding', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: XstoreApp(),
      ),
    );
    await tester.pump();

    expect(find.text('xStore'), findsOneWidget);
    expect(find.text('Buy & Sell Anything'), findsOneWidget);

    // Splash schedules a 2.5s navigation timer; drain it before teardown.
    await tester.pump(const Duration(seconds: 3));
  });
}
