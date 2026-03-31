import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/utils/extensions/context_extensions.dart';

class RejectOrderSheet extends StatefulWidget {
  const RejectOrderSheet({super.key, required this.onConfirm});

  final Future<void> Function(String reason) onConfirm;

  @override
  State<RejectOrderSheet> createState() => _RejectOrderSheetState();
}

class _RejectOrderSheetState extends State<RejectOrderSheet> {
  static const _reasons = <String>[
    AppStrings.vendorReasonItemUnavailable,
    AppStrings.vendorReasonOutOfStock,
    AppStrings.vendorReasonCannotDeliver,
    AppStrings.vendorReasonSuspicious,
    AppStrings.vendorReasonIncorrectPricing,
    AppStrings.vendorReasonOther,
  ];
  String? _selected;
  final _otherCtrl = TextEditingController();
  var _loading = false;

  @override
  void dispose() {
    _otherCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final canSubmit = _selected != null &&
        (_selected != AppStrings.vendorReasonOther || _otherCtrl.text.trim().isNotEmpty);
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(AppStrings.vendorRejectTitle, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: AppSpacing.sm),
            ..._reasons.map(
              (r) => RadioListTile<String>(
                // ignore: deprecated_member_use
                value: r,
                // ignore: deprecated_member_use
                groupValue: _selected,
                contentPadding: EdgeInsets.zero,
                title: Text(r),
                // ignore: deprecated_member_use
                onChanged: _loading ? null : (v) => setState(() => _selected = v),
              ),
            ),
            if (_selected == AppStrings.vendorReasonOther)
              TextField(
                controller: _otherCtrl,
                onChanged: (_) => setState(() {}),
                decoration: const InputDecoration(hintText: AppStrings.vendorTypeReasonHint),
              ),
            const SizedBox(height: AppSpacing.md),
            Text(
              AppStrings.vendorRejectWarning,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.warning,
                  ),
            ),
            const SizedBox(height: AppSpacing.md),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: _loading ? null : () => Navigator.pop(context),
                    child: Text(AppStrings.cancel),
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
                            final reason = _selected == AppStrings.vendorReasonOther
                                ? _otherCtrl.text.trim()
                                : _selected!;
                            await widget.onConfirm(reason);
                            if (!mounted) return;
                            navigator.pop();
                          },
                    style: FilledButton.styleFrom(backgroundColor: AppColors.error),
                    child: _loading
                        ? SizedBox(
                            width: AppSpacing.lg,
                            height: AppSpacing.lg,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: context.surfaceColor,
                            ),
                          )
                        : Text(AppStrings.vendorConfirmRejection),
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
