import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/utils/extensions/context_extensions.dart';
import '../../../../core/utils/validators.dart';
import '../../../../shared/utils/compress_picked_image.dart';
import '../../../../shared/widgets/app_snackbar.dart';
import '../../../../shared/widgets/xstore_button.dart';
import '../../domain/entities/commission_payment_method.dart';
import '../providers/commission_payment_providers.dart';
import '../widgets/commission_payment_method_avatar.dart';

/// Step 2 of paying platform fees: shows where to send the money, then
/// collects the amount sent and the transfer receipt for admin review.
class CommissionPaymentReceiptScreen extends ConsumerStatefulWidget {
  const CommissionPaymentReceiptScreen({super.key, required this.method});

  final CommissionPaymentMethod method;

  @override
  ConsumerState<CommissionPaymentReceiptScreen> createState() =>
      _CommissionPaymentReceiptScreenState();
}

class _CommissionPaymentReceiptScreenState
    extends ConsumerState<CommissionPaymentReceiptScreen> {
  final _picker = ImagePicker();
  String _amountInput = '';
  String? _receiptPath;
  bool _submitting = false;

  double? get _amount {
    final value = Validators.parseMoneyInput(_amountInput.trim());
    return value != null && value > 0 ? value : null;
  }

  bool get _canSubmit => _amount != null && _receiptPath != null;

  Future<void> _pickReceipt(ImageSource source) async {
    final XFile? file;
    try {
      file = await _picker.pickImage(source: source);
    } on PlatformException {
      // Camera/photos permission denied or no camera on this device.
      if (mounted) AppSnackbar.error(context, context.l10n.errorGeneric);
      return;
    }
    if (file == null) return;
    final path = await compressPickedImage(file.path);
    if (!mounted) return;
    setState(() => _receiptPath = path);
  }

  Future<void> _submit() async {
    final amount = _amount;
    final receiptPath = _receiptPath;
    // Guard a second tap landing before the rebuild disables the button.
    if (_submitting || amount == null || receiptPath == null) return;

    final repository = ref.read(commissionPaymentRepositoryProvider);
    setState(() => _submitting = true);
    final result = await repository.submitPayment(
      method: widget.method,
      amountEgp: amount,
      receiptImagePath: receiptPath,
    );
    if (!mounted) return;
    result.fold(
      (failure) {
        // Stay on the form so the amount and receipt aren't lost.
        setState(() => _submitting = false);
        AppSnackbar.error(context, failure.message ?? context.l10n.errorGeneric);
      },
      (_) {
        AppSnackbar.success(context, context.l10n.commissionPaymentSubmitted);
        // The wallet is a shell tab: `go` (not pop) clears both payment
        // screens in one navigation.
        context.go(AppRoutes.vendorWallet);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final showAmountError = _amountInput.trim().isNotEmpty && _amount == null;

    return Scaffold(
      backgroundColor: context.backgroundColor,
      appBar: AppBar(
        backgroundColor: context.surfaceColor,
        elevation: 0,
        title: Text(context.l10n.commissionPaymentReceiptTitle),
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        children: [
          _PayToCard(method: widget.method),
          const Gap(AppSpacing.x2l),
          TextField(
            enabled: !_submitting,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            textInputAction: TextInputAction.done,
            onChanged: (value) => setState(() => _amountInput = value),
            decoration: InputDecoration(
              labelText: context.l10n.commissionPaymentAmountLabel,
              errorText: showAmountError
                  ? context.l10n.commissionPaymentAmountInvalid
                  : null,
              border: const OutlineInputBorder(),
            ),
          ),
          const Gap(AppSpacing.x2l),
          Text(
            context.l10n.commissionPaymentReceiptLabel,
            style: AppTypography.titleSmall.copyWith(
              color: context.textPrimary,
              fontWeight: FontWeight.w700,
            ),
          ),
          const Gap(AppSpacing.sm),
          if (_receiptPath == null)
            _ReceiptPicker(
              enabled: !_submitting,
              onPick: _pickReceipt,
            )
          else
            _ReceiptPreview(
              path: _receiptPath!,
              onRemove: _submitting
                  ? null
                  : () => setState(() => _receiptPath = null),
            ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: XstoreButton(
            label: context.l10n.commissionPaymentSubmit,
            isLoading: _submitting,
            onPressed: _canSubmit ? _submit : null,
          ),
        ),
      ),
    );
  }
}

/// Where to send the money for [method], read from the admin-managed
/// `commission_payment_accounts` setting.
class _PayToCard extends ConsumerWidget {
  const _PayToCard({required this.method});

  final CommissionPaymentMethod method;

  Future<void> _copy(BuildContext context, String account) async {
    await Clipboard.setData(ClipboardData(text: account));
    if (!context.mounted) return;
    AppSnackbar.info(context, context.l10n.commissionPaymentCopied);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final accounts = ref.watch(commissionPayToAccountsProvider);
    final label = commissionPaymentMethodLabel(context, method);

    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: context.surfaceColor,
        borderRadius: BorderRadius.circular(AppSpacing.lg),
        border: Border.all(color: context.borderColor),
      ),
      child: Row(
        children: [
          CommissionPaymentMethodAvatar(method: method),
          const Gap(AppSpacing.md),
          Expanded(
            child: accounts.when(
              loading: () => const LinearProgressIndicator(),
              error: (_, __) => _NoAccountText(label: label),
              data: (map) {
                final account = map[method];
                if (account == null) return _NoAccountText(label: label);
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      context.l10n.commissionPaymentSendTo,
                      style: AppTypography.bodySmall.copyWith(
                        color: context.textSecondary,
                      ),
                    ),
                    const Gap(2),
                    SelectableText(
                      account,
                      style: AppTypography.titleMedium.copyWith(
                        color: context.textPrimary,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
          if (accounts.valueOrNull?[method] case final account?)
            IconButton(
              tooltip: context.l10n.commissionPaymentCopied,
              icon: const Icon(LucideIcons.copy, size: 20),
              onPressed: () => _copy(context, account),
            ),
        ],
      ),
    );
  }
}

class _NoAccountText extends StatelessWidget {
  const _NoAccountText({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Text(
      context.l10n.commissionPaymentNoAccount(label),
      style: AppTypography.bodySmall.copyWith(
        color: AppColors.warning,
        height: 1.35,
      ),
    );
  }
}

class _ReceiptPicker extends StatelessWidget {
  const _ReceiptPicker({required this.enabled, required this.onPick});

  final bool enabled;
  final ValueChanged<ImageSource> onPick;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: context.surfaceColor,
        borderRadius: BorderRadius.circular(AppSpacing.lg),
        border: Border.all(color: context.borderColor),
      ),
      child: Column(
        children: [
          Icon(LucideIcons.receipt, size: 32, color: context.textSecondary),
          const Gap(AppSpacing.sm),
          Text(
            context.l10n.commissionPaymentReceiptHint,
            textAlign: TextAlign.center,
            style: AppTypography.bodySmall.copyWith(
              color: context.textSecondary,
            ),
          ),
          const Gap(AppSpacing.md),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: enabled ? () => onPick(ImageSource.camera) : null,
                  icon: const Icon(LucideIcons.camera, size: 18),
                  label: Text(context.l10n.takePhoto),
                ),
              ),
              const Gap(AppSpacing.md),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: enabled ? () => onPick(ImageSource.gallery) : null,
                  icon: const Icon(LucideIcons.image, size: 18),
                  label: Text(context.l10n.chooseFromGallery),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ReceiptPreview extends StatelessWidget {
  const _ReceiptPreview({required this.path, required this.onRemove});

  final String path;
  final VoidCallback? onRemove;

  @override
  Widget build(BuildContext context) {
    // Decode at display size, not the photo's full resolution.
    final cacheWidth =
        (MediaQuery.sizeOf(context).width *
                MediaQuery.devicePixelRatioOf(context))
            .round();
    return Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(AppSpacing.lg),
          child: Container(
            height: 280,
            width: double.infinity,
            color: context.surfaceVariantColor,
            child: Image.file(
              File(path),
              fit: BoxFit.contain,
              cacheWidth: cacheWidth,
            ),
          ),
        ),
        PositionedDirectional(
          top: AppSpacing.sm,
          end: AppSpacing.sm,
          child: IconButton.filledTonal(
            tooltip: context.l10n.commissionPaymentRemoveReceipt,
            onPressed: onRemove,
            icon: const Icon(LucideIcons.x, size: 18),
          ),
        ),
      ],
    );
  }
}
