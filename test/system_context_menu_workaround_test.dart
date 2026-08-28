import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets(
    'readOnly field long-press does not throw when system context menu is off',
    (tester) async {
      debugDefaultTargetPlatformOverride = TargetPlatform.iOS;

      final controller = TextEditingController(text: 'copy me');
      addTearDown(controller.dispose);

      try {
        await tester.pumpWidget(
          MediaQuery(
            // Device reports iOS 16+ system menu support, same as a real phone.
            data: const MediaQueryData(
              size: Size(390, 844),
              supportsShowingSystemContextMenu: true,
            ),
            child: MaterialApp(
              builder: (context, child) {
                return MediaQuery(
                  data: MediaQuery.of(context).copyWith(
                    supportsShowingSystemContextMenu: false,
                  ),
                  child: child!,
                );
              },
              home: Scaffold(
                body: TextField(controller: controller, readOnly: true),
              ),
            ),
          ),
        );

        expect(
          MediaQuery.supportsShowingSystemContextMenu(
            tester.element(find.byType(TextField)),
          ),
          isFalse,
        );

        await tester.longPress(find.byType(TextField));
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
      } finally {
        debugDefaultTargetPlatformOverride = null;
      }
    },
  );
}
