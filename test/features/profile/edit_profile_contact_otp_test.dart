import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:xstore/core/animations/app_dialogs.dart';
import 'package:xstore/core/localization/app_localizations.dart';
import 'package:xstore/core/localization/app_localizations_en.dart';
import 'package:xstore/core/utils/validators.dart';
import 'package:xstore/features/profile/presentation/screens/edit_profile_screen.dart';

void main() {
  group('editProfileContactNeedsOtp', () {
    test('unchanged value does not need OTP', () {
      expect(
        editProfileContactNeedsOtp(typed: 'a@x.com', stored: 'a@x.com'),
        isFalse,
      );
    });

    test('trim and case match count as unchanged for email', () {
      expect(
        editProfileContactNeedsOtp(
          typed: ' A@X.COM ',
          stored: 'a@x.com',
          ignoreCase: true,
        ),
        isFalse,
      );
    });

    test('a different value needs OTP', () {
      expect(
        editProfileContactNeedsOtp(
          typed: 'b@x.com',
          stored: 'a@x.com',
          ignoreCase: true,
        ),
        isTrue,
      );
    });

    test('session-verified new value does not need OTP again', () {
      expect(
        editProfileContactNeedsOtp(
          typed: 'b@x.com',
          stored: 'a@x.com',
          sessionVerified: 'b@x.com',
          ignoreCase: true,
        ),
        isFalse,
      );
    });

    test('empty typed value does not need OTP', () {
      expect(
        editProfileContactNeedsOtp(typed: '  ', stored: 'a@x.com'),
        isFalse,
      );
    });

    test('session verified of a different value still needs OTP', () {
      expect(
        editProfileContactNeedsOtp(
          typed: 'c@x.com',
          stored: 'a@x.com',
          sessionVerified: 'b@x.com',
          ignoreCase: true,
        ),
        isTrue,
      );
    });
  });

  final l10n = AppLocalizationsEn();

  Future<void> _openContactSheet(
    WidgetTester tester, {
    required String title,
    required String initialText,
    required String Function(String raw) normalize,
    required String? Function(String value) validate,
  }) async {
    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('en'),
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: AppLocalizations.supportedLocales,
        home: Builder(
          builder: (context) {
            return Scaffold(
              body: TextButton(
                onPressed: () async {
                  await showAnimatedBottomSheet<String>(
                    context: context,
                    builder: (_) => EditProfileContactValueSheet(
                      title: title,
                      initialText: initialText,
                      fieldBuilder: (ctx, c) => TextField(controller: c),
                      normalize: normalize,
                      validate: validate,
                    ),
                  );
                },
                child: const Text('open'),
              ),
            );
          },
        ),
      ),
    );

    await tester.tap(find.text('open'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
  }

  FilledButton _verifyButton(WidgetTester tester) {
    return tester.widget<FilledButton>(
      find.widgetWithText(FilledButton, 'Verify'),
    );
  }

  testWidgets(
    'email Verify stays dimmed until the address changes and matches the regex',
    (tester) async {
      await _openContactSheet(
        tester,
        title: 'Email',
        initialText: 'old@x.com',
        normalize: (raw) => raw.trim(),
        validate: (value) => Validators.registerEmail(l10n, value),
      );

      expect(_verifyButton(tester).onPressed, isNull);

      await tester.enterText(find.byType(TextField), 'not-an-email');
      await tester.pump();
      expect(_verifyButton(tester).onPressed, isNull);

      await tester.enterText(find.byType(TextField), 'new@x.com');
      await tester.pump();
      expect(_verifyButton(tester).onPressed, isNotNull);

      await tester.enterText(find.byType(TextField), ' old@x.com ');
      await tester.pump();
      expect(_verifyButton(tester).onPressed, isNull);
    },
  );

  testWidgets(
    'phone Verify stays dimmed until the number changes and matches Egypt regex',
    (tester) async {
      await _openContactSheet(
        tester,
        title: 'Phone',
        initialText: '01012345678',
        normalize: AppValidators.normalizeEgyptLocal,
        validate: (value) => Validators.egyptPhone(l10n, value),
      );

      expect(_verifyButton(tester).onPressed, isNull);

      await tester.enterText(find.byType(TextField), '010');
      await tester.pump();
      expect(_verifyButton(tester).onPressed, isNull);

      await tester.enterText(find.byType(TextField), '01712345678');
      await tester.pump();
      expect(_verifyButton(tester).onPressed, isNull);

      await tester.enterText(find.byType(TextField), '01112345678');
      await tester.pump();
      expect(_verifyButton(tester).onPressed, isNotNull);

      await tester.enterText(find.byType(TextField), '01012345678');
      await tester.pump();
      expect(_verifyButton(tester).onPressed, isNull);
    },
  );

  testWidgets(
    'contact prompt controller survives animated bottom sheet pop',
    (tester) async {
      String? result;
      await tester.pumpWidget(
        MaterialApp(
          locale: const Locale('en'),
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: AppLocalizations.supportedLocales,
          home: Builder(
            builder: (context) {
              return Scaffold(
                body: TextButton(
                  onPressed: () async {
                    result = await showAnimatedBottomSheet<String>(
                      context: context,
                      builder: (_) => EditProfileContactValueSheet(
                        title: 'Email',
                        initialText: 'old@x.com',
                        fieldBuilder: (ctx, c) => TextField(controller: c),
                        normalize: (raw) => raw.trim(),
                        validate: (_) => null,
                      ),
                    );
                  },
                  child: const Text('open'),
                ),
              );
            },
          ),
        ),
      );

      await tester.tap(find.text('open'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));

      expect(find.byType(TextField), findsOneWidget);
      expect(find.byType(AlertDialog), findsNothing);

      await tester.enterText(find.byType(TextField), 'new@x.com');
      await tester.pump();
      await tester.tap(find.text('Verify'));
      // showAnimatedBottomSheet completes on pop; the slide/fade exit
      // animation still holds the TextField. Disposing the controller here
      // used to throw.
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));

      expect(tester.takeException(), isNull);
      expect(result, 'new@x.com');
    },
  );
}
