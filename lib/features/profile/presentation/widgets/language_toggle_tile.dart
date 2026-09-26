import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/localization/localization_provider.dart';
import '../../../../core/utils/extensions/context_extensions.dart';
import 'profile_menu_tile.dart';

/// "Language — English": tapping switches between English and Arabic.
class LanguageToggleTile extends ConsumerWidget {
  const LanguageToggleTile({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isArabic = ref.watch(appLocaleProvider) == AppLanguage.arabic;
    return ProfileMenuTile(
      icon: LucideIcons.languages,
      iconColor: AppColors.nova,
      label: context.l10n.languageToggleTitle,
      // Each language's own name, so either reader can find theirs.
      value: isArabic ? 'العربية' : 'English',
      onTap: () => ref.read(appLocaleProvider.notifier).toggleLanguage(),
    );
  }
}
