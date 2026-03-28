import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../shared/providers/shared_providers.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authProvider);
    final themeMode = ref.watch(appThemeModeProvider);

    return Scaffold(
      appBar: AppBar(title: const Text(AppStrings.profileTitle)),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        children: [
          auth.when(
            data: (user) {
              if (user == null) {
                return const SizedBox.shrink();
              }
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    user.name.isNotEmpty ? user.name : user.email,
                    style: AppTypography.titleMedium,
                  ),
                  if (user.name.isNotEmpty) ...[
                    const Gap(AppSpacing.xs),
                    Text(
                      user.email,
                      style: AppTypography.bodySmall,
                    ),
                  ],
                  const Gap(AppSpacing.sm),
                  Text(
                    user.isVendor ? AppStrings.vendorAccount : AppStrings.customerAccount,
                    style: AppTypography.bodySmall,
                  ),
                ],
              );
            },
            loading: () => const LinearProgressIndicator(minHeight: AppSpacing.sm),
            error: (e, _) => Text(
              e.toString(),
              style: AppTypography.bodyMedium.copyWith(color: AppColors.error),
            ),
          ),
          const Gap(AppSpacing.x2l),
          Text(AppStrings.theme, style: AppTypography.titleMedium),
          const Gap(AppSpacing.md),
          SegmentedButton<ThemeMode>(
            segments: const [
              ButtonSegment(value: ThemeMode.system, label: Text(AppStrings.themeSystem)),
              ButtonSegment(value: ThemeMode.light, label: Text(AppStrings.themeLight)),
              ButtonSegment(value: ThemeMode.dark, label: Text(AppStrings.themeDark)),
            ],
            selected: {themeMode},
            onSelectionChanged: (selection) async {
              await ref.read(appThemeModeProvider.notifier).setTheme(selection.first);
            },
          ),
          const Gap(AppSpacing.x2l),
          FilledButton(
            onPressed: () async {
              await ref.read(authProvider.notifier).logout();
            },
            child: const Text(AppStrings.logout),
          ),
        ],
      ),
    );
  }
}
