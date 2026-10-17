import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:xstore/core/localization/app_localizations.dart';
import 'package:xstore/core/network/app_error_messages.dart';

void main() {
  Future<String> resolve(WidgetTester tester, Locale locale, String code) async {
    late String out;
    await tester.pumpWidget(
      MaterialApp(
        locale: locale,
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: AppLocalizations.supportedLocales,
        home: Builder(builder: (context) {
          out = resolveAppError(context, code);
          return const SizedBox();
        }),
      ),
    );
    return out;
  }

  testWidgets('social sign-in error codes resolve to localized text',
      (tester) async {
    expect(
      await resolve(tester, const Locale('en'), googleSignInFailedErrorCode),
      'Google sign-in failed. Please try again.',
    );
    final ar = await resolve(tester, const Locale('ar'), googleSignInFailedErrorCode);
    expect(ar, isNot(googleSignInFailedErrorCode));
    expect(ar, contains('جوجل'));
    expect(
      await resolve(tester, const Locale('en'), socialAccountDisabledErrorCode),
      'This account has been disabled. Contact support.',
    );
    expect(
      await resolve(tester, const Locale('en'), socialAccountExistsErrorCode),
      startsWith('An account with this email already exists'),
    );
  });
}
