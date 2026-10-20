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
import 'package:xstore/shared/widgets/error_state_widget.dart';
import 'package:xstore/shared/widgets/xstore_button.dart';

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

Widget _harness(List<Override> overrides, {Locale? locale}) => ProviderScope(
  overrides: overrides,
  child: MaterialApp(
    locale: locale,
    localizationsDelegates: const [
      AppLocalizations.delegate,
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
    ],
    supportedLocales: AppLocalizations.supportedLocales,
    home: const VendorWalletScreen(),
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
      expect(find.text('4,500 LE'), findsOneWidget);
      expect(find.text('12'), findsOneWidget);
      expect(find.text('5 LE'), findsOneWidget);
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
  testWidgets(
    'a failed load shows the error state with Retry, not zero totals',
    skip: MockConfig.useMock,
    (tester) async {
      var fail = true;
      final dio = _fakeDio({
        'GET ${ApiEndpoints.vendorOrders}': (options) => fail
            ? DioException(
                requestOptions: options,
                type: DioExceptionType.connectionError,
              )
            : {
                'orders': <Map<String, dynamic>>[],
                'totalCount': 12,
                'totalRevenue': 4500,
                'commissionValueOnOrder': 5,
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

      expect(find.byType(ErrorStateWidget), findsOneWidget);
      expect(find.text('Your platform fees are up to date.'), findsNothing);
      expect(find.text('0 LE'), findsNothing);

      fail = false;
      await tester.tap(find.text('Retry'));
      await _settle(tester);

      expect(find.byType(ErrorStateWidget), findsNothing);
      expect(find.text('Your platform fees are up to date.'), findsOneWidget);
      expect(find.text('4,500 LE'), findsOneWidget);
    },
  );

  testWidgets(
    'a vendor with no revenue yet still sees fees up to date',
    skip: MockConfig.useMock,
    (tester) async {
      final dio = _fakeDio({
        'GET ${ApiEndpoints.vendorOrders}': (_) => {
          'orders': <Map<String, dynamic>>[],
          'totalCount': 0,
          'totalRevenue': 0,
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

      expect(find.byType(ErrorStateWidget), findsNothing);
      expect(find.text('Your platform fees are up to date.'), findsOneWidget);
    },
  );

  group('outstanding balance (live envelope shape, 2026-10-20)', () {
    Map<String, dynamic> envelope({
      required double outstandingBalance,
      bool exceedsWarn = false,
    }) => {
      'orders': <Map<String, dynamic>>[],
      'totalCount': 3,
      'pendingCount': 0,
      'confirmedCount': 0,
      'totalRevenue': 292.0,
      'outstandingBalance': outstandingBalance,
      'warnThresholdEgp': 1000.0,
      'pauseThresholdEgp': 5000.0,
      'exceedsWarnThreshold': exceedsWarn,
      'exceedsPauseThreshold': false,
      'commissionValueOnOrder': 10.0,
    };

    Future<void> pump(
      WidgetTester tester,
      Map<String, dynamic> body, {
      Locale? locale,
    }) async {
      final dio = _fakeDio({'GET ${ApiEndpoints.vendorOrders}': (_) => body});
      await tester.pumpWidget(
        _harness([
          authProvider.overrideWith(() => _FakeAuth(_vendor())),
          dioProvider.overrideWithValue(dio),
        ], locale: locale),
      );
      await _settle(tester);
    }

    VoidCallback? payOnPressed(WidgetTester tester) =>
        tester.widget<XstoreButton>(find.byType(XstoreButton)).onPressed;

    testWidgets(
      'nothing owed shows 0, good standing, and disables Pay',
      skip: MockConfig.useMock,
      (tester) async {
        await pump(tester, envelope(outstandingBalance: 0));

        expect(find.text('Platform fees owed'), findsOneWidget);
        expect(find.text('0 LE'), findsOneWidget);
        expect(find.text('Your platform fees are up to date.'), findsOneWidget);
        expect(find.textContaining('before the warning limit'), findsNothing);
        expect(payOnPressed(tester), isNull);
      },
    );

    testWidgets(
      'a balance below warn shows the amount, limits, and orders left',
      skip: MockConfig.useMock,
      (tester) async {
        await pump(tester, envelope(outstandingBalance: 350));

        expect(find.text('350 LE'), findsOneWidget);
        expect(find.text('Warning at 1,000 LE'), findsOneWidget);
        expect(find.text('Pause at 5,000 LE'), findsOneWidget);
        expect(
          find.text('About 65 more orders before the warning limit'),
          findsOneWidget,
        );
        final bar = tester.widget<LinearProgressIndicator>(
          find.byType(LinearProgressIndicator),
        );
        expect(bar.value, closeTo(0.07, 0.001));
        expect(find.text('Your platform fees are up to date.'), findsNothing);
        expect(payOnPressed(tester), isNotNull);
      },
    );

    testWidgets(
      'past warn: banner explains it, card shows the amount without the hint',
      skip: MockConfig.useMock,
      (tester) async {
        await pump(
          tester,
          envelope(outstandingBalance: 1200, exceedsWarn: true),
        );

        expect(find.text('Pay your platform fees soon'), findsOneWidget);
        expect(find.text('1,200 LE'), findsOneWidget);
        expect(find.textContaining('before the warning limit'), findsNothing);
        expect(find.text('Your platform fees are up to date.'), findsNothing);
        expect(payOnPressed(tester), isNotNull);
      },
    );

    testWidgets(
      'Arabic at 320x640 lays out without overflow',
      skip: MockConfig.useMock,
      (tester) async {
        tester.view.physicalSize = const Size(320, 640);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.reset);

        await pump(
          tester,
          envelope(outstandingBalance: 350),
          locale: const Locale('ar'),
        );

        expect(tester.takeException(), isNull);
        expect(find.text('رسوم المنصة المستحقة'), findsOneWidget);
        expect(find.textContaining('قبل حد التنبيه'), findsOneWidget);
      },
    );
  });
}
