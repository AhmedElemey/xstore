// Drives the real, compiled app on a connected device/emulator through:
// login -> Add Listing tab -> fill the form -> publish -> land on My
// Listings. Run with a device attached:
//
//   flutter test integration_test/create_listing_test.dart -d <deviceId>
//
// Listing creation is NOT gated behind MockConfig.useMock (no mock branch
// exists in ListingRemoteDataSource.createListing — see the flutter-review
// skill's 2026-08-02 Postman-contract lesson), so this test always calls
// the LIVE backend regardless of --dart-define=MOCK. It therefore needs a
// vendor account that already satisfies the backend's create-listing
// preconditions (phone verified + store lat/lng set) — the seeded test
// vendor documented in the flutter-review skill's 2026-08-14 "Full order
// lifecycle live-probed" lesson satisfies both. Swap the constants below
// for a different vendor if that seed account ever changes.
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:lucide_icons/lucide_icons.dart';

import 'package:xstore/core/config/app_flavor.dart';
import 'package:xstore/features/auth/presentation/widgets/auth_text_field.dart';
import 'package:xstore/features/auth/presentation/widgets/phone_input_field.dart';
import 'package:xstore/features/listing/presentation/providers/listing_form_notifier.dart';
import 'package:xstore/features/listing/presentation/widgets/listing_form_field.dart';
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
  final field = find.descendant(
    of: ancestor,
    matching: find.byType(fieldType),
  );
  await tester.enterText(field, text);
  await tester.pump();
}

/// The tappable region of a `_PickerField` (category/subcategory) — found
/// via its constant label text since the private widget type can't be
/// imported from this test. The label sits as a sibling of the InkWell
/// inside the same Column, so the nearest Column ancestor of the label is
/// that field's own Column.
Finder _pickerFieldTapTarget(String labelText) {
  final column = find
      .ancestor(of: find.text(labelText), matching: find.byType(Column))
      .first;
  return find.descendant(of: column, matching: find.byType(InkWell));
}

/// A tiny (1x1 pixel) but structurally valid JPEG, written to a real temp
/// file so `File(path).existsSync()` checks in the upload path pass.
Future<String> _writeFakePhoto() async {
  const base64Jpeg =
      '/9j/4AAQSkZJRgABAQEAYABgAAD/2wBDAAMCAgICAgMCAgIDAwMDBAYEBAQEBAgGBgUGCQgKCgkICQkKDA8MCgsOCwkJDRENDg8QEBEQCgwSExIQEw8QEBD/2wBDAQMDAwQDBAgEBAgQCwkLEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBD/wAARCAABAAEDASIAAhEBAxEB/8QAFQABAQAAAAAAAAAAAAAAAAAAAAj/xAAUEAEAAAAAAAAAAAAAAAAAAAAA/8QAFQEBAQAAAAAAAAAAAAAAAAAAAAX/xAAUEQEAAAAAAAAAAAAAAAAAAAAA/9oADAMBAAIRAxEAPwCdABmX/9k=';
  final file = File(
    '${Directory.systemTemp.path}/xstore_integration_test_photo.jpg',
  );
  await file.writeAsBytes(base64Decode(base64Jpeg));
  return file.path;
}

/// Picks a top-level category, then a subcategory. A subcategory is
/// required whenever a category is set, but not every live top-level
/// category has children — so this tries successive top-level categories
/// (closing the empty subcategory sheet via its own close icon) until one
/// with real subcategories is found.
Future<void> _pickCategoryAndSubcategory(WidgetTester tester) async {
  const maxAttempts = 8;
  for (var attempt = 0; attempt < maxAttempts; attempt++) {
    await tester.tap(_pickerFieldTapTarget('Category *'));
    await tester.pumpAndSettle();

    final categoryTiles = find.byType(ListTile);
    final available = categoryTiles.evaluate().length;
    if (attempt >= available) {
      fail(
        'Ran out of top-level categories to try ($available available) '
        'while looking for one with subcategories.',
      );
    }
    await tester.tap(categoryTiles.at(attempt));
    await tester.pumpAndSettle();

    await tester.tap(_pickerFieldTapTarget('Subcategory *'));
    await tester.pumpAndSettle();

    final subcategoryTiles = find.byType(ListTile);
    if (subcategoryTiles.evaluate().isNotEmpty) {
      await tester.tap(subcategoryTiles.first);
      await tester.pumpAndSettle();
      return;
    }

    // This category has no subcategories in the live catalog — close the
    // empty sheet and retry with the next top-level category.
    await tester.tap(find.byIcon(LucideIcons.x));
    await tester.pumpAndSettle();
  }
  fail('No top-level category with subcategories found after $maxAttempts attempts.');
}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('vendor can publish a new listing end-to-end', (tester) async {
    await app.bootstrap(AppFlavor.dev);
    await tester.pumpAndSettle(const Duration(seconds: 5));

    // Fresh install / no persisted session -> log in. If a session was
    // already restored (re-running against a warm emulator), skip straight
    // to the Add Listing tab.
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

    // Vendor bottom nav: Home, Explore, Add Listing, Incoming Orders, Profile.
    await tester.tap(find.text('Add Listing').last);
    await tester.pumpAndSettle();

    // Inject a photo the way pickFromGallery would after a real OS picker
    // returns a file — integration_test's synthetic taps can't drive the
    // native gallery/camera picker UI, so this one step calls the real
    // notifier method directly instead of going through ImagePicker.
    final container = ProviderScope.containerOf(
      tester.element(find.byType(ListingFormField).first),
      listen: false,
    );
    final photoPath = await _writeFakePhoto();
    container
        .read(listingFormNotifierProvider.notifier)
        .addPhotoPath(photoPath);
    await tester.pumpAndSettle();

    await _enterText(
      tester,
      ancestor: find.widgetWithText(ListingFormField, 'Product name *'),
      fieldType: TextField,
      text: 'Integration Test Listing',
    );
    await _enterText(
      tester,
      ancestor: find.widgetWithText(ListingFormField, 'Price *'),
      fieldType: TextField,
      text: '199.99',
    );
    await _enterText(
      tester,
      ancestor: find.widgetWithText(ListingFormField, 'Description *'),
      fieldType: TextField,
      text: 'Created by the create-listing integration test.',
    );

    await _pickCategoryAndSubcategory(tester);

    // Condition chip row -> first option (quantity already defaults to 1).
    await tester.tap(find.byType(ChoiceChip).first);
    await tester.pump();

    await _enterText(
      tester,
      ancestor: find.widgetWithText(ListingFormField, 'Location *'),
      fieldType: TextField,
      text: 'Cairo',
    );

    await tester.ensureVisible(find.textContaining('Publish Listing'));
    await tester.pumpAndSettle();
    await tester.tap(find.textContaining('Publish Listing'));
    await tester.pumpAndSettle(const Duration(seconds: 15));

    // Success routes back to My Listings; failure leaves the form up with
    // an error snackbar naming the reason (e.g. a stale seed account no
    // longer satisfying the backend's preconditions) — fail loudly either way.
    expect(
      find.text('My Listings'),
      findsOneWidget,
      reason:
          'Expected publish to succeed and navigate to My Listings. If a '
          'SnackBar with a server error is visible instead, the seeded '
          "vendor account may no longer satisfy the backend's create-listing "
          'preconditions (phone verified + store location set).',
    );
  });
}
