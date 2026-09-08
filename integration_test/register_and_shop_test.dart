// Drives the real, compiled app on a connected device/emulator through a
// brand-new consumer registration against the LIVE backend, then browsing
// -> product detail -> add-to-cart, confirming the cart badge updates.
// Matches create_listing_test.dart's pattern (real app.bootstrap, real UI
// taps, no MockConfig/scripted Dio at all).
//
// Run with a device attached:
//
//   flutter test integration_test/register_and_shop_test.dart -d <deviceId>
//
// Deliberately stops at "added to cart" rather than driving checkout to a
// placed order. Per the flutter-review skill's 2026-08-14 "Full order
// lifecycle live-probed" lesson, a real order on this backend requires:
// (1) email verification, which currently 500s on the live backend with an
// SMTP auth error (a known, currently-unfixed backend defect — not
// something this test can work around), and (2) an admin-approved listing,
// with no self-service or automated path to approval. Attempting checkout
// here would therefore fail for reasons outside this app's control, not
// because of an app bug — extend this test past add-to-cart only once
// either of those backend-side blockers is lifted.
//
// registerConsumer() has no MockConfig branch (confirmed via grep,
// documented in register_screen_live_flow_test.dart) — always-live.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:lucide_icons/lucide_icons.dart';

import 'package:xstore/core/config/app_flavor.dart';
import 'package:xstore/features/auth/presentation/providers/auth_provider.dart';
import 'package:xstore/features/auth/presentation/screens/register_screen.dart';
import 'package:xstore/features/cities/presentation/providers/city_dependencies.dart';
import 'package:xstore/features/explore/presentation/widgets/product_grid_card.dart';
import 'package:xstore/features/explore/presentation/widgets/product_list_card.dart';
import 'package:xstore/features/governments/presentation/providers/government_dependencies.dart';
import 'package:xstore/main.dart' as app;
import 'package:xstore/shared/widgets/notification_icon_badge.dart';
import 'package:xstore/shared/widgets/xstore_button.dart';

/// Unique per run so re-running this test never collides with a
/// previously-registered phone/email on the live backend.
String _uniquePhone() {
  final suffix = (DateTime.now().millisecondsSinceEpoch % 100000000)
      .toString()
      .padLeft(8, '0');
  return '010$suffix';
}

String _uniqueEmail() => 'itest_${DateTime.now().millisecondsSinceEpoch}@example.com';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets(
    'a new consumer registers, browses, and adds a real product to cart',
    (tester) async {
      await app.bootstrap(AppFlavor.dev);
      await tester.pumpAndSettle(const Duration(seconds: 5));

      // Fresh install lands on Login; "Create Account" opens the register
      // wizard. If a session was already restored (warm emulator), this
      // whole registration step is skipped and the test just shops.
      final createAccount = find.text('Create Account');
      if (createAccount.evaluate().isNotEmpty) {
        await tester.tap(createAccount);
        await tester.pumpAndSettle();

        // Step 1: role.
        await tester.tap(find.text("I'm a Buyer"));
        await tester.pump();
        await tester.tap(find.widgetWithText(XstoreButton, 'Continue'));
        await tester.pumpAndSettle();

        // Step 2: personal info. The location cascade needs a real
        // government/city id from the live catalog — read them straight off
        // the running app's own providers (same trick create_listing_test
        // .dart uses for the photo path) rather than driving the picker
        // sheets, which are tangential to what this test verifies.
        final container = ProviderScope.containerOf(
          tester.element(find.byType(RegisterScreen)),
          listen: false,
        );
        final governments = await container.read(allGovernmentsProvider.future);
        final cities = await container.read(allCitiesProvider.future);
        final government = governments.first;
        final city = cities.firstWhere(
          (c) => c.governorateId == government.id,
          orElse: () => cities.first,
        );

        final fields = find.byType(TextFormField);
        await tester.enterText(fields.at(0), 'Integration Test Buyer');
        await tester.enterText(fields.at(1), _uniqueEmail());
        await tester.enterText(fields.at(2), _uniquePhone());
        container.read(registerNotifierProvider.notifier).updateStoreLocation(
              storeCityId: city.id,
              storeGovernmentId: government.id,
            );
        await tester.pump();
        await tester.tap(find.widgetWithText(XstoreButton, 'Continue'));
        await tester.pumpAndSettle();

        // Step 3: security.
        final securityFields = find.byType(TextFormField);
        await tester.enterText(securityFields.at(0), 'Password123!');
        await tester.enterText(securityFields.at(1), 'Password123!');
        await tester.pump();
        await tester.scrollUntilVisible(
          find.byType(Checkbox),
          200,
          scrollable: find.byType(Scrollable).first,
        );
        await tester.tap(find.byType(Checkbox));
        await tester.pump();
        await tester.tap(find.widgetWithText(XstoreButton, 'Continue'));
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
        reason: 'Registration should land cleanly on the consumer shell.',
      );

      // Home -> Explore, since Home's own featured rows aren't guaranteed
      // to have loaded content the moment the shell mounts.
      await tester.tap(find.text('Explore').last);
      await tester.pumpAndSettle(const Duration(seconds: 5));

      // The catalog renders either grid or list cards depending on the
      // user's last-chosen view mode — check both.
      var productCard = find.byType(ProductGridCard);
      if (productCard.evaluate().isEmpty) {
        productCard = find.byType(ProductListCard);
      }
      expect(
        productCard,
        findsWidgets,
        reason: 'Expected at least one real product from the live catalog.',
      );

      await tester.tap(productCard.first);
      await tester.pumpAndSettle(const Duration(seconds: 5));

      expect(
        tester.takeException(),
        isNull,
        reason: 'Product detail should render real backend data without throwing.',
      );

      await tester.tap(find.text('Add to Cart'));
      await tester.pumpAndSettle();

      expect(find.text('Added to cart!'), findsOneWidget);

      // Back to Home and confirm the cart badge now shows at least one item.
      await tester.pageBack();
      await tester.pumpAndSettle();
      await tester.tap(find.text('Home').last);
      await tester.pumpAndSettle();

      final cartBadge = tester.widget<NotificationIconBadge>(
        find.ancestor(
          of: find.byIcon(LucideIcons.shoppingCart),
          matching: find.byType(NotificationIconBadge),
        ),
      );
      expect(
        cartBadge.count,
        greaterThan(0),
        reason: 'Expected the cart badge count to reflect the added product.',
      );
    },
  );
}
