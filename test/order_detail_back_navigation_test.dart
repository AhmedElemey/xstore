import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import 'package:xstore/core/localization/app_localizations.dart';
import 'package:xstore/core/router/app_routes.dart';
import 'package:xstore/features/auth/domain/entities/user_entity.dart';
import 'package:xstore/features/auth/presentation/providers/auth_provider.dart';
import 'package:xstore/features/orders/presentation/screens/order_detail_screen.dart';

/// Auth that never resolves, so [OrderDetailScreen]'s fetch bails out and
/// the back control is still on the empty/error app bar — enough to cover
/// the post-checkout `go('/order/:id')` stack (nothing to pop).
class _PendingAuth extends Auth {
  @override
  Future<UserEntity?> build() => Completer<UserEntity?>().future;
}

void main() {
  testWidgets(
    'back on a root order-detail go() lands on Orders',
    (tester) async {
      final router = GoRouter(
        initialLocation: AppRoutes.orderPath('501'),
        routes: [
          GoRoute(
            path: AppRoutes.orders,
            builder: (_, __) => const Text('orders-tab'),
          ),
          GoRoute(
            path: '${AppRoutes.orderDetail}/:orderId',
            builder: (_, state) => OrderDetailScreen(
              orderId: state.pathParameters['orderId'] ?? '',
            ),
          ),
        ],
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            authProvider.overrideWith(_PendingAuth.new),
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
        ),
      );
      await tester.pump();

      expect(find.byType(BackButton), findsOneWidget);
      await tester.tap(find.byType(BackButton));
      await tester.pump();
      await tester.pump();

      expect(find.text('orders-tab'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );
}
