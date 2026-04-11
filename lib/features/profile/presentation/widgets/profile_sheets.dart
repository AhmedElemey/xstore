import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/utils/extensions/context_extensions.dart';
import '../providers/profile_provider.dart';

Future<void> showProfileAvatarPickerSheet({
  required BuildContext context,
  required WidgetRef ref,
}) {
  return showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    builder: (ctx) => SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(LucideIcons.camera),
            title: Text(context.l10n.takePhoto),
            onTap: () async {
              Navigator.pop(ctx);
              final picked = await ref
                  .read(profileNotifierProvider.notifier)
                  .pickAvatar(ImageSource.camera);
              if (picked) {
                await ref.read(profileNotifierProvider.notifier).saveProfile();
              }
            },
          ),
          ListTile(
            leading: const Icon(LucideIcons.image),
            title: Text(context.l10n.chooseFromGallery),
            onTap: () async {
              Navigator.pop(ctx);
              final picked = await ref
                  .read(profileNotifierProvider.notifier)
                  .pickAvatar(ImageSource.gallery);
              if (picked) {
                await ref.read(profileNotifierProvider.notifier).saveProfile();
              }
            },
          ),
        ],
      ),
    ),
  );
}

Future<void> showProfileLogoutSheet({
  required BuildContext context,
  required WidgetRef ref,
}) {
  return showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    builder: (ctx) => Padding(
      padding: const EdgeInsets.all(AppSpacing.x2l),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(context.l10n.logoutConfirmTitle, style: AppTypography.titleMedium),
          const SizedBox(height: AppSpacing.x2l),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: Text(context.l10n.cancel),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: FilledButton(
                  onPressed: () async {
                    Navigator.pop(ctx);
                    await ref.read(profileNotifierProvider.notifier).logout();
                  },
                  child: Text(context.l10n.logOut),
                ),
              ),
            ],
          ),
        ],
      ),
    ),
  );
}
