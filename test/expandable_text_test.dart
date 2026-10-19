// "Read more" showed under short review/description text that never
// overflowed. ExpandableText must show its toggle only when the text exceeds
// maxLines at the laid-out width.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:xstore/shared/widgets/expandable_text.dart';

Widget _host(String text) => MaterialApp(
      home: Scaffold(
        body: SizedBox(
          width: 300,
          child: ExpandableText(
            text: text,
            maxLines: 2,
            expanded: false,
            toggle: const Text('toggle'),
          ),
        ),
      ),
    );

void main() {
  testWidgets('hides the toggle for text that fits', (tester) async {
    await tester.pumpWidget(_host('good'));
    expect(find.text('toggle'), findsNothing);
  });

  testWidgets('shows the toggle for text that overflows maxLines',
      (tester) async {
    await tester.pumpWidget(_host(List.filled(80, 'word').join(' ')));
    expect(find.text('toggle'), findsOneWidget);
  });
}
