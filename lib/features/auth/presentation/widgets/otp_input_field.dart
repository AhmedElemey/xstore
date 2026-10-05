import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gap/gap.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:pinput/pinput.dart';

import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/utils/extensions/context_extensions.dart';

/// Six Orbit code cells: frosted 16px-radius glass, mono digits, and a
/// glowing ring on the focused cell. Digits always read left to right.
class OtpInputField extends StatelessWidget {
  const OtpInputField({
    super.key,
    required this.controller,
    required this.onCompleted,
    this.errorText,
    this.enabled = true,
  });

  final TextEditingController controller;
  final ValueChanged<String> onCompleted;
  final String? errorText;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final primary = context.primaryColor;
    final error = context.colorScheme.error;
    final defaultTheme = PinTheme(
      width: 48,
      height: 60,
      textStyle: AppTypography.mono.copyWith(
        fontSize: 24,
        fontWeight: FontWeight.w700,
        color: context.textPrimary,
      ),
      decoration: BoxDecoration(
        color: context.glassColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: context.borderColor),
      ),
    );
    final focusedTheme = defaultTheme.copyWith(
      decoration: defaultTheme.decoration!.copyWith(
        border: Border.all(color: primary, width: 2),
        boxShadow: [
          BoxShadow(color: primary.withValues(alpha: 0.14), spreadRadius: 4),
          BoxShadow(color: primary.withValues(alpha: 0.3), blurRadius: 20),
        ],
      ),
    );
    final errorTheme = defaultTheme.copyWith(
      decoration: defaultTheme.decoration!.copyWith(
        border: Border.all(color: error, width: 1.5),
      ),
    );

    return Column(
      children: [
        // Scales the row down on narrow phones instead of overflowing.
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Directionality(
            textDirection: TextDirection.ltr,
            child: Pinput(
              controller: controller,
              length: 6,
              defaultPinTheme: defaultTheme,
              focusedPinTheme: focusedTheme,
              errorPinTheme: errorTheme,
              separatorBuilder: (_) => const Gap(10),
              enabled: enabled,
              autofocus: true,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              onCompleted: onCompleted,
              forceErrorState: errorText != null,
              hapticFeedbackType: HapticFeedbackType.lightImpact,
            ),
          ),
        ),
        if (errorText != null) ...[
          const Gap(AppSpacing.md),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(LucideIcons.alertCircle, size: 14, color: error),
              const Gap(AppSpacing.xs),
              Flexible(
                child: Text(
                  errorText!,
                  style: AppTypography.bodySmall.copyWith(color: error),
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }
}
