import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/utils/extensions/context_extensions.dart';
import '../../../../core/utils/validators.dart';
import '../../../../shared/widgets/xstore_text_field.dart';
import '../providers/auth_provider.dart';
import '../widgets/auth_button.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
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
    await ref.read(authProvider.notifier).register(
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
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  AppStrings.registerTitle,
                  style: context.textTheme.headlineSmall,
                ),
                const Gap(AppSpacing.md),
                XstoreTextField(
                  controller: _email,
                  label: 'Email',
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  validator: Validators.email,
                ),
                const Gap(AppSpacing.sm),
                XstoreTextField(
                  controller: _password,
                  label: 'Password',
                  obscure: true,
                  textInputAction: TextInputAction.done,
                  validator: Validators.password,
                ),
                const Gap(AppSpacing.lg),
                AuthButton(
                  label: 'Register',
                  isLoading: loading,
                  onPressed: loading ? null : _onSubmit,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
