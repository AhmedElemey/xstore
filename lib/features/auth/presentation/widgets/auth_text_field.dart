import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/utils/extensions/context_extensions.dart';
import '../../../../shared/widgets/orbit_widgets.dart';

class AuthTextField extends StatelessWidget {
  const AuthTextField({
    super.key,
    required this.label,
    this.hint,
    this.prefixIcon,
    this.suffixIcon,
    this.controller,
    this.validator,
    this.keyboardType,
    this.obscureText = false,
    this.onChanged,
    this.readOnly = false,
    this.onTap,
    this.maxLines = 1,
    this.inputFormatters,
    this.textInputAction,
    this.errorText,
    this.labelTrailing,
  });

  final String label;
  final String? hint;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final TextEditingController? controller;
  final String? Function(String?)? validator;
  final TextInputType? keyboardType;
  final bool obscureText;
  final void Function(String)? onChanged;
  final bool readOnly;
  final VoidCallback? onTap;
  final int maxLines;
  final List<TextInputFormatter>? inputFormatters;
  final TextInputAction? textInputAction;
  final String? errorText;

  /// Action shown at the end of the label line (e.g. "Forgot password?").
  final Widget? labelTrailing;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        OrbitFieldLabel(label, trailing: labelTrailing),
        SizedBox(height: context.scaledPx(8)),
        TextFormField(
          controller: controller,
          validator: validator,
          keyboardType: keyboardType,
          obscureText: obscureText,
          onChanged: onChanged,
          readOnly: readOnly,
          onTap: onTap,
          maxLines: maxLines,
          inputFormatters: inputFormatters,
          textInputAction: textInputAction,
          style: AppTypography.bodyLarge.copyWith(color: context.textPrimary),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: AppTypography.bodyLarge.copyWith(
              color: context.textSecondary,
            ),
            filled: true,
            fillColor: glassFill(context),
            isDense: true,
            constraints: const BoxConstraints(minHeight: 54),
            floatingLabelBehavior: FloatingLabelBehavior.never,
            prefixIcon: prefixIcon,
            prefixIconColor: context.iconSecondary,
            // Default 48×48 min with no max lets prefix/suffix eat the input
            // slot; PhoneInputField uses tight constraints so the hint can paint.
            prefixIconConstraints: const BoxConstraints(
              minWidth: 40,
              minHeight: 40,
            ),
            suffixIcon: suffixIcon,
            suffixIconColor: context.iconSecondary,
            contentPadding: EdgeInsets.symmetric(
              horizontal: context.scaledPx(16),
              vertical: context.scaledPx(AppSpacing.inputContentPaddingV + 4),
            ),
            border: _border(context.borderColor),
            enabledBorder: _border(context.borderColor),
            focusedBorder: _border(context.primaryColor, width: 1.5),
            errorBorder: _border(AppColors.error),
            focusedErrorBorder: _border(AppColors.error, width: 1.5),
            errorText: errorText,
          ),
        ),
      ],
    );
  }

  static OutlineInputBorder _border(Color color, {double width = 1}) =>
      OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: color, width: width),
      );
}
