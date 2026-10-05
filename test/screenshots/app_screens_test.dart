// Renders signed-in app screens (real router, MOCK data) to PNG for design
// review. Skipped in the regular suite; run it explicitly:
//   SCREENSHOTS=1 flutter test --dart-define=MOCK=true \
//     test/screenshots/app_screens_test.dart
// Output: build/screenshots/app/<locale>/<screen>_<dark|light>.png
// Network images can't load in tests, so they show their placeholders.
import 'dart:convert';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:xstore/core/constants/prefs_keys.dart';
import 'package:xstore/core/localization/app_localizations.dart';
import 'package:xstore/core/mock/mock_config.dart';
import 'package:xstore/core/router/app_router.dart';
import 'package:xstore/core/router/app_routes.dart';
import 'package:xstore/core/theme/app_theme.dart';
import 'package:xstore/features/auth/domain/entities/user_entity.dart';
import 'package:xstore/features/auth/presentation/providers/auth_provider.dart';
import 'package:xstore/features/explore/data/datasources/explore_remote_datasource.dart';
import 'package:xstore/features/explore/data/models/search_result_model.dart';
import 'package:xstore/features/explore/presentation/explore_dependencies.dart';
import 'package:xstore/features/notifications/presentation/providers/fcm_device_token_sync_provider.dart';
import 'package:xstore/features/notifications/presentation/providers/fcm_push_handling_provider.dart';

import '../helpers/fake_async_auth_notifier.dart';

const _size = Size(390, 844);
const _pixelRatio = 2.0;

const _users = {
  UserRole.consumer: UserEntity(
    id: 'consumer_001',
    name: 'Salma Hassan',
    email: 'salma@example.com',
    phoneNumber: '01012345678',
    role: UserRole.consumer,
    isVerified: true,
  ),
  UserRole.vendor: UserEntity(
    id: 'vendor_001',
    name: 'Stride Store',
    email: 'store@example.com',
    phoneNumber: '01099999999',
    role: UserRole.vendor,
    isVerified: true,
  ),
  UserRole.courier: UserEntity(
    id: 'courier_001',
    name: 'Omar Ali',
    email: 'omar@example.com',
    phoneNumber: '01055500003',
    role: UserRole.courier,
    isVerified: true,
  ),
};

/// (file name, role, route). Add a module's screens here as it's redesigned.
final _screens = <(String, UserRole, String)>[
  ('home', UserRole.consumer, AppRoutes.home),
  ('explore', UserRole.consumer, AppRoutes.explore),
  ('product', UserRole.consumer, '${AppRoutes.product}/listing_001'),
  ('reviews', UserRole.consumer, '${AppRoutes.product}/listing_001/reviews'),
  ('cart', UserRole.consumer, AppRoutes.cart),
  ('checkout', UserRole.consumer, AppRoutes.checkout),
  ('orders', UserRole.consumer, AppRoutes.orders),
  ('order_detail', UserRole.consumer, AppRoutes.orderPath('order_001')),
  ('wishlist', UserRole.consumer, AppRoutes.wishlist),
  ('notifications', UserRole.consumer, AppRoutes.notifications),
  ('vendor_orders', UserRole.vendor, AppRoutes.vendorOrders),
  ('courier_deliveries', UserRole.courier, AppRoutes.deliveries),
];

/// Explore always runs the live geo search (no MOCK branch), so give it a
/// fixed page of sample results for the screenshots.
class _SampleExplore implements ExploreRemoteDataSource {
  static final _results = [
    for (final (id, title, price, store) in [
      ('s1', 'Cloud runner sneakers', 1890, 'Stride Store'),
      ('s2', 'Suede court low', 1250, 'Maadi Kicks'),
      ('s3', 'Trail hiker mid', 2300, 'Outdoor Base'),
      ('s4', 'Canvas high top', 950, 'Stride Store'),
    ])
      SearchResultModel.fromListingLike({
        'id': id,
        'title': title,
        'price': price,
        'seller': {'storeName': store},
      }),
  ];

  @override
  dynamic noSuchMethod(Invocation invocation) {
    if (invocation.memberName == #searchListings) {
      return Future.value(_results);
    }
    if (invocation.memberName == #getSuggestions) {
      return Future.value(<String>[]);
    }
    return super.noSuchMethod(invocation);
  }
}

Future<void> _loadFonts() async {
  final manifest = json.decode(
    await rootBundle.loadString('FontManifest.json'),
  ) as List<dynamic>;
  for (final family in manifest.cast<Map<String, dynamic>>()) {
    final loader = FontLoader(family['family'] as String);
    for (final font in (family['fonts'] as List).cast<Map<String, dynamic>>()) {
      loader.addFont(rootBundle.load(font['asset'] as String));
    }
    await loader.load();
  }
  final flutterRoot = Platform.environment['FLUTTER_ROOT'] ??
      File(Platform.resolvedExecutable).parent.parent.parent.parent.parent.path;
  final materialIcons = File(
    '$flutterRoot/bin/cache/artifacts/material_fonts/MaterialIcons-Regular.otf',
  );
  if (materialIcons.existsSync()) {
    final loader = FontLoader('MaterialIcons')
      ..addFont(Future.value(ByteData.sublistView(materialIcons.readAsBytesSync())));
    await loader.load();
  }
}

void main() {
  final enabled =
      Platform.environment['SCREENSHOTS'] == '1' && MockConfig.useMock;
  final only = Platform.environment['SCREEN'];
  final locale = Locale(Platform.environment['LOCALE'] ?? 'en');

  setUpAll(() async {
    if (enabled) await _loadFonts();
  });

  setUp(() {
    SharedPreferences.setMockInitialValues({
      PrefsKeys.locationPermissionRationaleShown: true,
    });
    FlutterSecureStorage.setMockInitialValues({});
  });

  for (final (name, role, location) in _screens) {
    if (only != null && !name.contains(only)) continue;
    for (final dark in [true, false]) {
      final mode = dark ? 'dark' : 'light';
      testWidgets('$name $mode', skip: !enabled, (tester) async {
        tester.view.physicalSize = _size * _pixelRatio;
        tester.view.devicePixelRatio = _pixelRatio;
        addTearDown(tester.view.reset);

        final boundary = GlobalKey();
        await tester.pumpWidget(
          RepaintBoundary(
            key: boundary,
            child: ProviderScope(
              overrides: [
                authProvider.overrideWith(() => FakeAuth(_users[role])),
                fcmDeviceTokenSyncProvider.overrideWith((ref) {}),
                fcmPushHandlingProvider.overrideWith((ref) {}),
                exploreRemoteDataSourceProvider.overrideWithValue(
                  _SampleExplore(),
                ),
              ],
              child: Consumer(
                builder: (context, ref, _) => MaterialApp.router(
                  debugShowCheckedModeBanner: false,
                  theme: AppTheme.light,
                  darkTheme: AppTheme.dark,
                  themeMode: dark ? ThemeMode.dark : ThemeMode.light,
                  locale: locale,
                  localizationsDelegates: const [
                    AppLocalizations.delegate,
                    GlobalMaterialLocalizations.delegate,
                    GlobalWidgetsLocalizations.delegate,
                    GlobalCupertinoLocalizations.delegate,
                  ],
                  supportedLocales: AppLocalizations.supportedLocales,
                  routerConfig: ref.watch(goRouterProvider),
                ),
              ),
            ),
          ),
        );
        await tester.pump();
        final container = ProviderScope.containerOf(
          tester.element(find.byType(MaterialApp)),
        );
        await tester.runAsync(() => container.read(authProvider.future));
        await tester.pump();
        container.read(goRouterProvider).go(location);
        // Mock datasources resolve after short simulated delays.
        for (var i = 0; i < 30; i++) {
          await tester.runAsync(
            () => Future<void>.delayed(const Duration(milliseconds: 20)),
          );
          await tester.pump(const Duration(milliseconds: 100));
        }

        await tester.runAsync(() async {
          final render = boundary.currentContext!.findRenderObject()!
              as RenderRepaintBoundary;
          final image = await render.toImage(pixelRatio: _pixelRatio);
          final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
          final dir = Directory('build/screenshots/app/${locale.languageCode}')
            ..createSync(recursive: true);
          File('${dir.path}/${name}_$mode.png')
              .writeAsBytesSync(bytes!.buffer.asUint8List());
        });

        await tester.pumpWidget(const SizedBox());
        await tester.pump(const Duration(seconds: 10));
      });
    }
  }
}
