import 'package:flutter/material.dart';

class XstoreButton extends StatelessWidget {
  const XstoreButton({
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
    return FilledButton(
      onPressed: isLoading ? null : onPressed,
      child: isLoading
          ? const SizedBox(
              height: 22,
              width: 22,
              child: CircularProgressIndicator.adaptive(strokeWidth: 2),
            )
          : Text(label),
    );
  }
}
