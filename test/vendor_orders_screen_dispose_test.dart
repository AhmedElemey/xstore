import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';

import 'package:xstore/core/localization/app_localizations.dart';
import 'package:xstore/core/mock/mock_users.dart';
import 'package:xstore/features/auth/presentation/providers/auth_provider.dart';
import 'package:xstore/features/orders/presentation/providers/orders_dependencies.dart';
import 'package:xstore/features/orders/presentation/screens/vendor_orders_screen.dart';

import 'helpers/fake_async_auth_notifier.dart';
import 'helpers/stub_orders_repository.dart';

void main() {
  testWidgets(
    'unmounting with no pending badge does not create a ticker in dispose',
    (tester) async {
      tester.view.physicalSize = const Size(800, 2000);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            authProvider.overrideWith(() => FakeAuth(mockVendorUser)),
            ordersRepositoryProvider.overrideWithValue(
              StubOrdersRepository(
                getVendorOrdersResult: ({
                  required vendorId,
                  required page,
                  required pageSize,
                }) =>
                    const Right([]),
              ),
            ),
          ],
          child: const MaterialApp(
            localizationsDelegates: [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: AppLocalizations.supportedLocales,
            home: VendorOrdersScreen(),
          ),
        ),
      );

      expect(find.byType(VendorOrdersScreen), findsOneWidget);

      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pump();
    },
  );
}
