// Renders the auth screens to PNG for design review. Skipped in the regular
// suite; run it explicitly:
//   SCREENSHOTS=1 flutter test test/screenshots/auth_screens_test.dart
// Output: build/screenshots/auth/<screen>_<dark|light>.png
import 'dart:convert';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:xstore/core/constants/prefs_keys.dart';
import 'package:xstore/core/localization/app_localizations.dart';
import 'package:xstore/core/network/api_endpoints.dart';
import 'package:xstore/core/network/dio_provider.dart';
import 'package:xstore/core/router/app_routes.dart';
import 'package:xstore/core/theme/app_theme.dart';
import 'package:xstore/features/auth/domain/entities/user_entity.dart';
import 'package:xstore/features/auth/presentation/providers/auth_provider.dart';
import 'package:xstore/features/auth/presentation/screens/change_password_screen.dart';
import 'package:xstore/features/auth/presentation/screens/courier_login_screen.dart';
import 'package:xstore/features/auth/presentation/screens/forgot_password_otp_screen.dart';
import 'package:xstore/features/auth/presentation/screens/forgot_password_screen.dart';
import 'package:xstore/features/auth/presentation/screens/login_screen.dart';
import 'package:xstore/features/auth/presentation/screens/onboarding_screen.dart';
import 'package:xstore/features/auth/presentation/screens/otp_screen.dart';
import 'package:xstore/features/auth/presentation/screens/register_screen.dart';
import 'package:xstore/features/auth/presentation/screens/reset_password_screen.dart';
import 'package:xstore/features/auth/presentation/screens/social_role_screen.dart';
import 'package:xstore/features/auth/presentation/screens/splash_screen.dart';

const _size = Size(390, 844);
const _pixelRatio = 2.0;

/// Every request fails as offline, so screens render their idle state.
class _OfflineInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    handler.reject(
      DioException(
        requestOptions: options,
        type: DioExceptionType.connectionError,
      ),
    );
  }
}

/// Signed out, without touching Firebase.
class _SignedOut extends Auth {
  @override
  Future<UserEntity?> build() async => null;
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

GoRouter _router(String location, Object? extra) {
  Widget stub(String name) => Scaffold(body: Center(child: Text(name)));
  return GoRouter(
    initialLocation: location,
    initialExtra: extra,
    routes: [
      GoRoute(path: AppRoutes.splash, builder: (_, __) => const SplashScreen()),
      GoRoute(
        path: AppRoutes.onboarding,
        builder: (_, __) => const OnboardingScreen(),
      ),
      GoRoute(path: AppRoutes.login, builder: (_, __) => const LoginScreen()),
      GoRoute(
        path: AppRoutes.register,
        builder: (_, __) => const RegisterScreen(),
      ),
      GoRoute(path: AppRoutes.otp, builder: (_, __) => const OtpScreen()),
      GoRoute(
        path: AppRoutes.forgotPassword,
        builder: (_, __) => const ForgotPasswordScreen(),
      ),
      GoRoute(
        path: AppRoutes.forgotPasswordOtp,
        builder: (_, s) => ForgotPasswordOtpScreen(email: s.extra! as String),
      ),
      GoRoute(
        path: AppRoutes.resetPassword,
        builder: (_, s) =>
            ResetPasswordScreen(args: s.extra! as ResetPasswordArgs),
      ),
      GoRoute(
        path: AppRoutes.socialRoleSelect,
        builder: (_, __) => const SocialRoleScreen(),
      ),
      GoRoute(
        path: AppRoutes.courierLogin,
        builder: (_, __) => const CourierLoginScreen(),
      ),
      GoRoute(
        path: AppRoutes.changePassword,
        builder: (_, __) => const ChangePasswordScreen(),
      ),
      GoRoute(path: '/:rest(.*)', builder: (_, s) => stub(s.uri.path)),
    ],
  );
}

final _screens = <(String, String, Object?)>[
  ('01_splash', AppRoutes.splash, null),
  ('02_onboarding', AppRoutes.onboarding, null),
  ('03_login', AppRoutes.login, null),
  ('04_register', AppRoutes.register, null),
  ('05_otp', AppRoutes.otp, null),
  ('06_forgot_password', AppRoutes.forgotPassword, null),
  ('07_forgot_password_code', AppRoutes.forgotPasswordOtp, 'salma@example.com'),
  (
    '08_reset_password',
    AppRoutes.resetPassword,
    const ResetPasswordArgs(email: 'salma@example.com', otpToken: 't'),
  ),
  ('09_social_role', AppRoutes.socialRoleSelect, null),
  ('10_courier_login', AppRoutes.courierLogin, null),
  ('11_change_password', AppRoutes.changePassword, null),
];

void main() {
  final enabled = Platform.environment['SCREENSHOTS'] == '1';
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

  for (final (name, location, extra) in _screens) {
    if (only != null && !name.contains(only)) continue;
    for (final dark in [true, false]) {
      final mode = dark ? 'dark' : 'light';
      testWidgets('$name $mode', skip: !enabled, (tester) async {
        tester.view.physicalSize = _size * _pixelRatio;
        tester.view.devicePixelRatio = _pixelRatio;
        addTearDown(tester.view.reset);

        final dio = Dio(BaseOptions(baseUrl: ApiEndpoints.baseUrl))
          ..interceptors.add(_OfflineInterceptor());
        final boundary = GlobalKey();
        await tester.pumpWidget(
          RepaintBoundary(
            key: boundary,
            child: ProviderScope(
              overrides: [
                dioProvider.overrideWithValue(dio),
                authProvider.overrideWith(_SignedOut.new),
              ],
              child: MaterialApp.router(
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
                routerConfig: _router(location, extra),
              ),
            ),
          ),
        );
        // Entrance animations finish well inside a second; the splash
        // screen is captured before its own redirect fires.
        final frames = name.contains('splash') ? 4 : 12;
        for (var i = 0; i < frames; i++) {
          await tester.pump(const Duration(milliseconds: 100));
        }

        await tester.runAsync(() async {
          final render = boundary.currentContext!.findRenderObject()!
              as RenderRepaintBoundary;
          final image = await render.toImage(pixelRatio: _pixelRatio);
          final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
          final dir = Directory('build/screenshots/auth/${locale.languageCode}')
            ..createSync(recursive: true);
          File('${dir.path}/${name}_$mode.png')
              .writeAsBytesSync(bytes!.buffer.asUint8List());
        });

        // Drain any timers the screen started (resend countdowns, splash).
        await tester.pumpWidget(const SizedBox());
        await tester.pump(const Duration(seconds: 10));
      });
    }
  }
}
