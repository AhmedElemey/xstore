import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gap/gap.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:pinput/pinput.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/utils/extensions/context_extensions.dart';
import '../../../../shared/widgets/orbit_widgets.dart';

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
    final defaultTheme = PinTheme(
      width: 48,
      height: 60,
      textStyle: AppTypography.titleLarge.copyWith(
        color: context.textPrimary,
        fontWeight: FontWeight.w700,
        fontFeatures: const [FontFeature.tabularFigures()],
      ),
      decoration: BoxDecoration(
        color: glassFill(context),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: context.borderColor),
      ),
    );
    final accent = context.primaryColor;
    final focusedTheme = defaultTheme.copyWith(
      decoration: defaultTheme.decoration!.copyWith(
        border: Border.all(color: accent, width: 2),
        boxShadow: [
          BoxShadow(color: accent.withValues(alpha: 0.14), spreadRadius: 4),
          BoxShadow(color: accent.withValues(alpha: 0.3), blurRadius: 20),
        ],
      ),
    );
    final filledTheme = defaultTheme;
    final errorTheme = defaultTheme.copyWith(
      decoration: defaultTheme.decoration!.copyWith(
        border: Border.all(color: AppColors.error, width: 1.5),
      ),
    );

    return Column(
      children: [
        Pinput(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          controller: controller,
          length: 6,
          defaultPinTheme: defaultTheme,
          focusedPinTheme: focusedTheme,
          submittedPinTheme: filledTheme,
          errorPinTheme: errorTheme,
          enabled: enabled,
          autofocus: true,
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          onCompleted: onCompleted,
          forceErrorState: errorText != null,
          hapticFeedbackType: HapticFeedbackType.lightImpact,
        ),
        if (errorText != null) ...[
          const Gap(AppSpacing.sm),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                LucideIcons.alertCircle,
                size: 14,
                color: AppColors.error,
              ),
              const Gap(AppSpacing.xs),
              Text(
                errorText!,
                style: AppTypography.bodySmall.copyWith(color: AppColors.error),
              ),
            ],
          ),
        ],
      ],
    );
  }
}
