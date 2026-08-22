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
import 'package:xstore/features/commission/presentation/providers/vendor_commission_wallet_provider.dart';
import 'package:xstore/features/listing/presentation/screens/add_listing_screen.dart';
import 'package:xstore/features/listing/presentation/widgets/category_picker_sheet.dart';

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
    CatalogCategoryEntity(
      id: 33,
      name: LocalizedText(en: 'Accessories', ar: 'الإكسسوارات'),
      parentId: 7,
    ),
  ],
);

const _beauty = CatalogCategoryEntity(
  id: 4,
  name: LocalizedText(en: 'Beauty', ar: 'الجمال'),
  children: [
    CatalogCategoryEntity(
      id: 23,
      name: LocalizedText(en: 'Skincare', ar: 'العناية بالبشرة'),
      parentId: 4,
    ),
  ],
);

const _catalog = [_automotive, _beauty];

const _emptyWallet = VendorCommissionWallet(
  exceedsWarnThreshold: false,
  exceedsPauseThreshold: false,
  warnThresholdEgp: 100,
  pauseThresholdEgp: 200,
);

List<Override> _catalogOverrides({
  List<CatalogCategoryEntity> categories = _catalog,
  Duration? delay,
  Object? error,
}) {
  return [
    allCatalogCategoriesProvider.overrideWith((ref) async {
      if (error != null) throw error;
      if (delay != null) await Future<void>.delayed(delay);
      return categories;
    }),
  ];
}

Widget _app({
  required Widget home,
  List<Override> extraOverrides = const [],
  List<CatalogCategoryEntity> categories = _catalog,
  Duration? delay,
  Object? error,
}) {
  return ProviderScope(
    overrides: [
      ..._catalogOverrides(
        categories: categories,
        delay: delay,
        error: error,
      ),
      ...extraOverrides,
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

/// Nested navigator + bottom bar, matching Add Listing as a shell tab.
Widget _shellTab({
  required Widget Function(BuildContext context) child,
  Duration? delay,
  Object? error,
}) {
  return _app(
    delay: delay,
    error: error,
    home: Scaffold(
      body: Navigator(
        onGenerateRoute: (_) => MaterialPageRoute(
          builder: (ctx) => Scaffold(body: child(ctx)),
        ),
      ),
      bottomNavigationBar: const SizedBox(
        height: 72,
        child: ColoredBox(
          color: Colors.black,
          child: Center(child: Text('tab-bar')),
        ),
      ),
    ),
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('shows a spinner until /api/categories resolves, then names',
      (tester) async {
    await tester.pumpWidget(
      _app(
        delay: const Duration(milliseconds: 80),
        home: Scaffold(
          body: Builder(
            builder: (context) => TextButton(
              onPressed: () => showListingCategoryPicker(
                context: context,
                title: 'Category',
                selectedId: null,
                onSelected: (_) {},
              ),
              child: const Text('open-cat'),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('open-cat'));
    await tester.pump();
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(find.text('Automotive'), findsNothing);

    await tester.pumpAndSettle();
    expect(find.text('Automotive'), findsOneWidget);
    expect(find.text('Beauty'), findsOneWidget);
    expect(find.text('Parts'), findsNothing);
  });

  testWidgets('error in the sheet is visible with retry, not a dead tap',
      (tester) async {
    await tester.pumpWidget(
      _app(
        error: Exception('network'),
        home: Scaffold(
          body: Builder(
            builder: (context) => TextButton(
              onPressed: () => showListingCategoryPicker(
                context: context,
                title: 'Category',
                selectedId: null,
                onSelected: (_) {},
              ),
              child: const Text('open-cat'),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('open-cat'));
    await tester.pumpAndSettle();

    expect(find.text('Retry'), findsOneWidget);
    expect(find.text('Automotive'), findsNothing);
  });

  testWidgets('tapping a category pops its id', (tester) async {
    int? picked;
    await tester.pumpWidget(
      _app(
        home: Scaffold(
          body: Builder(
            builder: (context) => TextButton(
              onPressed: () => showListingCategoryPicker(
                context: context,
                title: 'Category',
                selectedId: null,
                onSelected: (id) => picked = id,
              ),
              child: const Text('open-cat'),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('open-cat'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Automotive'));
    await tester.pumpAndSettle();

    expect(picked, 7);
    expect(find.text('Automotive'), findsNothing);
  });

  testWidgets('subcategory picker lists the selected category children',
      (tester) async {
    await tester.pumpWidget(
      _app(
        home: Scaffold(
          body: Builder(
            builder: (context) => TextButton(
              onPressed: () => showListingSubcategoryPicker(
                context: context,
                title: 'Subcategory',
                parentId: 7,
                selectedId: null,
                onSelected: (_) {},
              ),
              child: const Text('open-sub'),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('open-sub'));
    await tester.pumpAndSettle();

    expect(find.text('Parts'), findsOneWidget);
    expect(find.text('Accessories'), findsOneWidget);
    expect(find.text('Automotive'), findsNothing);
  });

  testWidgets('names stay hit-testable above a shell tab bar', (tester) async {
    int? picked;
    await tester.pumpWidget(
      _shellTab(
        child: (context) => Center(
          child: TextButton(
            onPressed: () => showListingCategoryPicker(
              context: context,
              title: 'Category',
              selectedId: null,
              onSelected: (id) => picked = id,
            ),
            child: const Text('open-cat'),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('open-cat'));
    await tester.pumpAndSettle();

    expect(find.text('Automotive').hitTestable(), findsOneWidget);
    await tester.tap(find.text('Automotive'));
    await tester.pumpAndSettle();

    expect(picked, 7);
    expect(find.text('open-cat'), findsOneWidget);
    expect(find.text('tab-bar'), findsOneWidget);
  });

  testWidgets(
    'Add Listing category field opens catalog, pick updates subcategory children',
    (tester) async {
      tester.view.physicalSize = const Size(400, 1200);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        _app(
          extraOverrides: [
            authProvider.overrideWith(() => FakeAuth(
                  const UserEntity(
                    id: 'v1',
                    name: 'Vendor',
                    email: 'v@test.com',
                    phoneNumber: '01000000000',
                    role: UserRole.vendor,
                  ),
                )),
            vendorCommissionWalletProvider.overrideWith(
              (ref) async => _emptyWallet,
            ),
          ],
          home: const AddListingScreen(),
        ),
      );
      await tester.pumpAndSettle();

      await tester.scrollUntilVisible(
        find.text('Select category'),
        200,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.tap(find.text('Select category'));
      await tester.pumpAndSettle();

      expect(find.text('Automotive').hitTestable(), findsOneWidget);
      expect(find.text('Beauty').hitTestable(), findsOneWidget);

      await tester.tap(find.text('Automotive'));
      await tester.pumpAndSettle();

      expect(find.text('Automotive'), findsWidgets);
      await tester.scrollUntilVisible(
        find.text('Select subcategory'),
        200,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.tap(find.text('Select subcategory'));
      await tester.pumpAndSettle();

      expect(find.text('Parts').hitTestable(), findsOneWidget);
      expect(find.text('Accessories').hitTestable(), findsOneWidget);

      await tester.tap(find.text('Parts'));
      await tester.pumpAndSettle();
      expect(find.text('Parts'), findsWidgets);
    },
  );
}
