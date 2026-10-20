// TEMPORARY — renders VendorWalletScreen states to PNG for review.
// Lives only on the tmp/wallet-screenshots branch; never merged.
import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:xstore/core/localization/app_localizations.dart';
import 'package:xstore/core/network/api_endpoints.dart';
import 'package:xstore/core/network/dio_provider.dart';
import 'package:xstore/core/theme/app_theme.dart';
import 'package:xstore/features/auth/domain/entities/user_entity.dart';
import 'package:xstore/features/auth/presentation/providers/auth_provider.dart';
import 'package:xstore/features/commission/presentation/screens/vendor_wallet_screen.dart';

class _Routed extends Interceptor {
  _Routed(this.body);
  final Map<String, dynamic>? body;
  @override
  void onRequest(RequestOptions o, RequestInterceptorHandler h) {
    h.resolve(Response(requestOptions: o, statusCode: 200, data: body));
  }
}

class _FakeAuth extends Auth {
  @override
  Future<UserEntity?> build() async => const UserEntity(
    id: 'vendor_1',
    name: 'Test Vendor',
    email: 'vendor@test.com',
    phoneNumber: '01012345678',
    role: UserRole.vendor,
  );
}

Future<void> _loadFonts() async {
  final manifest =
      json.decode(await rootBundle.loadString('FontManifest.json')) as List;
  for (final f in manifest.cast<Map<String, dynamic>>()) {
    final loader = FontLoader(f['family'] as String);
    for (final font in (f['fonts'] as List).cast<Map<String, dynamic>>()) {
      loader.addFont(rootBundle.load(font['asset'] as String));
    }
    await loader.load();
  }
}

Map<String, dynamic> _env(
  double? balance, {
  bool warn = false,
  bool pause = false,
}) => {
  'orders': <Map<String, dynamic>>[],
  'totalCount': 3,
  'pendingCount': 0,
  'confirmedCount': 0,
  'totalRevenue': 292.0,
  if (balance != null) 'outstandingBalance': balance,
  'warnThresholdEgp': 1000.0,
  'pauseThresholdEgp': 5000.0,
  'exceedsWarnThreshold': warn,
  'exceedsPauseThreshold': pause,
  'commissionValueOnOrder': 10.0,
};

void main() {
  setUpAll(_loadFonts);
  setUp(() {
    SharedPreferences.setMockInitialValues({});
    FlutterSecureStorage.setMockInitialValues({});
  });

  final cases = <String, (Map<String, dynamic>, Locale, bool)>{
    '1_en_zero': (_env(0), const Locale('en'), false),
    '2_en_350': (_env(350), const Locale('en'), false),
    '3_en_warn_1200': (_env(1200, warn: true), const Locale('en'), false),
    '4_en_paused_5200': (
      _env(5200, warn: true, pause: true),
      const Locale('en'),
      false,
    ),
    '5_ar_350': (_env(350), const Locale('ar'), false),
    '6_en_350_dark': (_env(350), const Locale('en'), true),
    '7_en_no_field_old_backend': (_env(null), const Locale('en'), false),
  };

  for (final MapEntry(key: name, value: (body, locale, dark)) in cases.entries) {
    testWidgets(name, (tester) async {
      tester.view.physicalSize = const Size(1170, 2532);
      tester.view.devicePixelRatio = 3;
      addTearDown(tester.view.reset);

      final dio = Dio(BaseOptions(baseUrl: ApiEndpoints.baseUrl))
        ..interceptors.add(_Routed(body));
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            authProvider.overrideWith(_FakeAuth.new),
            dioProvider.overrideWithValue(dio),
          ],
          child: MaterialApp(
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
            home: const Scaffold(body: VendorWalletScreen()),
          ),
        ),
      );
      for (var i = 0; i < 20; i++) {
        await tester.pump(const Duration(milliseconds: 100));
      }
      await expectLater(
        find.byType(MaterialApp),
        matchesGoldenFile('shots/$name.png'),
      );
    });
  }
}
