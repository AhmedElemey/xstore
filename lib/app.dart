import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/localization/app_localizations.dart';
import 'core/localization/localization_provider.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'shared/providers/shared_providers.dart';
import 'shared/widgets/offline_banner.dart';

class XstoreApp extends ConsumerWidget {
  const XstoreApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(goRouterProvider);
    final currentThemeMode = ref.watch(appThemeModeProvider);
    final language = ref.watch(appLocaleProvider);
    final locale = ref.read(appLocaleProvider.notifier).locale;
    final useArabicFont = language == AppLanguage.arabic;

    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'xStore',
      builder: (context, child) {
        final scaler = MediaQuery.textScalerOf(context);
        return Theme(
          data: AppTheme.withScaledTextSpacing(Theme.of(context), scaler),
          child: OfflineBannerHost(
            child: child ?? const SizedBox.shrink(),
          ),
        );
      },
      theme: AppTheme.light.copyWith(
        textTheme: useArabicFont
            ? AppTheme.light.textTheme.apply(fontFamily: 'Cairo')
            : AppTheme.light.textTheme,
      ),
      darkTheme: AppTheme.dark.copyWith(
        textTheme: useArabicFont
            ? AppTheme.dark.textTheme.apply(fontFamily: 'Cairo')
            : AppTheme.dark.textTheme,
      ),
      themeMode: currentThemeMode,
      locale: locale,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      routerConfig: router,
    );
  }
}
