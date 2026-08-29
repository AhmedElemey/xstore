import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/network/app_error_messages.dart';
import '../../../../core/utils/extensions/context_extensions.dart';
import '../../../../shared/widgets/app_snackbar.dart';
import '../providers/auth_provider.dart';

/// Verifies the signed-in user's phone number via the backend OTP flow
/// (`send-phone-otp` / `verify-phone`) — distinct from passwordless login
/// (`send-login-otp` / `login-with-otp`). Used where an action requires
/// phone verification the user hasn't completed yet (e.g. placing an order).
///
/// Returns true if the phone was successfully verified, false otherwise.
Future<bool> verifyPhoneNow(
  BuildContext context,
  WidgetRef ref,
  String phoneNumber,
) async {
  final result = await showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    backgroundColor: context.surfaceColor,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(AppSpacing.lg)),
    ),
    builder: (_) => _PhoneVerificationSheet(phoneNumber: phoneNumber),
  );
  return result ?? false;
}

class _PhoneVerificationSheet extends ConsumerStatefulWidget {
  const _PhoneVerificationSheet({required this.phoneNumber});

  final String phoneNumber;

  @override
  ConsumerState<_PhoneVerificationSheet> createState() =>
      _PhoneVerificationSheetState();
}

class _PhoneVerificationSheetState
    extends ConsumerState<_PhoneVerificationSheet> {
  final _otpController = TextEditingController();
  bool _codeSent = false;
  bool _isSending = false;
  bool _isVerifying = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _sendCode();
  }

  @override
  void dispose() {
    _otpController.dispose();
    super.dispose();
  }

  Future<void> _sendCode() async {
    setState(() {
      _isSending = true;
      _error = null;
    });
    final result = await ref
        .read(sendPhoneOtpBackendUseCaseProvider)
        .call(widget.phoneNumber);
    if (!mounted) return;
    result.fold(
      (f) => setState(() {
        _isSending = false;
        _codeSent = false;
        _error = resolveAppError(context, f.toString());
      }),
      (otp) {
        setState(() {
          _isSending = false;
          _codeSent = true;
        });
        if (kDebugMode && otp != null && otp.isNotEmpty && context.mounted) {
          AppSnackbar.info(context, 'Debug OTP: $otp');
        }
      },
    );
  }

  Future<void> _verify() async {
    final code = _otpController.text.trim();
    if (code.isEmpty) return;
    setState(() {
      _isVerifying = true;
      _error = null;
    });
    final result = await ref.read(verifyPhoneOtpBackendUseCaseProvider).call(
          phoneNumber: widget.phoneNumber,
          otpToken: code,
        );
    if (!mounted) return;
    result.fold(
      (f) => setState(() {
        _isVerifying = false;
        _error = context.l10n.otpInvalidCode;
      }),
      (_) => Navigator.of(context).pop(true),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(
          left: AppSpacing.lg,
          right: AppSpacing.lg,
          top: AppSpacing.lg,
          bottom: MediaQuery.viewInsetsOf(context).bottom + AppSpacing.lg,
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                context.l10n.verifyYourNumber,
                style: AppTypography.titleMedium
                    .copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                _codeSent
                    ? '${context.l10n.codeSentTo} ${widget.phoneNumber}'
                    : widget.phoneNumber,
                style: AppTypography.bodyMedium,
              ),
              const SizedBox(height: AppSpacing.lg),
              TextField(
                controller: _otpController,
                keyboardType: TextInputType.number,
                autofocus: true,
                decoration: InputDecoration(
                  labelText: context.l10n.courierModeOtp,
                  border: const OutlineInputBorder(),
                  errorText: _error,
                ),
                onSubmitted: (_) => _verify(),
              ),
              const SizedBox(height: AppSpacing.md),
              FilledButton(
                onPressed: _isVerifying || !_codeSent ? null : _verify,
                child: _isVerifying
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text(context.l10n.verifyAndContinue),
              ),
              const SizedBox(height: AppSpacing.sm),
              TextButton(
                onPressed: _isSending ? null : _sendCode,
                child: Text(context.l10n.resendCode),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
