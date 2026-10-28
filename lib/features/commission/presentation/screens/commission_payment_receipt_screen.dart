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
import '../../../auth/presentation/widgets/auth_text_field.dart';
import '../../../../shared/widgets/xstore_button.dart';
import '../../../../shared/widgets/orbit_background.dart';
import '../../domain/entities/commission_payment_method.dart';
import '../../../general_settings/presentation/providers/general_settings_provider.dart';
import '../providers/commission_config_provider.dart';
import '../providers/commission_payment_providers.dart';
import '../widgets/commission_page_header.dart';
import '../providers/vendor_commission_wallet_provider.dart';
import '../widgets/commission_payment_method_avatar.dart';

/// Receipt formats the backend accepts (Postman collection v10); the size
/// cap is the one proposed in the commission payment handoff doc.
const _kReceiptExtensions = {'jpg', 'jpeg', 'png', 'webp'};
const _kReceiptMaxBytes = 5 * 1024 * 1024;

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
  // True when [_receiptPath] is the `-compressed.jpg` copy we created (safe
  // to delete), false when compression fell back to the picker's original.
  bool _receiptIsOurCopy = false;
  bool _picking = false;
  bool _submitting = false;

  double? get _amount {
    final value = Validators.parseMoneyInput(_amountInput.trim());
    return value != null && value > 0 ? value : null;
  }

  bool get _hasAmountAndReceipt => _amount != null && _receiptPath != null;

  /// Best-effort delete of the compressed copy; never touches the picker's
  /// original file.
  void _discardReceiptCopy() {
    final path = _receiptPath;
    if (path == null || !_receiptIsOurCopy) return;
    try {
      File(path).deleteSync();
    } catch (_) {}
  }

  bool _isAcceptedReceipt(String path) {
    final dot = path.lastIndexOf('.');
    if (dot < 0 ||
        !_kReceiptExtensions.contains(path.substring(dot + 1).toLowerCase())) {
      return false;
    }
    try {
      return File(path).lengthSync() <= _kReceiptMaxBytes;
    } on FileSystemException {
      return false;
    }
  }

  Future<void> _pickReceipt(ImageSource source) async {
    // A second tap while the picker/compression is still running.
    if (_picking) return;
    _picking = true;
    try {
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
      final isOurCopy = path != file.path;
      if (!_isAcceptedReceipt(path)) {
        // Compression fell back to e.g. a HEIC/GIF original, or the photo is
        // over the size limit.
        if (isOurCopy) {
          try {
            File(path).deleteSync();
          } catch (_) {}
        }
        if (mounted) {
          AppSnackbar.error(
            context,
            context.l10n.commissionPaymentReceiptInvalid,
          );
        }
        return;
      }
      if (!mounted) return;
      _discardReceiptCopy();
      setState(() {
        _receiptPath = path;
        _receiptIsOurCopy = isOurCopy;
      });
    } finally {
      _picking = false;
    }
  }

  Future<void> _submit() async {
    final amount = _amount;
    final receiptPath = _receiptPath;
    // Guard a second tap landing before the rebuild disables the button.
    if (_submitting || amount == null || receiptPath == null) return;

    // The picker cache can be evicted between picking and submitting.
    if (!File(receiptPath).existsSync()) {
      setState(() => _receiptPath = null);
      AppSnackbar.error(
        context,
        context.l10n.commissionPaymentReceiptUnavailable,
      );
      return;
    }

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
        AppSnackbar.error(
          context,
          failure.message ?? context.l10n.errorGeneric,
        );
      },
      (_) {
        _discardReceiptCopy();
        // The wallet banner reads these; refetch so the new payment shows.
        ref
          ..invalidate(vendorCommissionSnapshotProvider)
          ..invalidate(vendorCommissionWalletProvider);
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
    // Never let a vendor submit a payment without knowing where to send it.
    final hasPayToAccount = ref.watch(
      commissionPayToAccountsProvider.select(
        (accounts) => accounts.valueOrNull?[widget.method] != null,
      ),
    );

    return PopScope(
      canPop: !_submitting,
      child: Scaffold(
        backgroundColor: context.backgroundColor,
        body: OrbitBackground(
          child: SafeArea(
            bottom: false,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                CommissionPageHeader(
                  title: context.l10n.commissionPaymentReceiptTitle,
                ),
                Expanded(
                  child: ListView(
                    padding: const EdgeInsetsDirectional.fromSTEB(
                      AppSpacing.xl,
                      0,
                      AppSpacing.xl,
                      AppSpacing.x2l,
                    ),
                    children: [
                      _PayToCard(method: widget.method),
                      const Gap(AppSpacing.x2l),
                      AuthTextField(
                        label: context.l10n.commissionPaymentAmountLabel,
                        readOnly: _submitting,
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        textInputAction: TextInputAction.done,
                        onChanged: (value) =>
                            setState(() => _amountInput = value),
                        errorText: showAmountError
                            ? context.l10n.commissionPaymentAmountInvalid
                            : null,
                      ),
                      const Gap(AppSpacing.x2l),
                      Text(
                        context.l10n.commissionPaymentReceiptLabel
                            .toUpperCase(),
                        style: AppTypography.fieldLabel.copyWith(
                          color: context.labelColor,
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
                              : () {
                                  _discardReceiptCopy();
                                  setState(() => _receiptPath = null);
                                },
                        ),
                    ],
                  ),
                ),
                // Sticky footer, same chrome as the cart's checkout bar.
                DecoratedBox(
                  decoration: BoxDecoration(
                    color: context.backgroundColor.withValues(alpha: 0.96),
                    border: Border(top: BorderSide(color: context.borderColor)),
                  ),
                  child: SafeArea(
                    top: false,
                    child: Padding(
                      padding: const EdgeInsets.all(AppSpacing.lg),
                      child: XstoreButton(
                        label: context.l10n.commissionPaymentSubmit,
                        isLoading: _submitting,
                        onPressed: _hasAmountAndReceipt && hasPayToAccount
                            ? _submit
                            : null,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Where to send the money for [method], read from the admin-managed
/// per-method `*_handle` General Settings.
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
        color: context.glassColor,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: context.borderColor),
      ),
      child: Row(
        children: [
          CommissionPaymentMethodAvatar(method: method),
          const Gap(AppSpacing.md),
          Expanded(
            child: accounts.when(
              loading: () => const LinearProgressIndicator(),
              error: (_, __) => Row(
                children: [
                  Expanded(
                    child: Text(
                      context.l10n.errorGeneric,
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.error,
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: () => ref.invalidate(generalSettingsProvider),
                    child: Text(context.l10n.retry),
                  ),
                ],
              ),
              data: (map) {
                final account = map[method];
                if (account == null) return _NoAccountText(label: label);
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      context.l10n.commissionPaymentSendTo,
                      style: AppTypography.bodySmall.copyWith(
                        color: context.labelColor,
                      ),
                    ),
                    const Gap(2),
                    SelectableText(
                      account,
                      style: AppTypography.mono.copyWith(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: context.textPrimary,
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
        color: context.glassColor,
        borderRadius: BorderRadius.circular(22),
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
          borderRadius: BorderRadius.circular(22),
          child: Image.file(
            File(path),
            // fit: BoxFit.contain,
            cacheWidth: cacheWidth,
            // The cache file can be evicted while the screen is open.
            errorBuilder: (_, __, ___) => Icon(
              Icons.broken_image_outlined,
              size: 48,
              color: context.textSecondary,
            ),
          ),
        ),
        PositionedDirectional(
          top: AppSpacing.sm,
          end: AppSpacing.sm,
          
          child: Container(
            width: AppSpacing.x3l,
            height: AppSpacing.x3l,
            decoration: BoxDecoration(
              color: Colors.red,
              shape: BoxShape.circle
            ),
            child: IconButton(
              tooltip: context.l10n.commissionPaymentRemoveReceipt,
              onPressed: onRemove,

              icon: const Icon(LucideIcons.x, size: 16,color: Colors.white,),
            ),
          ),
        ),
      ],
    );
  }
}
