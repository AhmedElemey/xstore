import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/constants/app_typography.dart';
import '../../../../core/utils/extensions/context_extensions.dart';

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

  /// Shown at the end of the label row (e.g. "Forgot password?").
  final Widget? labelTrailing;

  @override
  Widget build(BuildContext context) {
    // Orbit field: uppercase tracked label over a frosted 16px-radius field;
    // borders and fill come from the theme's InputDecorationTheme.
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                label.toUpperCase(),
                style: AppTypography.fieldLabel.copyWith(
                  color: context.labelColor,
                ),
              ),
            ),
            ?labelTrailing,
          ],
        ),
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
          style: AppTypography.bodyLarge.copyWith(
            color: context.textPrimary,
            fontWeight: FontWeight.w500,
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: AppTypography.bodyLarge.copyWith(
              color: context.textHint,
            ),
            isDense: true,
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
              vertical: context.scaledPx(16),
            ),
            errorText: errorText,
          ),
        ),
      ],
    );
  }
}
