import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/utils/extensions/context_extensions.dart';
import '../providers/auth_provider.dart';
import '../widgets/auth_button.dart';
import '../widgets/login_form.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _onSubmit() async {
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }
    await ref.read(authProvider.notifier).login(
          email: _email.text.trim(),
          password: _password.text,
        );
    if (!mounted) {
      return;
    }
    final auth = ref.read(authProvider);
    auth.whenOrNull(
      error: (e, _) => context.showSnack(e.toString()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authProvider);
    final loading = auth.isLoading;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                AppStrings.loginTitle,
                style: context.textTheme.headlineSmall,
              ),
              const Gap(AppSpacing.md),
              LoginForm(
                formKey: _formKey,
                emailController: _email,
                passwordController: _password,
              ),
              const Gap(AppSpacing.lg),
              AuthButton(
                label: 'Continue',
                isLoading: loading,
                onPressed: loading ? null : _onSubmit,
              ),
              const Gap(AppSpacing.md),
              TextButton(
                onPressed: () => context.push(AppRoutes.register),
                child: const Text('Create an account'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
