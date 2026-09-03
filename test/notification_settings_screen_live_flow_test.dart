// Screen-level test of the real NotificationSettingsScreen — real
// SharedPreferences reads/writes and real role-conditional sections, not
// fixture data. Unlike every other screen this session, it makes no
// network call at all (no MockConfig, no Dio, no AuthRepository — its own
// TODO(phase-2) comment says preferences don't sync to the backend yet),
// so there is nothing to script here. The screen is also currently
// unreachable in the app (its entry point is commented out in
// app_router.dart), but the widget itself is real, shipped code and worth
// covering on its own: it reads `authProvider` only for the
// consumer/vendor section split, so a `_FakeAuth` override is enough.
//
// Run with: flutter test test/notification_settings_screen_live_flow_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:xstore/core/localization/app_localizations.dart';
import 'package:xstore/features/auth/domain/entities/user_entity.dart';
import 'package:xstore/features/auth/presentation/providers/auth_provider.dart';
import 'package:xstore/features/notifications/presentation/screens/notification_settings_screen.dart';

class _FakeAuth extends Auth {
  _FakeAuth(this._user);
  final UserEntity? _user;
  @override
  Future<UserEntity?> build() async => _user;
}

UserEntity _consumer() => const UserEntity(
  id: 'consumer_1',
  name: 'Test Buyer',
  email: 'buyer@test.com',
  phoneNumber: '01012345678',
  role: UserRole.consumer,
  isVerified: true,
);

UserEntity _vendor() => const UserEntity(
  id: 'vendor_1',
  name: 'Test Vendor',
  email: 'vendor@test.com',
  phoneNumber: '01012345678',
  role: UserRole.vendor,
  isVerified: true,
);

Widget _harness(UserEntity user) {
  return ProviderScope(
    overrides: [
      authProvider.overrideWith(() => _FakeAuth(user)),
    ],
    child: MaterialApp(
      home: const NotificationSettingsScreen(),
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

Future<void> _settle(
  WidgetTester tester, {
  int times = 15,
  Duration step = const Duration(milliseconds: 100),
}) async {
  for (var i = 0; i < times; i++) {
    await tester.pump(step);
  }
}

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets(
    'a consumer sees order/deal preferences with sane real defaults, not the vendor store section',
    (tester) async {
      await tester.pumpWidget(_harness(_consumer()));
      await _settle(tester);

      expect(find.text('Order updates'), findsOneWidget);
      expect(find.text('Deals & offers'), findsOneWidget);
      expect(find.text('Store updates'), findsNothing);

      final orderConfirmedSwitch = tester.widget<Switch>(
        find.descendant(
          of: find.widgetWithText(ListTile, 'Order confirmed'),
          matching: find.byType(Switch),
        ),
      );
      // Defaults set in `_load()`: order-confirmed on, back-in-stock off.
      expect(orderConfirmedSwitch.value, isTrue);

      final backInStockSwitch = tester.widget<Switch>(
        find.descendant(
          of: find.widgetWithText(ListTile, 'Back in stock'),
          matching: find.byType(Switch),
        ),
      );
      expect(backInStockSwitch.value, isFalse);
    },
  );

  testWidgets(
    'a vendor sees the store section, not the consumer order/deal sections',
    (tester) async {
      await tester.pumpWidget(_harness(_vendor()));
      await _settle(tester);

      expect(find.text('Store updates'), findsOneWidget);
      expect(find.text('Order updates'), findsNothing);
      expect(find.text('Deals & offers'), findsNothing);
    },
  );

  testWidgets(
    'toggling a switch and tapping Save persists the real value to SharedPreferences',
    (tester) async {
      await tester.pumpWidget(_harness(_consumer()));
      await _settle(tester);

      // The `ListTile` itself has no `onTap` — only its trailing `Switch`
      // is wired to `onChanged`, so the tap must land on the switch.
      await tester.tap(
        find.descendant(
          of: find.widgetWithText(ListTile, 'Flash sales'),
          matching: find.byType(Switch),
        ),
      );
      await tester.pump();

      await tester.scrollUntilVisible(
        find.text('Save Preferences'),
        300,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.tap(find.text('Save Preferences'));
      await _settle(tester);

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getBool('notif_flash_sales'), isFalse);
      expect(find.text('Preferences saved'), findsOneWidget);
    },
  );
}
