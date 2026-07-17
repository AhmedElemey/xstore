import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/utils/extensions/context_extensions.dart';

/// Bottom sheet asking the courier why a drop-off failed. The reason is
/// required — it feeds the order's cancel reason, which the vendor and the
/// owner both see.
class DeliveryFailSheet extends StatefulWidget {
  const DeliveryFailSheet({super.key, required this.onConfirm});

  final Future<void> Function(String reason) onConfirm;

  @override
  State<DeliveryFailSheet> createState() => _DeliveryFailSheetState();
}

class _DeliveryFailSheetState extends State<DeliveryFailSheet> {
  final _reasonCtrl = TextEditingController();
  var _loading = false;

  @override
  void dispose() {
    _reasonCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final canSubmit = _reasonCtrl.text.trim().isNotEmpty;
    return SafeArea(
      child: SingleChildScrollView(
        padding: EdgeInsets.only(
          left: AppSpacing.lg,
          right: AppSpacing.lg,
          top: AppSpacing.lg,
          bottom: AppSpacing.lg + MediaQuery.viewInsetsOf(context).bottom,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              context.l10n.courierFailReasonTitle,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: AppSpacing.md),
            TextField(
              controller: _reasonCtrl,
              enabled: !_loading,
              onChanged: (_) => setState(() {}),
              maxLines: 2,
              decoration: InputDecoration(
                hintText: context.l10n.courierFailReasonHint,
                helperText:
                    canSubmit ? null : context.l10n.courierFailReasonRequired,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: _loading ? null : () => Navigator.pop(context),
                    child: Text(context.l10n.cancel),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: FilledButton(
                    onPressed: !canSubmit || _loading
                        ? null
                        : () async {
                            final navigator = Navigator.of(context);
                            setState(() => _loading = true);
                            await widget.onConfirm(_reasonCtrl.text.trim());
                            if (!mounted) return;
                            navigator.pop();
                          },
                    style:
                        FilledButton.styleFrom(backgroundColor: AppColors.error),
                    child: _loading
                        ? SizedBox(
                            width: AppSpacing.lg,
                            height: AppSpacing.lg,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: context.surfaceColor,
                            ),
                          )
                        : Text(context.l10n.courierFailAction),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
