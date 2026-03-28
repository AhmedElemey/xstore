import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';

class AuthDivider extends StatelessWidget {
  const AuthDivider({super.key, this.label = 'or continue with'});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Divider(
            color: AppColors.textDisabled.withValues(alpha: 0.6),
            thickness: 1,
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.textSecondary,
            ),
          ),
        ),
        Expanded(
          child: Divider(
            color: AppColors.textDisabled.withValues(alpha: 0.6),
            thickness: 1,
          ),
        ),
      ],
    );
  }
}
