import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:go_router/go_router.dart';
import 'package:xstore/core/localization/app_localizations.dart';
import 'package:xstore/core/router/app_routes.dart';
import 'package:xstore/features/auth/presentation/providers/auth_provider.dart';
import 'package:xstore/features/auth/presentation/screens/reset_password_screen.dart';
import 'package:xstore/shared/widgets/xstore_button.dart';

import '../../../helpers/stub_auth_repository.dart';

Widget _harness(StubAuthRepository repo) {
  final router = GoRouter(
    initialLocation: AppRoutes.resetPassword,
    routes: [
      GoRoute(
        path: AppRoutes.resetPassword,
        builder: (_, __) => const ResetPasswordScreen(
          args: ResetPasswordArgs(
            email: 'consumer@test.com',
            otpToken: '483921',
          ),
        ),
      ),
      GoRoute(
        path: AppRoutes.login,
        builder: (_, __) => const Scaffold(body: Text('login')),
      ),
    ],
  );
  return ProviderScope(
    overrides: [
      authRepositoryProvider.overrideWith((ref) => repo),
    ],
    child: MaterialApp.router(
      routerConfig: router,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
    ),
  );
}

void main() {
  testWidgets(
    'submits email, otpToken, newPassword, confirmNewPassword then goes to login',
    (tester) async {
      final repo = StubAuthRepository(
        verifyForgotPasswordOtpResult: const Right(unit),
      );
      await tester.pumpWidget(_harness(repo));
      await tester.pumpAndSettle();

      final fields = find.byType(TextField);
      await tester.enterText(fields.at(0), 'NewPass1!');
      await tester.enterText(fields.at(1), 'NewPass1!');
      await tester.tap(find.widgetWithText(XstoreButton, 'Reset Password'));
      await tester.pumpAndSettle();

      expect(repo.lastVerifyForgotEmail, 'consumer@test.com');
      expect(repo.lastVerifyForgotOtpToken, '483921');
      expect(repo.lastVerifyForgotNewPassword, 'NewPass1!');
      expect(repo.lastVerifyForgotConfirm, 'NewPass1!');
      expect(find.text('login'), findsOneWidget);
    },
  );
}
