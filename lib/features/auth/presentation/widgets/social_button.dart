import 'package:flutter/material.dart';

import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/utils/extensions/context_extensions.dart';

/// Orbit ghost button: a frosted 52px pill with a hairline border.
class SocialButton extends StatelessWidget {
  const SocialButton({
    super.key,
    required this.onTap,
    required this.isLoading,
    required this.icon,
    required this.label,
  });

  final VoidCallback? onTap;
  final bool isLoading;
  final Widget icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final textColor = context.textPrimary;
    return SizedBox(
      height: 52,
      width: double.infinity,
      child: Material(
        color: context.glassColor,
        shape: StadiumBorder(side: BorderSide(color: context.borderColor)),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Padding(
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
                Flexible(
                  child: Text(
                    label,
                    overflow: TextOverflow.ellipsis,
                    style: AppTypography.body15.copyWith(
                      color: textColor,
                      fontWeight: FontWeight.w700,
                    ),
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
