import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/utils/extensions/context_extensions.dart';
import '../widgets/auth_button.dart';
import '../widgets/auth_text_field.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  int _step = 1;
  final _email = TextEditingController();
  int _cooldown = 0;
  Timer? _timer;

  @override
  void dispose() {
    _timer?.cancel();
    _email.dispose();
    super.dispose();
  }

  void _startCooldown() {
    _timer?.cancel();
    setState(() => _cooldown = 60);
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (_cooldown <= 1) {
        t.cancel();
        setState(() => _cooldown = 0);
      } else {
        setState(() => _cooldown--);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(LucideIcons.arrowLeft, color: context.iconPrimary),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 320),
            child: _step == 1
                ? _StepEmail(
                    key: const ValueKey(1),
                    emailController: _email,
                    onSend: () {
                      if (_email.text.trim().isEmpty) return;
                      setState(() => _step = 2);
                      _startCooldown();
                    },
                  )
                : _StepCheckEmail(
                    key: const ValueKey(2),
                    email: _email.text.trim(),
                    cooldown: _cooldown,
                    onResend: _cooldown == 0 ? _startCooldown : null,
                    onBackToLogin: () => context.go(AppRoutes.login),
                  ),
          ),
        ),
      ),
    );
  }
}

class _StepEmail extends StatelessWidget {
  const _StepEmail({
    super.key,
    required this.emailController,
    required this.onSend,
  });

  final TextEditingController emailController;
  final VoidCallback onSend;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Reset Password',
          style: TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.w800,
            color: context.textPrimary,
          ),
        ),
        const Gap(12),
        Text(
          "Enter your email and we'll send you a reset link",
          style: TextStyle(
            fontSize: 15,
            height: 1.4,
            color: context.textSecondary,
          ),
        ),
        const Gap(28),
        AuthTextField(
          label: 'Email',
          controller: emailController,
          keyboardType: TextInputType.emailAddress,
          prefixIcon: const Icon(LucideIcons.mail),
        ),
        const Spacer(),
        AuthButton(
          label: 'Send Reset Link',
          onPressed: onSend,
        ),
      ],
    );
  }
}

class _StepCheckEmail extends StatelessWidget {
  const _StepCheckEmail({
    super.key,
    required this.email,
    required this.cooldown,
    required this.onResend,
    required this.onBackToLogin,
  });

  final String email;
  final int cooldown;
  final VoidCallback? onResend;
  final VoidCallback onBackToLogin;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Center(
          child: SvgPicture.string(
            _mailSvg,
            width: 120,
            height: 120,
          ),
        ),
        const Gap(24),
        Text(
          'Check your email',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w800,
            color: context.textPrimary,
          ),
        ),
        const Gap(12),
        Text(
          'We sent a reset link to\n$email',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 15,
            height: 1.45,
            color: context.textSecondary,
          ),
        ),
        const Gap(24),
        if (cooldown > 0)
          Text(
            'Resend in ${cooldown}s',
            textAlign: TextAlign.center,
            style: TextStyle(color: context.textSecondary),
          )
        else
          TextButton(
            onPressed: onResend,
            child: Text(
              'Resend email',
              style: TextStyle(
                fontWeight: FontWeight.w700,
                color: AppColors.accent,
              ),
            ),
          ),
        const Spacer(),
        TextButton(
          onPressed: onBackToLogin,
          child: Text(
            'Back to Login',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: AppColors.primary,
            ),
          ),
        ),
      ],
    );
  }
}

const _mailSvg = '''
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 120 120" fill="none">
  <circle cx="60" cy="60" r="56" fill="#EEF2FF"/>
  <path d="M30 45h60v30H30V45z" stroke="#4F46E5" stroke-width="2.5" fill="white" rx="4"/>
  <path d="M30 45l30 20 30-20" stroke="#4F46E5" stroke-width="2.5" fill="none"/>
</svg>
''';
