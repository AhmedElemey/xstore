import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:xstore/core/localization/app_localizations.dart';
import 'package:xstore/core/mock/mock_users.dart';
import 'package:xstore/features/auth/presentation/providers/auth_provider.dart';
import 'package:xstore/features/delivery/domain/entities/delivery_request.dart';
import 'package:xstore/features/delivery/presentation/providers/delivery_request_dependencies.dart';
import 'package:xstore/features/delivery/presentation/screens/my_package_requests_screen.dart';

import 'helpers/fake_async_auth_notifier.dart';
import 'helpers/stub_delivery_request_repository.dart';

Widget _app(List<Override> overrides) => ProviderScope(
      overrides: overrides,
      child: MaterialApp(
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: AppLocalizations.supportedLocales,
        // Splash gates on auth in the real app; mirror that so the screen's
        // initState fetch reads authProvider as AsyncData, not Loading.
        home: Consumer(
          builder: (context, ref, _) {
            final user = ref.watch(authProvider).valueOrNull;
            if (user == null) return const SizedBox.shrink();
            return const MyPackageRequestsScreen();
          },
        ),
      ),
    );

List<Override> _overrides(List<DeliveryRequestEntity> requests) => [
      authProvider.overrideWith(() => FakeAuth(mockConsumerUser)),
      deliveryRequestRepositoryProvider.overrideWithValue(
        StubDeliveryRequestRepository(myRequests: requests),
      ),
    ];

void main() {
  testWidgets('submitted request shows the waiting-for-pricing state',
      (tester) async {
    await tester.pumpWidget(_app(_overrides([
      testPackageRequest(
        id: 'pkg_waiting',
        status: DeliveryRequestStatus.submitted,
      ),
    ])));
    await tester.pumpAndSettle();

    expect(
      find.text('Waiting for xStore to price this delivery'),
      findsOneWidget,
    );
    expect(find.text('Confirm — pay at pickup'), findsNothing);
  });

  testWidgets(
      'priced request shows the price and confirming moves it to confirmed',
      (tester) async {
    await tester.pumpWidget(_app(_overrides([
      testPackageRequest(
        id: 'pkg_priced',
        status: DeliveryRequestStatus.priced,
        price: 80,
      ),
    ])));
    await tester.pumpAndSettle();

    // The admin's price is shown with the cash-at-pickup framing.
    expect(find.textContaining('80'), findsWidgets);
    expect(
      find.textContaining('cash when the courier picks up'),
      findsWidgets,
    );

    final confirm = find.text('Confirm — pay at pickup');
    expect(confirm, findsOneWidget);

    // Confirm goes through a dialog that restates the cash amount.
    await tester.tap(confirm);
    await tester.pumpAndSettle();
    expect(find.text('Place delivery order'), findsOneWidget);
    await tester.tap(find.text('Confirm — pay at pickup').last);
    await tester.pumpAndSettle();

    // Optimistic + stub result: the request is now confirmed, courier en route.
    expect(
      find.text('Courier on the way to pick up your package'),
      findsOneWidget,
    );
    expect(find.text('Confirm — pay at pickup'), findsNothing);
  });
}
