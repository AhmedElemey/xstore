import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:xstore/core/localization/app_localizations.dart';
import 'package:xstore/core/localization/localized_text.dart';
import 'package:xstore/features/auth/domain/entities/user_entity.dart';
import 'package:xstore/features/auth/presentation/providers/auth_provider.dart';
import 'package:xstore/features/catalog_categories/domain/entities/catalog_category_entity.dart';
import 'package:xstore/features/catalog_categories/presentation/providers/catalog_category_dependencies.dart';
import 'package:xstore/features/commission/domain/entities/vendor_commission_wallet.dart';
import 'package:xstore/features/commission/presentation/providers/commission_config_provider.dart';
import 'package:xstore/features/commission/presentation/providers/vendor_commission_wallet_provider.dart';
import 'package:xstore/features/listing/domain/entities/listing_entity.dart';
import 'package:xstore/features/listing/presentation/screens/add_listing_screen.dart';

import 'helpers/fake_async_auth_notifier.dart';

const _automotive = CatalogCategoryEntity(
  id: 7,
  name: LocalizedText(en: 'Automotive', ar: 'السيارات'),
  children: [
    CatalogCategoryEntity(
      id: 32,
      name: LocalizedText(en: 'Parts', ar: 'قطع غيار'),
      parentId: 7,
    ),
  ],
);

const _emptyWallet = VendorCommissionWallet(
  exceedsWarnThreshold: false,
  exceedsPauseThreshold: false,
  warnThresholdEgp: 100,
  pauseThresholdEgp: 200,
);

const _existingListing = ListingEntity(
  id: '42',
  title: 'Old Title',
  description: 'Old description',
  price: 199.5,
  status: ListingStatus.paused,
  titleEn: 'Wireless Mouse',
  descriptionEn: 'A great wireless mouse',
  imageUrls: ['https://example.com/a.jpg'],
  categoryId: 7,
  subcategoryId: 32,
  condition: ListingCondition.likeNew,
  brand: 'Logitech',
  stockQuantity: 3,
  shippingAvailable: true,
  shippingCost: 25,
  location: 'Cairo',
  attributes: {'Color': 'Black'},
);

Widget _app({required Widget home}) {
  return ProviderScope(
    overrides: [
      allCatalogCategoriesProvider.overrideWith((ref) async => [_automotive]),
      authProvider.overrideWith(() => FakeAuth(
            const UserEntity(
              id: 'v1',
              name: 'Vendor',
              email: 'v@test.com',
              phoneNumber: '01000000000',
              role: UserRole.vendor,
            ),
          )),
      vendorCommissionWalletProvider.overrideWith((ref) async => _emptyWallet),
      // Never let the real (mock-datasource) order-stats path run under
      // flutter_test — it schedules a simulated-latency Timer via
      // MockConfig.simulate that the test binding flags as still pending
      // after teardown. See the 2026-07-19 lesson in flutter-review/SKILL.md.
      vendorCommissionSnapshotProvider.overrideWith((ref) async => null),
    ],
    child: MaterialApp(
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      home: home,
    ),
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets(
    'Edit Listing prefills the text fields with the listing\'s current data',
    (tester) async {
      await tester.pumpWidget(
        _app(home: const AddListingScreen(editingListing: _existingListing)),
      );
      await tester.pumpAndSettle();

      final nameField = tester.widget<TextField>(
        find.widgetWithText(TextField, 'Wireless Mouse'),
      );
      expect(nameField.controller!.text, 'Wireless Mouse');

      final descField = tester.widget<TextField>(
        find.widgetWithText(TextField, 'A great wireless mouse'),
      );
      expect(descField.controller!.text, 'A great wireless mouse');

      final brandField = tester.widget<TextField>(
        find.widgetWithText(TextField, 'Logitech'),
      );
      expect(brandField.controller!.text, 'Logitech');

      final locationField = tester.widget<TextField>(
        find.widgetWithText(TextField, 'Cairo'),
      );
      expect(locationField.controller!.text, 'Cairo');

      expect(find.text('199.50'), findsOneWidget);
      expect(find.text('Update Listing'), findsOneWidget);
    },
  );
}
