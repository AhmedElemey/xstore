import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/utils/extensions/context_extensions.dart';

class DeleteAccountDialog extends StatefulWidget {
  const DeleteAccountDialog({super.key, required this.onConfirm});

  final Future<void> Function() onConfirm;

  @override
  State<DeleteAccountDialog> createState() => _DeleteAccountDialogState();
}

class _DeleteAccountDialogState extends State<DeleteAccountDialog> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ok = _controller.text.trim() == context.l10n.deleteConfirmKeyword;
    return AlertDialog(
      icon: const Icon(LucideIcons.alertTriangle, color: AppColors.error, size: 40),
      title: Text(context.l10n.deleteAccountPermanentWarning),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(context.l10n.deleteAccountDialogTitle, style: AppTypography.bodySmall),
          const SizedBox(height: AppSpacing.lg),
          TextField(
            controller: _controller,
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
                  Navigator.of(context).pop();
                  await widget.onConfirm();
                }
              : null,
          child: Text(context.l10n.deleteMyAccount),
        ),
      ],
    );
  }
}
