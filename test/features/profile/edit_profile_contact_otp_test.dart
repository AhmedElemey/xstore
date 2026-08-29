import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:xstore/core/animations/app_dialogs.dart';
import 'package:xstore/core/localization/app_localizations.dart';
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

  testWidgets(
    'contact prompt controller survives animated dialog pop',
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
                    result = await showAnimatedDialog<String>(
                      context: context,
                      child: EditProfileContactValueDialog(
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

      await tester.tap(find.text('Verify'));
      // showAnimatedDialog completes on pop; the Scale/Fade exit animation
      // still holds the TextField. Disposing the controller here used to throw.
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));

      expect(tester.takeException(), isNull);
      expect(result, 'old@x.com');
    },
  );
}
