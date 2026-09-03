// Drives the real, compiled app on a connected device/emulator through a
// vendor password login against the LIVE backend, then visits every vendor
// bottom-nav tab (Orders, My Listings, Add Listing, Wallet, Profile) to
// confirm each one renders real data without crashing. Matches
// create_listing_test.dart's pattern (real app.bootstrap, real UI taps,
// no MockConfig/scripted Dio at all) but stays read-only — it never
// submits a form — so it has no admin-approval-style backend wall to work
// around.
//
// Run with a device attached:
//
//   flutter test integration_test/login_flow_test.dart -d <deviceId>
//
// Uses the same seeded vendor account documented in the flutter-review
// skill's 2026-08-14 "Full order lifecycle live-probed" lesson. Swap the
// constants below if that seed account ever changes.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'package:xstore/core/config/app_flavor.dart';
import 'package:xstore/features/auth/presentation/widgets/auth_text_field.dart';
import 'package:xstore/features/auth/presentation/widgets/phone_input_field.dart';
import 'package:xstore/main.dart' as app;
import 'package:xstore/shared/widgets/xstore_button.dart';

const _vendorPhone = '01112345678';
const _vendorPassword = 'P@ssw0rd';

Future<void> _enterText(
  WidgetTester tester, {
  required Finder ancestor,
  required Type fieldType,
  required String text,
}) async {
  final field = find.descendant(of: ancestor, matching: find.byType(fieldType));
  await tester.enterText(field, text);
  await tester.pump();
}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets(
    'vendor logs in and every bottom-nav tab renders without crashing',
    (tester) async {
      await app.bootstrap(AppFlavor.dev);
      await tester.pumpAndSettle(const Duration(seconds: 5));

      // Fresh install / no persisted session -> log in. If a session was
      // already restored (re-running against a warm emulator), the tabs
      // below are already reachable.
      final loginButton = find.widgetWithText(XstoreButton, 'Login');
      if (loginButton.evaluate().isNotEmpty) {
        await _enterText(
          tester,
          ancestor: find.byType(PhoneInputField),
          fieldType: TextFormField,
          text: _vendorPhone,
        );
        await _enterText(
          tester,
          ancestor: find.byType(AuthTextField),
          fieldType: TextFormField,
          text: _vendorPassword,
        );
        await tester.tap(loginButton);
        await tester.pumpAndSettle(const Duration(seconds: 15));

        // First-cold-start location rationale popup, if it fires here.
        final notNow = find.text('Not Now');
        if (notNow.evaluate().isNotEmpty) {
          await tester.tap(notNow);
          await tester.pumpAndSettle();
        }
      }

      expect(
        tester.takeException(),
        isNull,
        reason: 'Login should land cleanly on the vendor shell.',
      );

      // Vendor bottom nav order: Orders, My Listings, Add Listing, Wallet,
      // Profile (app_router.dart's _vendorShellBranches, mirrored by
      // xstore_bottom_nav.dart's label list). Visit each and confirm it
      // renders real backend data without throwing.
      const vendorTabLabels = ['Orders', 'My Listings', 'Add Listing', 'Wallet', 'Profile'];
      for (final label in vendorTabLabels) {
        await tester.tap(find.text(label).last);
        await tester.pumpAndSettle(const Duration(seconds: 5));
        expect(
          tester.takeException(),
          isNull,
          reason: 'The "$label" tab should render live backend data without throwing.',
        );
      }
    },
  );
}
