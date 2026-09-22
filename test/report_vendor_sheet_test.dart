import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:xstore/core/localization/app_localizations.dart';
import 'package:xstore/features/orders/presentation/widgets/report_vendor_sheet.dart';
import 'package:xstore/features/reports/domain/entities/vendor_report_reason.dart';

Future<bool?> _openSheet(
  WidgetTester tester, {
  required Future<bool> Function(VendorReportReason reason, String? comment)
  onSubmit,
}) async {
  bool? result;
  await tester.pumpWidget(
    MaterialApp(
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      home: Builder(
        builder: (context) => Scaffold(
          body: Center(
            child: ElevatedButton(
              onPressed: () async {
                result = await showModalBottomSheet<bool>(
                  context: context,
                  isScrollControlled: true,
                  builder: (_) => ReportVendorSheet(
                    vendorName: 'Cairo Gadgets',
                    onSubmit: onSubmit,
                  ),
                );
              },
              child: const Text('open'),
            ),
          ),
        ),
      ),
    ),
  );
  await tester.tap(find.text('open'));
  await tester.pumpAndSettle();
  return result;
}

void main() {
  testWidgets('submit is disabled until a reason is picked', (tester) async {
    await _openSheet(tester, onSubmit: (_, __) async => true);

    final submitButton = tester.widget<FilledButton>(
      find.widgetWithText(FilledButton, 'Submit Report'),
    );
    expect(submitButton.onPressed, isNull);

    await tester.tap(find.text('Fraud or scam'));
    await tester.pump();

    final enabled = tester.widget<FilledButton>(
      find.widgetWithText(FilledButton, 'Submit Report'),
    );
    expect(enabled.onPressed, isNotNull);
  });

  testWidgets('Other reason requires a comment before submit enables', (
    tester,
  ) async {
    await _openSheet(tester, onSubmit: (_, __) async => true);

    await tester.tap(find.text('Other'));
    await tester.pump();

    var button = tester.widget<FilledButton>(
      find.widgetWithText(FilledButton, 'Submit Report'),
    );
    expect(button.onPressed, isNull);

    await tester.enterText(find.byType(TextField), 'Vendor never shipped');
    await tester.pump();

    button = tester.widget<FilledButton>(
      find.widgetWithText(FilledButton, 'Submit Report'),
    );
    expect(button.onPressed, isNotNull);
  });

  testWidgets('submitting calls onSubmit with the picked reason and comment', (
    tester,
  ) async {
    VendorReportReason? capturedReason;
    String? capturedComment;

    await _openSheet(
      tester,
      onSubmit: (reason, comment) async {
        capturedReason = reason;
        capturedComment = comment;
        return true;
      },
    );

    await tester.tap(find.text('Poor product quality'));
    await tester.pump();
    await tester.enterText(find.byType(TextField), 'Item arrived broken');
    await tester.pump();
    await tester.ensureVisible(
      find.widgetWithText(FilledButton, 'Submit Report'),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, 'Submit Report'));
    await tester.pumpAndSettle();

    expect(capturedReason, VendorReportReason.poorProductQuality);
    expect(capturedComment, 'Item arrived broken');
  });

  testWidgets('a failed submit stays open with an inline error', (
    tester,
  ) async {
    await _openSheet(tester, onSubmit: (_, __) async => false);

    await tester.tap(find.text('Harassment or abuse'));
    await tester.pump();
    await tester.ensureVisible(
      find.widgetWithText(FilledButton, 'Submit Report'),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, 'Submit Report'));
    await tester.pumpAndSettle();

    // The sheet is still on screen (didn't pop) with its error visible.
    expect(find.byType(ReportVendorSheet), findsOneWidget);
    expect(find.text('Something went wrong'), findsOneWidget);
  });
}
