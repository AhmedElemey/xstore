// Screen-level, LIVE-mode (MOCK=false) test of the real ExploreScreen — a
// real user searching/browsing, not fixture data. Matches
// test/orders_screen_live_flow_test.dart's established pattern: real
// screen + real ExploreNotifier -> ExploreRepositoryImpl ->
// ExploreRemoteDataSourceImpl chain, only the Dio HTTP transport is
// scripted.
//
// Unlike a plain `MaterialApp(home: ...)`, `ExploreScreen`'s `initState`
// reads `GoRouterState.of(context)` unconditionally (to seed a category
// filter from a `?category=` query param) — with no `GoRouter` ancestor
// that throws immediately, so every test here uses a routed harness.
//
// Run with: flutter test test/explore_screen_live_flow_test.dart
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:xstore/core/localization/app_localizations.dart';
import 'package:xstore/core/mock/mock_config.dart';
import 'package:xstore/core/network/api_endpoints.dart';
import 'package:xstore/core/network/dio_provider.dart';
import 'package:xstore/features/auth/domain/entities/user_entity.dart';
import 'package:xstore/features/auth/presentation/providers/auth_provider.dart';
import 'package:xstore/features/explore/presentation/screens/explore_screen.dart';

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

UserEntity _consumer() => const UserEntity(
  id: 'consumer_1',
  name: 'Test Buyer',
  email: 'buyer@test.com',
  phoneNumber: '01012345678',
);

Map<String, dynamic> _listingJson({
  required String id,
  required String title,
  num price = 50000,
}) => {
  'id': id,
  'title': title,
  'price': price,
  'status': 2,
  'imageUrls': <String>[],
  'userName': 'Ahmed',
  'categoryNameEn': 'Electronics',
  'condition': 1,
};

/// `GET /api/listings` with no `keyword` query param — the initial,
/// empty-query search `ExploreScreen`'s `initState` fires.
Widget _harness(List<Override> overrides) {
  final router = GoRouter(
    initialLocation: '/explore-under-test',
    routes: [
      GoRoute(
        path: '/explore-under-test',
        builder: (context, state) => const ExploreScreen(),
      ),
    ],
  );
  return ProviderScope(
    overrides: overrides,
    child: MaterialApp.router(
      routerConfig: router,
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
    'consumer opens Explore and sees live search results for the default (empty) query',
    // Exercises ExploreRemoteDataSourceImpl's LIVE (non-mock) branch.
    skip: MockConfig.useMock,
    (tester) async {
      final dio = _fakeDio({
        'GET ${ApiEndpoints.apiListings}': (_) => [
          _listingJson(id: '9001', title: 'Wireless Earbuds'),
          _listingJson(id: '9002', title: 'Bluetooth Speaker'),
        ],
      });

      await tester.pumpWidget(
        _harness([
          authProvider.overrideWith(() => _FakeAuth(_consumer())),
          dioProvider.overrideWithValue(dio),
        ]),
      );
      await _settle(tester);

      expect(find.text('Wireless Earbuds'), findsOneWidget);
      expect(find.text('Bluetooth Speaker'), findsOneWidget);
    },
  );

  testWidgets(
    'consumer types a search query and the debounced live search narrows the results',
    skip: MockConfig.useMock,
    (tester) async {
      final dio = _fakeDio({
        // The initial empty-query search on open.
        'GET ${ApiEndpoints.apiListings}': (options) {
          final keyword = options.queryParameters['keyword'];
          if (keyword == 'speaker') {
            return [_listingJson(id: '9002', title: 'Bluetooth Speaker')];
          }
          return [
            _listingJson(id: '9001', title: 'Wireless Earbuds'),
            _listingJson(id: '9002', title: 'Bluetooth Speaker'),
          ];
        },
      });

      await tester.pumpWidget(
        _harness([
          authProvider.overrideWith(() => _FakeAuth(_consumer())),
          dioProvider.overrideWithValue(dio),
        ]),
      );
      await _settle(tester);

      expect(find.text('Wireless Earbuds'), findsOneWidget);
      expect(find.text('Bluetooth Speaker'), findsOneWidget);

      await tester.enterText(find.byType(TextField).first, 'speaker');
      // onQueryChanged debounces the actual search behind a real 400ms
      // Timer — advance the fake clock past it (matching the established
      // OtpResendCooldown-style live-Timer handling) rather than settling
      // with the default 100ms step, which would never cross it.
      await tester.pump(const Duration(milliseconds: 450));
      await _settle(tester);

      expect(
        find.text('Wireless Earbuds'),
        findsNothing,
        reason: 'the live search should narrow to the typed keyword',
      );
      // Two matches, not one: `getSuggestions` derives typeahead
      // suggestions from the SAME GET /api/listings?keyword= endpoint (no
      // dedicated typeahead route exists), so a focused, matching search
      // shows both the real result card and a suggestion chip with the
      // same title — real behavior, not a rendering bug.
      expect(find.text('Bluetooth Speaker'), findsWidgets);
    },
  );
}
