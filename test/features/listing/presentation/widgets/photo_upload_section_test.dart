// Regression test for: the Add Listing form's "Product Photos" section had
// no asterisk even though at least one photo is required to publish
// (Validators.listingFormErrors sets 'photos' => listingValidationPhotosRequired
// when none are picked), unlike every other required field on the same
// screen ("Product name *", "Price *", etc.).
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:xstore/core/localization/app_localizations.dart';
import 'package:xstore/features/listing/presentation/widgets/photo_upload_section.dart';

void main() {
  Future<void> pump(WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: PhotoUploadSection(
            paths: const [],
            errorText: null,
            onOpenPicker: () {},
            onRemove: (_) {},
            onReorder: (_, __) {},
            existingUrls: const ['https://example.test/photo.jpg'],
          ),
        ),
      ),
    );
    await tester.pump();
  }

  testWidgets(
    'the section header marks Product Photos as required, matching the '
    'other required fields on this form',
    (tester) async {
      await pump(tester);

      expect(find.text('Product Photos *'), findsOneWidget);
      expect(find.text('Product Photos'), findsNothing);
    },
  );

  testWidgets(
    "the asterisk doesn't leak into the existing-photo's accessibility label",
    (tester) async {
      await pump(tester);

      expect(
        find.byWidgetPredicate(
          (w) => w is Semantics && w.properties.label == 'Product Photos',
        ),
        findsOneWidget,
      );
      expect(
        find.byWidgetPredicate(
          (w) => w is Semantics && w.properties.label == 'Product Photos *',
        ),
        findsNothing,
      );
    },
  );
}
