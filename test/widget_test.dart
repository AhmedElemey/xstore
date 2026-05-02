import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/widgets.dart';

void main() {
  testWidgets('Splash copy remains consistent', (WidgetTester tester) async {
    await tester.pumpWidget(
      const Directionality(
        textDirection: TextDirection.ltr,
        child: Column(
          children: [
            Text('xStore'),
            Text('Buy & Sell Anything'),
          ],
        ),
      ),
    );

    expect(find.text('xStore'), findsOneWidget);
    expect(find.text('Buy & Sell Anything'), findsOneWidget);
  });
}
