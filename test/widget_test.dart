import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:xstore/app.dart';

void main() {
  testWidgets('App shows login', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: XstoreApp(),
      ),
    );
    // Auth restore + router: avoid pumpAndSettle (indeterminate progress).
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.text('Sign in'), findsOneWidget);
  });
}
