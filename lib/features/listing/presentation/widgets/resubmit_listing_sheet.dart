import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/utils/extensions/context_extensions.dart';
import '../../../../core/utils/validators.dart';
import '../../domain/entities/listing_entity.dart';

/// Bottom sheet: shows why a listing was rejected and lets the vendor
/// resubmit it with a corrected price.
class ResubmitListingSheet extends StatefulWidget {
  const ResubmitListingSheet({
    super.key,
    required this.listing,
    required this.onSubmit,
  });

  final ListingEntity listing;

  /// Returns true on success. The sheet pops itself only on success (the
  /// caller then shows a toast); on failure it stays open with an inline
  /// error so the vendor doesn't lose the price they typed.
  final Future<bool> Function(double newPrice) onSubmit;

  @override
  State<ResubmitListingSheet> createState() => _ResubmitListingSheetState();
}

class _ResubmitListingSheetState extends State<ResubmitListingSheet> {
  late final TextEditingController _price;
  String? _error;
  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    _price = TextEditingController(
      text: widget.listing.price.toStringAsFixed(2),
    );
  }

  @override
  void dispose() {
    _price.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final price = Validators.parseMoneyInput(_price.text);
    if (price == null || price <= 0) {
      setState(() => _error = context.l10n.resubmitInvalidPrice);
      return;
    }
    setState(() {
      _error = null;
      _submitting = true;
    });
    final ok = await widget.onSubmit(price);
    if (!mounted) return;
    if (!ok) {
      // Stay open on failure — the vendor's typed price and the visible
      // rejection reason shouldn't be lost; let them retry inline instead
      // of reopening the sheet from scratch.
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
    final reason = widget.listing.rejectionReason;
    final hasReason = reason != null && reason.trim().isNotEmpty;
    final theme = Theme.of(context);

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(
          left: AppSpacing.x2l,
          right: AppSpacing.x2l,
          top: AppSpacing.x2l,
          bottom: MediaQuery.of(context).viewInsets.bottom + AppSpacing.x2l,
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                context.l10n.resubmitListingTitle,
                style: theme.textTheme.titleLarge
                    ?.copyWith(fontWeight: FontWeight.w700),
              ),
              const Gap(AppSpacing.lg),
              Text(
                context.l10n.rejectionReasonLabel,
                style: theme.textTheme.labelMedium
                    ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
              ),
              const Gap(AppSpacing.xs),
              Text(
                hasReason ? reason : context.l10n.rejectionReasonUnavailable,
                style: theme.textTheme.bodyMedium,
              ),
              const Gap(AppSpacing.x2l),
              Text(
                context.l10n.resubmitPriceLabel,
                style: theme.textTheme.labelMedium
                    ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
              ),
              const Gap(AppSpacing.xs),
              TextField(
                controller: _price,
                enabled: !_submitting,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(
                  errorText: _error,
                  border: const OutlineInputBorder(),
                ),
              ),
              const Gap(AppSpacing.x2l),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: _submitting ? null : _submit,
                  child: _submitting
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: AppColors.white,
                          ),
                        )
                      : Text(context.l10n.resubmitSubmit),
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
