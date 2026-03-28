import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../shared/providers/shared_providers.dart';
import '../providers/profile_provider.dart';
import 'profile_menu_tile.dart';

bool _isDarkModeActive(ThemeMode mode, Brightness platform) {
  if (mode == ThemeMode.dark) return true;
  if (mode == ThemeMode.light) return false;
  return platform == Brightness.dark;
}

class ThemeToggleTile extends ConsumerWidget {
  const ThemeToggleTile({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final platformBrightness = theme.brightness;
    final mode = ref.watch(appThemeModeProvider);
    final on = _isDarkModeActive(mode, platformBrightness);

    return ProfileMenuTile(
      icon: LucideIcons.moon,
      iconBackground: AppColors.primary,
      label: AppStrings.menuDarkMode,
      showChevron: false,
      trailing: Switch.adaptive(
        value: on,
        activeTrackColor: AppColors.primary.withValues(alpha: 0.35),
        activeThumbColor: AppColors.primary,
        onChanged: (v) {
          ref.read(profileNotifierProvider.notifier).toggleDarkMode(v);
        },
      ),
    );
  }
}
