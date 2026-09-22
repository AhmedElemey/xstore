import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/utils/extensions/context_extensions.dart';
import '../../../reports/domain/entities/vendor_report_reason.dart';

String _reasonLabel(BuildContext context, VendorReportReason reason) =>
    switch (reason) {
      VendorReportReason.fraud => context.l10n.reportVendorReasonFraud,
      VendorReportReason.poorProductQuality =>
        context.l10n.reportVendorReasonPoorQuality,
      VendorReportReason.itemNotAsDescribed =>
        context.l10n.reportVendorReasonNotAsDescribed,
      VendorReportReason.noResponseFromSeller =>
        context.l10n.reportVendorReasonNoResponse,
      VendorReportReason.harassment =>
        context.l10n.reportVendorReasonHarassment,
      VendorReportReason.other => context.l10n.reportVendorReasonOther,
    };

/// Bottom sheet: lets a consumer report the vendor of a placed order.
class ReportVendorSheet extends StatefulWidget {
  const ReportVendorSheet({
    super.key,
    required this.vendorName,
    required this.onSubmit,
  });

  final String vendorName;

  /// Returns true on success. The sheet pops itself only on success; on
  /// failure it stays open with an inline error so the selected reason and
  /// typed comment aren't lost.
  final Future<bool> Function(VendorReportReason reason, String? comment)
  onSubmit;

  @override
  State<ReportVendorSheet> createState() => _ReportVendorSheetState();
}

class _ReportVendorSheetState extends State<ReportVendorSheet> {
  late final TextEditingController _comment;
  VendorReportReason? _reason;
  String? _error;
  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    _comment = TextEditingController();
  }

  @override
  void dispose() {
    _comment.dispose();
    super.dispose();
  }

  bool get _requiresComment => _reason == VendorReportReason.other;

  bool get _canSubmit =>
      _reason != null && (!_requiresComment || _comment.text.trim().isNotEmpty);

  Future<void> _submit() async {
    final reason = _reason;
    if (reason == null) return;
    final comment = _comment.text.trim();
    if (_requiresComment && comment.isEmpty) return;
    setState(() {
      _error = null;
      _submitting = true;
    });
    final ok = await widget.onSubmit(reason, comment.isEmpty ? null : comment);
    if (!mounted) return;
    if (!ok) {
      setState(() {
        _submitting = false;
        _error = context.l10n.errorGeneric;
      });
      return;
    }
    Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(
          left: AppSpacing.x2l,
          right: AppSpacing.x2l,
          top: AppSpacing.x2l,
          bottom: MediaQuery.viewInsetsOf(context).bottom + AppSpacing.x2l,
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                context.l10n.reportVendorTitle(widget.vendorName),
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const Gap(AppSpacing.xs),
              Text(
                context.l10n.reportVendorSubtitle,
                style: AppTypography.bodySmall.copyWith(
                  color: context.textSecondary,
                ),
              ),
              const Gap(AppSpacing.lg),
              for (final reason in VendorReportReason.values)
                RadioListTile<VendorReportReason>(
                  contentPadding: EdgeInsets.zero,
                  value: reason,
                  // ignore: deprecated_member_use
                  groupValue: _reason,
                  activeColor: AppColors.error,
                  // ignore: deprecated_member_use
                  onChanged: _submitting
                      ? null
                      : (v) => setState(() => _reason = v),
                  title: Text(_reasonLabel(context, reason)),
                ),
              const Gap(AppSpacing.md),
              TextField(
                controller: _comment,
                enabled: !_submitting,
                maxLines: 4,
                onChanged: (_) => setState(() {}),
                decoration: InputDecoration(
                  hintText: _requiresComment
                      ? context.l10n.reportVendorCommentHintRequired
                      : context.l10n.reportVendorCommentHintOptional,
                  border: const OutlineInputBorder(),
                ),
              ),
              if (_error != null) ...[
                const Gap(AppSpacing.sm),
                Text(
                  _error!,
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.error,
                  ),
                ),
              ],
              const Gap(AppSpacing.x2l),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.error,
                  ),
                  onPressed: (_submitting || !_canSubmit) ? null : _submit,
                  child: _submitting
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: AppColors.white,
                          ),
                        )
                      : Text(context.l10n.reportVendorSubmit),
                ),
              ),
              const Gap(AppSpacing.sm),
              SizedBox(
                width: double.infinity,
                child: TextButton(
                  onPressed: _submitting
                      ? null
                      : () => Navigator.of(context).pop(false),
                  child: Text(context.l10n.cancel),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
