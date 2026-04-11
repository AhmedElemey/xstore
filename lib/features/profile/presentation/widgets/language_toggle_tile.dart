import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/localization/localization_provider.dart';
import '../../../../core/utils/extensions/context_extensions.dart';
import 'profile_switch_tile.dart';

class LanguageToggleTile extends ConsumerWidget {
  const LanguageToggleTile({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = ref.watch(appLocaleProvider);
    final isArabic = locale == AppLanguage.arabic;

    return ProfileSwitchTile(
      icon: LucideIcons.languages,
      iconBackground: AppColors.primary,
      label: '${context.l10n.languageToggleTitle} (${isArabic ? 'العربية' : 'English'})',
      value: isArabic,
      onChanged: (_) => ref.read(appLocaleProvider.notifier).toggleLanguage(),
    );
  }
}
