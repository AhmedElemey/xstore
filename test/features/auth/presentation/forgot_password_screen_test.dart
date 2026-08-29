import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:go_router/go_router.dart';
import 'package:xstore/core/localization/app_localizations.dart';
import 'package:xstore/core/router/app_routes.dart';
import 'package:xstore/features/auth/presentation/providers/auth_provider.dart';
import 'package:xstore/features/auth/presentation/screens/forgot_password_screen.dart';

import '../../../helpers/stub_auth_repository.dart';

Widget _harness(StubAuthRepository repo) {
  final router = GoRouter(
    initialLocation: AppRoutes.forgotPassword,
    routes: [
      GoRoute(
        path: AppRoutes.forgotPassword,
        builder: (_, __) => const ForgotPasswordScreen(),
      ),
      GoRoute(
        path: AppRoutes.forgotPasswordOtp,
        builder: (_, __) => const Scaffold(body: Text('forgot-otp')),
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

Future<void> _submitEmail(WidgetTester tester) async {
  await tester.enterText(find.byType(TextField), 'jane@test.com');
  await tester.tap(find.text('Send Reset Code'));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('does not show a debug OTP snackbar when the API omits otp',
      (tester) async {
    await tester.pumpWidget(
      _harness(StubAuthRepository(forgotPasswordResult: const Right(null))),
    );
    await tester.pumpAndSettle();
    await _submitEmail(tester);

    expect(find.textContaining('Debug OTP'), findsNothing);
    expect(find.text('forgot-otp'), findsOneWidget);
  });

  testWidgets('shows a debug OTP snackbar only when the API returned otp',
      (tester) async {
    await tester.pumpWidget(
      _harness(StubAuthRepository(forgotPasswordResult: const Right('654321'))),
    );
    await tester.pumpAndSettle();
    await _submitEmail(tester);

    expect(find.textContaining('Debug OTP: 654321'), findsOneWidget);
  });
}
