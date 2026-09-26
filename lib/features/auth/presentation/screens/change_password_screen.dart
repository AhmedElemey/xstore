import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../core/constants/app_spacing.dart';
import '../../../../core/utils/extensions/context_extensions.dart';
import '../../../../core/utils/validators.dart';
import '../../../../shared/widgets/app_snackbar.dart';
import '../../../../shared/widgets/xstore_button.dart';
import '../../../profile/presentation/providers/profile_provider.dart';
import '../providers/auth_provider.dart';
import '../widgets/auth_text_field.dart';
import '../widgets/password_strength_bar.dart';
import '../../../../shared/widgets/space_background.dart';

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
  late final Listenable _fields;

  @override
  void initState() {
    super.initState();
    _fields = Listenable.merge([_current, _next, _confirm]);
  }

  @override
  void dispose() {
    _current.dispose();
    _next.dispose();
    _confirm.dispose();
    super.dispose();
  }

  bool get _hasPassword =>
      ref.read(profileNotifierProvider).profile?.hasPassword ?? true;

  Future<void> _submit() async {
    final l10n = context.l10n;
    final hasPassword = _hasPassword;
    final currentError = hasPassword
        ? Validators.loginPassword(l10n, _current.text)
        : null;
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
          currentPassword: hasPassword ? _current.text : null,
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
        // Pass the loaded profile user so this screen never reads
        // authProvider (that starts session-restore work). force skips the
        // 30s refresh cooldown so hasPassword and the rest of get-profile
        // are current when the user lands back on Profile.
        final user = ref.read(profileNotifierProvider).profile?.user;
        final notifier = ref.read(profileNotifierProvider.notifier);
        context.pop();
        if (user != null) {
          unawaited(notifier.refreshProfileData(user: user, force: true));
        }
      },
    );
  }

  bool _canSubmit(bool hasPassword) {
    final l10n = context.l10n;
    final currentOk = !hasPassword ||
        Validators.loginPassword(l10n, _current.text) == null;
    return currentOk &&
        Validators.registerPassword(l10n, _next.text) == null &&
        Validators.confirmPasswordMatches(l10n, _next.text, _confirm.text) ==
            null;
  }

  @override
  Widget build(BuildContext context) {
    final hasPassword = ref.watch(
      profileNotifierProvider.select((s) => s.profile?.hasPassword ?? true),
    );
    return Scaffold(
      backgroundColor: context.backgroundColor,
      appBar: AppBar(
        title: Text(context.l10n.menuChangePassword),
      ),
      body: SpaceBackground(child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.x2l),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (hasPassword) ...[
                AuthTextField(
                  label: context.l10n.currentPasswordRequired,
                  controller: _current,
                  obscureText: !_currentVisible,
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
              ],
              AuthTextField(
                label: context.l10n.newPasswordRequired,
                controller: _next,
                obscureText: !_nextVisible,
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
              const Gap(AppSpacing.sm),
              ListenableBuilder(
                listenable: _next,
                builder: (context, _) => PasswordStrengthBar(password: _next.text),
              ),
              const Gap(AppSpacing.lg),
              AuthTextField(
                label: context.l10n.confirmPasswordRequired,
                controller: _confirm,
                obscureText: !_confirmVisible,
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
              const Gap(AppSpacing.lg),
              ListenableBuilder(
                listenable: _next,
                builder: (context, _) => PasswordRulesCard(password: _next.text),
              ),
              const Gap(AppSpacing.x2l),
              ListenableBuilder(
                listenable: _fields,
                builder: (context, _) => XstoreButton(
                  label: context.l10n.menuChangePassword,
                  isLoading: _isLoading,
                  onPressed:
                      _isLoading || !_canSubmit(hasPassword) ? null : _submit,
                ),
              ),
            ],
          ),
        ),
      )),
    );
  }
}
