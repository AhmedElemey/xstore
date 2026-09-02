// Screen-level, LIVE-mode test of the real MyListingsScreen — a real
// vendor tapping through the app, not fixture data. Matches
// test/orders_screen_live_flow_test.dart's established pattern: real
// screen + real ListingRepositoryImpl -> ListingRemoteDataSourceImpl
// chain, only the Dio HTTP transport is scripted.
//
// ListingRemoteDataSourceImpl.fetchMyListings/deactivateListing have no
// MockConfig.useMock branch at all — always live, regardless of the MOCK
// build define — so these tests run (and must pass) under both
// `flutter test` and `flutter test --dart-define=MOCK=true`, no `skip:`
// needed (same characteristic as notifications_screen_live_flow_test.dart).
//
// MyListingsNotifier is also a plain self-fetching `@riverpod`
// AsyncNotifier-style build() (`Future.microtask(fetchListings)`, no auth
// dependency at all) — no initState postFrameCallback, so none of the
// auth-prewarm machinery other screens needed applies here.
//
// Run with: flutter test test/my_listings_screen_live_flow_test.dart
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:xstore/core/localization/app_localizations.dart';
import 'package:xstore/core/network/api_endpoints.dart';
import 'package:xstore/core/network/dio_provider.dart';
import 'package:xstore/features/auth/domain/entities/user_entity.dart';
import 'package:xstore/features/auth/presentation/providers/auth_provider.dart';
import 'package:xstore/features/listing/presentation/screens/my_listings_screen.dart';

/// Routes each request by (method, path) to a scripted response — same
/// technique as orders_screen_live_flow_test.dart's `_RoutedInterceptor`.
class _RoutedInterceptor extends Interceptor {
  _RoutedInterceptor(this._routes);

  final Map<String, Object? Function(RequestOptions options)> _routes;

  String _key(RequestOptions o) => '${o.method} ${o.path}';

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final route = _routes[_key(options)];
    if (route == null) {
      handler.reject(
        DioException(
          requestOptions: options,
          error: StateError('unscripted request: ${_key(options)}'),
        ),
      );
      return;
    }
    final result = route(options);
    if (result is DioException) {
      handler.reject(result);
    } else {
      handler.resolve(
        Response(requestOptions: options, statusCode: 200, data: result),
      );
    }
  }
}

Dio _fakeDio(Map<String, Object? Function(RequestOptions)> routes) {
  final d = Dio(BaseOptions(baseUrl: ApiEndpoints.baseUrl));
  d.interceptors.add(_RoutedInterceptor(routes));
  return d;
}

class _FakeAuth extends Auth {
  _FakeAuth(this._user);
  final UserEntity? _user;
  @override
  Future<UserEntity?> build() async => _user;
}

UserEntity _vendor() => const UserEntity(
  id: 'vendor_1',
  name: 'Test Vendor',
  email: 'vendor@test.com',
  phoneNumber: '01099999999',
  role: UserRole.vendor,
);

Map<String, dynamic> _listingJson({
  String id = '9001',
  String title = 'Wireless Earbuds',
  num price = 50000,
  int status = 2,
}) => {'id': id, 'title': title, 'description': 'A listing', 'price': price, 'status': status};

Widget _harness(List<Override> overrides) => ProviderScope(
  overrides: overrides,
  child: const MaterialApp(
    localizationsDelegates: [
      AppLocalizations.delegate,
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
    ],
    supportedLocales: AppLocalizations.supportedLocales,
    // MyListingsScreen renders its own Scaffold, so no extra Material
    // wrapper is needed here.
    home: MyListingsScreen(),
  ),
);

/// Bounded frame pump instead of `pumpAndSettle()` — matches the
/// established convention from orders_screen_live_flow_test.dart.
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
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    FlutterSecureStorage.setMockInitialValues({});
  });

  testWidgets(
    'vendor views their live listings with stats',
    (tester) async {
      final dio = _fakeDio({
        'GET ${ApiEndpoints.apiMyListings}': (_) => [_listingJson()],
      });

      await tester.pumpWidget(
        _harness([
          authProvider.overrideWith(() => _FakeAuth(_vendor())),
          dioProvider.overrideWithValue(dio),
        ]),
      );
      await _settle(tester);

      expect(find.text('My Listings'), findsOneWidget);
      expect(find.text('Wireless Earbuds'), findsOneWidget);
    },
  );

  testWidgets(
    'vendor pauses an active listing via the live deactivate wire call',
    (tester) async {
      RequestOptions? putRequest;
      final dio = _fakeDio({
        'GET ${ApiEndpoints.apiMyListings}': (_) => [_listingJson()],
        'PUT ${ApiEndpoints.apiListingDeactivate('9001')}': (options) {
          putRequest = options;
          return _listingJson(status: 3);
        },
      });

      await tester.pumpWidget(
        _harness([
          authProvider.overrideWith(() => _FakeAuth(_vendor())),
          dioProvider.overrideWithValue(dio),
        ]),
      );
      await _settle(tester);

      expect(find.text('Wireless Earbuds'), findsOneWidget);
      await tester.tap(find.byIcon(LucideIcons.moreVertical));
      await _settle(tester);

      expect(find.text('Pause'), findsOneWidget);
      await tester.tap(find.text('Pause'));
      await _settle(tester);

      expect(putRequest, isNotNull);
    },
  );
}
