import 'package:flutter/material.dart';

import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_typography.dart';

class SocialButton extends StatelessWidget {
  const SocialButton({
    super.key,
    required this.onTap,
    required this.isLoading,
    required this.icon,
    required this.label,
    required this.borderColor,
    required this.bgColor,
    required this.textColor,
  });

  final VoidCallback? onTap;
  final bool isLoading;
  final Widget icon;
  final String label;
  final Color borderColor;
  final Color bgColor;
  final Color textColor;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 52,
      width: double.infinity,
      child: Material(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: borderColor, width: 1.5),
            ),
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (isLoading)
                  SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.2,
                      valueColor: AlwaysStoppedAnimation<Color>(textColor),
                    ),
                  )
                else
                  SizedBox(width: 22, height: 22, child: Center(child: icon)),
                const SizedBox(width: AppSpacing.md),
                Text(
                  label,
                  style: AppTypography.labelLarge.copyWith(
                    color: textColor,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
