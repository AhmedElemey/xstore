import 'package:flutter/material.dart';

import '../../../../core/utils/validators.dart';
import '../../../../shared/widgets/xstore_text_field.dart';

class LoginForm extends StatelessWidget {
  const LoginForm({
    super.key,
    required this.emailController,
    required this.passwordController,
    required this.formKey,
  });

  final TextEditingController emailController;
  final TextEditingController passwordController;
  final GlobalKey<FormState> formKey;

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          XstoreTextField(
            controller: emailController,
            label: 'Email',
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.next,
            validator: Validators.email,
          ),
          const SizedBox(height: 12),
          XstoreTextField(
            controller: passwordController,
            label: 'Password',
            obscure: true,
            textInputAction: TextInputAction.done,
            validator: Validators.password,
          ),
        ],
      ),
    );
  }
}
