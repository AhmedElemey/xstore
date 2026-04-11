import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/extensions/context_extensions.dart';
import '../../../../shared/providers/shared_providers.dart';
import 'profile_switch_tile.dart';

class ThemeToggleTile extends ConsumerWidget {
  const ThemeToggleTile({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(appThemeModeProvider);
    final isDark = themeMode == ThemeMode.dark;

    return ProfileSwitchTile(
      icon: isDark ? LucideIcons.moon : LucideIcons.sun,
      iconBackground: AppColors.primary,
      label: isDark ? context.l10n.darkMode : context.l10n.lightMode,
      value: isDark,
      onChanged: (_) =>
          ref.read(appThemeModeProvider.notifier).toggleDarkMode(),
    );
  }
}
