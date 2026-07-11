import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:xstore/core/localization/app_localizations.dart';
import 'package:xstore/core/router/app_routes.dart';
import 'package:xstore/features/auth/domain/entities/user_entity.dart';
import 'package:xstore/features/auth/presentation/providers/auth_provider.dart';
import 'package:xstore/shared/utils/require_login.dart';

import 'helpers/fake_async_auth_notifier.dart';

UserEntity _consumer() => UserEntity(
      id: 'c1',
      name: 'Buyer',
      email: 'buyer@test.com',
      phoneNumber: '01011111111',
    );

Widget _harness({UserEntity? user, required void Function(bool) onResult}) {
  final router = GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => Scaffold(
          body: Consumer(
            builder: (context, ref, _) {
              // Warm up the lazy async auth provider so the tap-time read
              // sees AsyncData, matching the real app where the splash
              // screen awaits auth before any action is reachable.
              ref.watch(authProvider);
              return ElevatedButton(
                onPressed: () => onResult(requireLogin(context, ref)),
                child: const Text('act'),
              );
            },
          ),
        ),
      ),
      GoRoute(
        path: AppRoutes.login,
        builder: (context, state) =>
            const Scaffold(body: Text('login-screen-stub')),
      ),
    ],
  );
  return ProviderScope(
    overrides: [authProvider.overrideWith(() => FakeAuth(user))],
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
  testWidgets('signed-in user passes without any dialog', (tester) async {
    bool? result;
    await tester.pumpWidget(
      _harness(user: _consumer(), onResult: (r) => result = r),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('act'));
    await tester.pumpAndSettle();

    expect(result, isTrue);
    expect(find.byType(AlertDialog), findsNothing);
  });

  testWidgets('guest gets a dialog and can dismiss it', (tester) async {
    bool? result;
    await tester.pumpWidget(_harness(user: null, onResult: (r) => result = r));
    await tester.pumpAndSettle();

    await tester.tap(find.text('act'));
    await tester.pumpAndSettle();

    expect(result, isFalse);
    expect(find.byType(AlertDialog), findsOneWidget);
    expect(find.text('Sign in required'), findsOneWidget);

    await tester.tap(find.text('Not now'));
    await tester.pumpAndSettle();

    // Dismissed: dialog gone, no navigation happened.
    expect(find.byType(AlertDialog), findsNothing);
    expect(find.text('act'), findsOneWidget);
    expect(find.text('login-screen-stub'), findsNothing);
  });

  testWidgets('guest choosing Sign in closes the dialog and navigates',
      (tester) async {
    await tester.pumpWidget(_harness(user: null, onResult: (_) {}));
    await tester.pumpAndSettle();

    await tester.tap(find.text('act'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Sign in'));
    await tester.pumpAndSettle();

    expect(find.byType(AlertDialog), findsNothing);
    expect(find.text('login-screen-stub'), findsOneWidget);
  });
}
