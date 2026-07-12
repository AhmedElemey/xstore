import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/network/app_error_messages.dart';
import '../../../../core/utils/extensions/context_extensions.dart';
import '../../../../shared/widgets/app_snackbar.dart';
import '../providers/profile_provider.dart';

Future<void> _saveAvatarAfterPick({
  required BuildContext context,
  required WidgetRef ref,
  required ImageSource source,
}) async {
  final picked = await ref
      .read(profileNotifierProvider.notifier)
      .pickAvatar(source);
  if (!picked) return;

  try {
    await ref.read(profileNotifierProvider.notifier).saveProfile();
    if (!context.mounted) return;
    final err = ref.read(profileNotifierProvider).error;
    if (err != null) {
      AppSnackbar.error(context, resolveAppError(context, err));
      return;
    }
    AppSnackbar.success(context, context.l10n.profileUpdatedSuccess);
  } catch (_) {
    if (context.mounted) {
      AppSnackbar.error(context, context.l10n.errorGeneric);
    }
  }
}

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
              await _saveAvatarAfterPick(
                context: context,
                ref: ref,
                source: ImageSource.camera,
              );
            },
          ),
          ListTile(
            leading: const Icon(LucideIcons.image),
            title: Text(context.l10n.chooseFromGallery),
            onTap: () async {
              Navigator.pop(ctx);
              await _saveAvatarAfterPick(
                context: context,
                ref: ref,
                source: ImageSource.gallery,
              );
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
