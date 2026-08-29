import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'features/notifications/presentation/providers/fcm_push_handling_provider.dart';
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
    ref.watch(fcmPushHandlingProvider);
    final router = ref.watch(goRouterProvider);
    final currentThemeMode = ref.watch(appThemeModeProvider);
    final language = ref.watch(appLocaleProvider);
    final locale = ref.read(appLocaleProvider.notifier).locale;
    final useArabicFont = language == AppLanguage.arabic;

    return MaterialApp.router(
      // Role-changing login replaces [GoRouter]. Remount so the old
      // navigator GlobalKeys deactivate before the new shell inflates.
      key: ObjectKey(router),
      debugShowCheckedModeBanner: false,
      title: 'xStore',
      builder: (context, child) {
        final media = MediaQuery.of(context);
        return MediaQuery(
          // iOS SystemContextMenu.build asserts an active TextInputConnection
          // (readOnly fields, SelectableText, parent rebuilds). Flutter-drawn
          // AdaptiveTextSelectionToolbar does not. See Flutter #170521.
          data: media.copyWith(supportsShowingSystemContextMenu: false),
          child: Theme(
            data: AppTheme.withScaledTextSpacing(
              Theme.of(context),
              media.textScaler,
            ),
            child: OfflineBannerHost(
              child: child ?? const SizedBox.shrink(),
            ),
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
