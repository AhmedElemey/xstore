import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/prefs_keys.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../shared/providers/shared_providers.dart';
import '../providers/auth_provider.dart';
import '../widgets/auth_button.dart';
import '../widgets/auth_divider.dart';
import '../widgets/auth_header.dart';
import '../widgets/auth_text_field.dart';
import '../widgets/social_login_row.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();
  late AnimationController _shakeController;

  @override
  void initState() {
    super.initState();
    _shakeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadRememberedEmail());
  }

  Future<void> _loadRememberedEmail() async {
    final prefs = await ref.read(sharedPreferencesProvider.future);
    final saved = prefs.getString(PrefsKeys.rememberedEmail);
    if (saved != null && saved.isNotEmpty && mounted) {
      _email.text = saved;
      ref.read(loginNotifierProvider.notifier).updateEmail(saved);
      ref.read(loginNotifierProvider.notifier).setRememberMe(true);
    }
  }

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    _shakeController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final n = ref.read(loginNotifierProvider.notifier);
    n.updateEmail(_email.text.trim());
    n.updatePassword(_password.text);
    await n.login();
    if (!mounted) return;
    final err = ref.read(loginNotifierProvider).error;
    if (err == null) {
      context.go(AppRoutes.home);
    }
  }

  bool _isValidEmailOrPhone(String v) {
    final t = v.trim();
    if (RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(t)) return true;
    final digits = t.replaceAll(RegExp(r'\D'), '');
    return digits.length >= 10;
  }

  @override
  Widget build(BuildContext context) {
    final login = ref.watch(loginNotifierProvider);
    ref.listen(loginNotifierProvider, (prev, next) {
      if (next.error != null && next.error != prev?.error) {
        _shakeController.forward(from: 0);
      }
    });

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          Expanded(
            flex: 40,
            child: AuthHeader(
              heightFraction: 1,
              title: 'Welcome back 👋',
              subtitle: 'Sign in to continue shopping',
              logoSize: 32,
            ),
          ),
          Expanded(
            flex: 60,
            child: Transform.translate(
              offset: const Offset(0, -24),
              child: AnimatedBuilder(
                animation: _shakeController,
                builder: (context, child) {
                  final t = _shakeController.value;
                  final ox = 10 * (1 - t) * math.sin(t * 6.28318 * 4);
                  return Transform.translate(
                    offset: Offset(ox, 0),
                    child: child,
                  );
                },
                child: Container(
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
                    boxShadow: [
                      BoxShadow(
                        color: Color(0x12000000),
                        blurRadius: 20,
                        offset: Offset(0, -4),
                      ),
                    ],
                  ),
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
                    child: Form(
                      key: _formKey,
                      child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _LoginRegisterTabs(
                          onRegisterTap: () =>
                              context.push(AppRoutes.register),
                        ),
                        const Gap(20),
                        AuthTextField(
                          label: 'Email or Phone Number',
                          hint: 'you@email.com',
                          controller: _email,
                          keyboardType: TextInputType.emailAddress,
                          textInputAction: TextInputAction.next,
                          prefixIcon: const Icon(LucideIcons.mail),
                          errorText: login.error != null &&
                                  (login.error!.contains('Email') ||
                                      login.error!.contains('phone') ||
                                      login.error!.contains('valid'))
                              ? login.error
                              : null,
                          onChanged: (v) =>
                              ref.read(loginNotifierProvider.notifier).updateEmail(v),
                          validator: (v) {
                            if (v == null || v.trim().isEmpty) {
                              return 'Required';
                            }
                            if (!_isValidEmailOrPhone(v)) {
                              return 'Valid email or 10+ digit phone';
                            }
                            return null;
                          },
                        ),
                        const Gap(16),
                        AuthTextField(
                          label: 'Password',
                          controller: _password,
                          obscureText: !login.isPasswordVisible,
                          textInputAction: TextInputAction.done,
                          prefixIcon: const Icon(LucideIcons.lock),
                          suffixIcon: IconButton(
                            onPressed: () => ref
                                .read(loginNotifierProvider.notifier)
                                .togglePasswordVisibility(),
                            icon: Icon(
                              login.isPasswordVisible
                                  ? LucideIcons.eyeOff
                                  : LucideIcons.eye,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          errorText: login.error != null &&
                                  login.error!.toLowerCase().contains('password')
                              ? login.error
                              : null,
                          onChanged: (v) => ref
                              .read(loginNotifierProvider.notifier)
                              .updatePassword(v),
                          validator: (v) {
                            if (v == null || v.isEmpty) return 'Required';
                            if (v.length < 6) return 'Min 6 characters';
                            return null;
                          },
                        ),
                        if (login.error != null &&
                            !login.error!.toLowerCase().contains('password') &&
                            !login.error!.contains('Email') &&
                            !login.error!.contains('phone') &&
                            !login.error!.contains('valid')) ...[
                          const Gap(8),
                          Text(
                            login.error!,
                            style: const TextStyle(
                              color: AppColors.error,
                              fontSize: 13,
                            ),
                          ),
                        ],
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            onPressed: () =>
                                context.push(AppRoutes.forgotPassword),
                            child: const Text(
                              'Forgot Password?',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                color: AppColors.accent,
                              ),
                            ),
                          ),
                        ),
                        Row(
                          children: [
                            Checkbox(
                              value: login.rememberMe,
                              activeColor: AppColors.primary,
                              onChanged: (_) => ref
                                  .read(loginNotifierProvider.notifier)
                                  .toggleRememberMe(),
                            ),
                            const Text(
                              'Remember me',
                              style: TextStyle(
                                fontSize: 14,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ],
                        ),
                        const Gap(8),
                        AuthButton(
                          label: 'Login',
                          isLoading: login.isLoading,
                          onPressed: login.isLoading
                              ? null
                              : () async {
                                  if (_formKey.currentState?.validate() ??
                                      false) {
                                    await _submit();
                                  }
                                },
                        ),
                        const Gap(22),
                        const AuthDivider(),
                        const Gap(22),
                        const SocialLoginRow(),
                        const Gap(20),
                        Center(
                          child: TextButton(
                            onPressed: () =>
                                context.push(AppRoutes.register),
                            child: RichText(
                              text: const TextSpan(
                                style: TextStyle(
                                  fontSize: 14,
                                  color: AppColors.textSecondary,
                                ),
                                children: [
                                  TextSpan(text: "Don't have an account?  "),
                                  TextSpan(
                                    text: 'Create one →',
                                    style: TextStyle(
                                      color: AppColors.accent,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LoginRegisterTabs extends StatelessWidget {
  const _LoginRegisterTabs({required this.onRegisterTap});

  final VoidCallback onRegisterTap;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            children: [
              const Text(
                'Login',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                  color: AppColors.primary,
                ),
              ),
              const Gap(8),
              Container(
                height: 3,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: InkWell(
            onTap: onRegisterTap,
            child: Column(
              children: [
                Text(
                  'Register',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textSecondary.withValues(alpha: 0.85),
                  ),
                ),
                const Gap(8),
                const SizedBox(height: 3),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
