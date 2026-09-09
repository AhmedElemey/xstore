// Screen-level, LIVE-mode test of the real VendorWalletScreen — a real
// vendor viewing their commission-fee overview, not fixture data.
// Matches test/vendor_orders_screen_live_flow_test.dart's established
// pattern: real screen + real OrdersRepositoryImpl ->
// OrdersRemoteDataSourceImpl chain, only the Dio HTTP transport is
// scripted.
//
// There is no dedicated vendor-wallet endpoint (see
// commission_config_provider.dart's doc comment) — revenue/order-count
// and the commission/threshold fields all come from the SAME
// `GET /api/vendor/orders` envelope vendor_orders_screen_live_flow_test
// .dart already scripts, just parsed differently
// (vendorCommissionSnapshotProvider) and re-derived
// (vendorCommissionWalletProvider) — one scripted route serves both,
// same as the courier cash/deliveries endpoint-sharing lesson in
// flutter-review/SKILL.md.
//
// VendorWalletScreen is a plain ConsumerWidget (no initState fetch at
// all) built entirely on `@riverpod` FutureProviders that themselves
// watch authProvider — like CourierCashScreen, no `_pumpReady`
// re-trigger workaround is needed, just a plain pumpWidget + settle.
//
// getVendorOrderStats has a MockConfig branch — this test needs the
// usual `skip: MockConfig.useMock`.
//
// Run with: flutter test test/vendor_wallet_screen_live_flow_test.dart
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:xstore/core/localization/app_localizations.dart';
import 'package:xstore/core/mock/mock_config.dart';
import 'package:xstore/core/network/api_endpoints.dart';
import 'package:xstore/core/network/dio_provider.dart';
import 'package:xstore/features/auth/domain/entities/user_entity.dart';
import 'package:xstore/features/auth/presentation/providers/auth_provider.dart';
import 'package:xstore/features/commission/presentation/screens/vendor_wallet_screen.dart';

/// Routes each request by (method, path) to a scripted response — same
/// technique as vendor_orders_screen_live_flow_test.dart's
/// `_RoutedInterceptor`.
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
  phoneNumber: '01012345678',
  role: UserRole.vendor,
);

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
    home: VendorWalletScreen(),
  ),
);

/// Bounded frame pump instead of `pumpAndSettle()` — matches the
/// established convention from vendor_orders_screen_live_flow_test.dart.
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
    'vendor in good standing sees their live revenue, order count, and fee',
    skip: MockConfig.useMock,
    (tester) async {
      final dio = _fakeDio({
        'GET ${ApiEndpoints.vendorOrders}': (_) => {
          'orders': <Map<String, dynamic>>[],
          'totalCount': 12,
          'pendingCount': 1,
          'confirmedCount': 2,
          'totalRevenue': 4500,
          'commissionValueOnOrder': 5,
          'warnThresholdEgp': 100,
          'pauseThresholdEgp': 200,
          'exceedsWarnThreshold': false,
          'exceedsPauseThreshold': false,
        },
      });

      await tester.pumpWidget(
        _harness([
          authProvider.overrideWith(() => _FakeAuth(_vendor())),
          dioProvider.overrideWithValue(dio),
        ]),
      );
      await _settle(tester);

      expect(find.text('Your platform fees are up to date.'), findsOneWidget);
      expect(find.text('EGP 4,500'), findsOneWidget);
      expect(find.text('12'), findsOneWidget);
      expect(find.text('EGP 5'), findsOneWidget);
    },
  );

  testWidgets(
    'vendor past the warn threshold sees the live alert banner instead of good standing',
    skip: MockConfig.useMock,
    (tester) async {
      final dio = _fakeDio({
        'GET ${ApiEndpoints.vendorOrders}': (_) => {
          'orders': <Map<String, dynamic>>[],
          'totalCount': 40,
          'pendingCount': 0,
          'confirmedCount': 0,
          'totalRevenue': 15000,
          'commissionValueOnOrder': 5,
          'warnThresholdEgp': 100,
          'pauseThresholdEgp': 200,
          'exceedsWarnThreshold': true,
          'exceedsPauseThreshold': false,
        },
      });

      await tester.pumpWidget(
        _harness([
          authProvider.overrideWith(() => _FakeAuth(_vendor())),
          dioProvider.overrideWithValue(dio),
        ]),
      );
      await _settle(tester);

      expect(
        find.text('Your platform fees are up to date.'),
        findsNothing,
      );
    },
  );
}
