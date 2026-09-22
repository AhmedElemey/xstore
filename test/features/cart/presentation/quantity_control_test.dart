import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:xstore/features/cart/presentation/widgets/quantity_control.dart';

Widget _nestedInCard({
  required int quantity,
  required int maxQuantity,
  required VoidCallback onParentTap,
  required VoidCallback onIncrement,
}) {
  return MaterialApp(
    home: Scaffold(
      body: Center(
        child: InkWell(
          onTap: onParentTap,
          child: QuantityControl(
            quantity: quantity,
            maxQuantity: maxQuantity,
            enabled: true,
            onDecrement: () {},
            onIncrement: onIncrement,
            onEditQuantity: () {},
          ),
        ),
      ),
    ),
  );
}

void main() {
  testWidgets(
    'tapping + at max does not increment or open the parent card',
    (tester) async {
      var parentTaps = 0;
      var increments = 0;

      await tester.pumpWidget(
        _nestedInCard(
          quantity: 4,
          maxQuantity: 4,
          onParentTap: () => parentTaps++,
          onIncrement: () => increments++,
        ),
      );

      await tester.tap(find.byIcon(LucideIcons.plus));
      await tester.pump();

      expect(increments, 0);
      expect(parentTaps, 0);
    },
  );

  testWidgets(
    'tapping + below max increments without opening the parent card',
    (tester) async {
      var parentTaps = 0;
      var increments = 0;

      await tester.pumpWidget(
        _nestedInCard(
          quantity: 2,
          maxQuantity: 4,
          onParentTap: () => parentTaps++,
          onIncrement: () => increments++,
        ),
      );

      await tester.tap(find.byIcon(LucideIcons.plus));
      await tester.pump();

      expect(increments, 1);
      expect(parentTaps, 0);
    },
  );
}
