import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/router/app_routes.dart';
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
        padding: const EdgeInsets.all(AppSpacing.md),
        children: [
          auth.when(
            data: (user) {
              if (user == null) {
                return const SizedBox.shrink();
              }
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(user.email, style: Theme.of(context).textTheme.titleMedium),
                  const Gap(AppSpacing.xs),
                  Text(
                    user.isVendor ? 'Vendor account' : 'Customer account',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  if (user.isVendor) ...[
                    const Gap(AppSpacing.md),
                    FilledButton.tonalIcon(
                      onPressed: () => context.push(AppRoutes.listingAdd),
                      icon: const Icon(Icons.add),
                      label: const Text('Add listing'),
                    ),
                    const Gap(AppSpacing.sm),
                    OutlinedButton.icon(
                      onPressed: () => context.push(AppRoutes.listingMy),
                      icon: const Icon(Icons.list_alt),
                      label: const Text('My listings'),
                    ),
                  ],
                ],
              );
            },
            loading: () => const LinearProgressIndicator(),
            error: (e, _) => Text(e.toString()),
          ),
          const Gap(AppSpacing.lg),
          Text('Theme', style: Theme.of(context).textTheme.titleSmall),
          const Gap(AppSpacing.sm),
          SegmentedButton<ThemeMode>(
            segments: const [
              ButtonSegment(value: ThemeMode.system, label: Text('System')),
              ButtonSegment(value: ThemeMode.light, label: Text('Light')),
              ButtonSegment(value: ThemeMode.dark, label: Text('Dark')),
            ],
            selected: {themeMode},
            onSelectionChanged: (selection) async {
              await ref
                  .read(appThemeModeProvider.notifier)
                  .setTheme(selection.first);
            },
          ),
          const Gap(AppSpacing.lg),
          FilledButton(
            onPressed: () async {
              await ref.read(authProvider.notifier).logout();
            },
            child: const Text('Sign out'),
          ),
        ],
      ),
    );
  }
}
