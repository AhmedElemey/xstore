import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/utils/extensions/context_extensions.dart';
import '../../../../core/utils/validators.dart';
import '../../../../shared/widgets/app_snackbar.dart';
import '../../../../shared/widgets/xstore_button.dart';
import '../providers/auth_provider.dart';
import '../widgets/auth_text_field.dart';

class ChangePasswordScreen extends ConsumerStatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  ConsumerState<ChangePasswordScreen> createState() =>
      _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends ConsumerState<ChangePasswordScreen> {
  final _current = TextEditingController();
  final _next = TextEditingController();
  final _confirm = TextEditingController();
  var _currentVisible = false;
  var _nextVisible = false;
  var _confirmVisible = false;
  var _isLoading = false;
  String? _currentError;
  String? _nextError;
  String? _confirmError;

  @override
  void dispose() {
    _current.dispose();
    _next.dispose();
    _confirm.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final l10n = context.l10n;
    final currentError = Validators.loginPassword(l10n, _current.text);
    final nextError = Validators.registerPassword(l10n, _next.text);
    final confirmError = Validators.confirmPasswordMatches(
      l10n,
      _next.text,
      _confirm.text,
    );
    setState(() {
      _currentError = currentError;
      _nextError = nextError;
      _confirmError = confirmError;
    });
    if (currentError != null || nextError != null || confirmError != null) {
      return;
    }

    setState(() => _isLoading = true);
    final result = await ref.read(changePasswordUseCaseProvider).call(
          currentPassword: _current.text,
          newPassword: _next.text,
          confirmNewPassword: _confirm.text,
        );
    if (!mounted) return;
    result.fold(
      (failure) {
        setState(() => _isLoading = false);
        AppSnackbar.error(context, failure.toString());
      },
      (_) {
        setState(() => _isLoading = false);
        AppSnackbar.success(context, l10n.changePasswordSuccess);
        context.pop();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.backgroundColor,
      appBar: AppBar(
        title: Text(context.l10n.menuChangePassword),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.x2l),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                context.l10n.strongPasswordHint,
                style: AppTypography.body15.copyWith(
                  height: 1.4,
                  color: context.textSecondary,
                ),
              ),
              const Gap(AppSpacing.x2l),
              AuthTextField(
                label: context.l10n.currentPasswordRequired,
                controller: _current,
                obscureText: !_currentVisible,
                prefixIcon: const Icon(LucideIcons.lock),
                suffixIcon: IconButton(
                  onPressed: () =>
                      setState(() => _currentVisible = !_currentVisible),
                  icon: Icon(
                    _currentVisible ? LucideIcons.eyeOff : LucideIcons.eye,
                    color: context.iconSecondary,
                  ),
                ),
                errorText: _currentError,
                onChanged: (_) {
                  if (_currentError != null) {
                    setState(() => _currentError = null);
                  }
                },
              ),
              const Gap(AppSpacing.lg),
              AuthTextField(
                label: context.l10n.newPasswordRequired,
                controller: _next,
                obscureText: !_nextVisible,
                prefixIcon: const Icon(LucideIcons.lock),
                suffixIcon: IconButton(
                  onPressed: () => setState(() => _nextVisible = !_nextVisible),
                  icon: Icon(
                    _nextVisible ? LucideIcons.eyeOff : LucideIcons.eye,
                    color: context.iconSecondary,
                  ),
                ),
                errorText: _nextError,
                onChanged: (_) {
                  if (_nextError != null) {
                    setState(() => _nextError = null);
                  }
                },
              ),
              const Gap(AppSpacing.lg),
              AuthTextField(
                label: context.l10n.confirmPasswordRequired,
                controller: _confirm,
                obscureText: !_confirmVisible,
                prefixIcon: const Icon(LucideIcons.shieldCheck),
                suffixIcon: IconButton(
                  onPressed: () =>
                      setState(() => _confirmVisible = !_confirmVisible),
                  icon: Icon(
                    _confirmVisible ? LucideIcons.eyeOff : LucideIcons.eye,
                    color: context.iconSecondary,
                  ),
                ),
                errorText: _confirmError,
                onChanged: (_) {
                  if (_confirmError != null) {
                    setState(() => _confirmError = null);
                  }
                },
              ),
              const Gap(AppSpacing.x2l),
              XstoreButton(
                label: context.l10n.menuChangePassword,
                isLoading: _isLoading,
                onPressed: _isLoading ? null : _submit,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
