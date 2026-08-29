import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:go_router/go_router.dart';
import 'package:xstore/core/localization/app_localizations.dart';
import 'package:xstore/core/router/app_routes.dart';
import 'package:xstore/features/auth/presentation/providers/auth_provider.dart';
import 'package:xstore/features/auth/presentation/screens/forgot_password_otp_screen.dart';
import 'package:xstore/features/auth/presentation/screens/reset_password_screen.dart';

import '../../../helpers/stub_auth_repository.dart';

Widget _otpHarness(StubAuthRepository repo) {
  final router = GoRouter(
    initialLocation: AppRoutes.forgotPasswordOtp,
    routes: [
      GoRoute(
        path: AppRoutes.forgotPasswordOtp,
        builder: (_, __) =>
            const ForgotPasswordOtpScreen(email: 'jane@test.com'),
      ),
      GoRoute(
        path: AppRoutes.resetPassword,
        builder: (_, state) {
          final args = state.extra as ResetPasswordArgs;
          return Scaffold(
            body: Text('reset:${args.email}:${args.otpToken}'),
          );
        },
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
  testWidgets('completing a 6-digit OTP opens the new-password screen',
      (tester) async {
    await tester.pumpWidget(
      _otpHarness(StubAuthRepository(forgotPasswordResult: const Right(null))),
    );
    // OtpResendCooldown's periodic timer never lets pumpAndSettle complete.
    await tester.pump();

    expect(find.textContaining('jane@test.com'), findsOneWidget);

    await tester.enterText(find.byType(EditableText), '483921');
    await tester.pump();
    await tester.pump();

    expect(find.text('reset:jane@test.com:483921'), findsOneWidget);
  });
}
