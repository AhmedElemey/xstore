import 'package:flutter/material.dart';

import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/utils/extensions/context_extensions.dart';
import '../../../../shared/widgets/orbit_widgets.dart';

/// Orbit "ghost" pill: glass fill, hairline border, icon + label.
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
    return SizedBox(
      height: 52,
      width: double.infinity,
      child: Material(
        color: glassFill(context),
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
                      color: context.textPrimary,
                    ),
                  )
                else
                  SizedBox(width: 22, height: 22, child: Center(child: icon)),
                const SizedBox(width: AppSpacing.md),
                Flexible(
                  child: Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTypography.labelLarge.copyWith(
                      color: context.textPrimary,
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
