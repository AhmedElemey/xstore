import 'package:flutter/material.dart';

import '../../../../shared/widgets/xstore_button.dart';

class AuthButton extends StatelessWidget {
  const AuthButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.isLoading = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return XstoreButton(
      label: label,
      onPressed: onPressed,
      isLoading: isLoading,
    );
  }
}
