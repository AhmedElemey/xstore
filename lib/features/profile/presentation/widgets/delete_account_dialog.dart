import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/utils/extensions/context_extensions.dart';

/// Confirm-only dialog for accounts with `hasPassword: false`.
/// The caller sends `confirmationText` itself after this returns true.
class PasswordlessDeleteAccountDialog extends StatelessWidget {
  const PasswordlessDeleteAccountDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      icon: const Icon(
        LucideIcons.alertTriangle,
        color: AppColors.error,
        size: 40,
      ),
      title: Text(context.l10n.deleteAccountDialogTitle),
      content: Text(
        context.l10n.deleteAccountPermanentWarning,
        style: AppTypography.bodySmall,
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: Text(context.l10n.cancel),
        ),
        FilledButton(
          style: FilledButton.styleFrom(backgroundColor: AppColors.error),
          onPressed: () => Navigator.of(context).pop(true),
          child: Text(context.l10n.deleteMyAccount),
        ),
      ],
    );
  }
}

class DeleteAccountDialog extends StatefulWidget {
  const DeleteAccountDialog({super.key, required this.onConfirm});

  /// Shown when the account has a password. Backend body is
  /// `{password, confirmationText}`.
  final Future<void> Function(String password, String confirmationText)
  onConfirm;

  @override
  State<DeleteAccountDialog> createState() => _DeleteAccountDialogState();
}

class _DeleteAccountDialogState extends State<DeleteAccountDialog> {
  final _confirmController = TextEditingController();
  final _passwordController = TextEditingController();
  var _passwordVisible = false;

  @override
  void dispose() {
    _confirmController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ok =
        _confirmController.text.trim() == context.l10n.deleteConfirmKeyword &&
        _passwordController.text.isNotEmpty;
    return AlertDialog(
      icon: const Icon(
        LucideIcons.alertTriangle,
        color: AppColors.error,
        size: 40,
      ),
      title: Text(context.l10n.deleteAccountPermanentWarning),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            context.l10n.deleteAccountDialogTitle,
            style: AppTypography.bodySmall,
          ),
          const SizedBox(height: AppSpacing.lg),
          TextField(
            controller: _passwordController,
            obscureText: !_passwordVisible,
            decoration: InputDecoration(
              labelText: context.l10n.currentPasswordRequired,
              border: const OutlineInputBorder(),
              suffixIcon: IconButton(
                icon: Icon(
                  _passwordVisible ? LucideIcons.eyeOff : LucideIcons.eye,
                ),
                onPressed: () =>
                    setState(() => _passwordVisible = !_passwordVisible),
              ),
            ),
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: AppSpacing.md),
          TextField(
            controller: _confirmController,
            decoration: InputDecoration(
              labelText: context.l10n.deleteAccountTypeHint,
              border: const OutlineInputBorder(),
            ),
            onChanged: (_) => setState(() {}),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(context.l10n.cancel),
        ),
        FilledButton(
          style: FilledButton.styleFrom(backgroundColor: AppColors.error),
          onPressed: ok
              ? () async {
                  final password = _passwordController.text;
                  final confirmationText = _confirmController.text.trim();
                  Navigator.of(context).pop();
                  await widget.onConfirm(password, confirmationText);
                }
              : null,
          child: Text(context.l10n.deleteMyAccount),
        ),
      ],
    );
  }
}
