import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/animations/animated_widgets.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/utils/extensions/context_extensions.dart';

/// Orbit text field: uppercase label over a frosted field (the theme's
/// input decoration), optional counter. Not [AuthTextField] because the
/// listing form needs a prefix, capitalization and a character counter.
class ListingFormField extends StatelessWidget {
  const ListingFormField({
    super.key,
    required this.label,
    this.controller,
    this.hint,
    this.minLines,
    this.maxLines,
    this.maxLength,
    this.keyboardType,
    this.prefix,
    this.prefixText,
    this.suffix,
    this.errorText,
    this.onChanged,
    this.inputFormatters,
    this.textCapitalization = TextCapitalization.sentences,
  });

  final String label;
  final TextEditingController? controller;
  final String? hint;
  final int? minLines;
  final int? maxLines;
  final int? maxLength;
  final TextInputType? keyboardType;
  final Widget? prefix;
  final String? prefixText;
  final Widget? suffix;
  final String? errorText;
  final void Function(String)? onChanged;
  final List<TextInputFormatter>? inputFormatters;
  final TextCapitalization textCapitalization;

  @override
  Widget build(BuildContext context) {
    final hasError = errorText != null && errorText!.isNotEmpty;
    final len = controller?.text.length ?? 0;
    final effectiveMaxLines = minLines != null ? maxLines : (maxLines ?? 1);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label.isNotEmpty) ...[
          Text(
            label.toUpperCase(),
            style: AppTypography.fieldLabel.copyWith(color: context.labelColor),
          ),
          SizedBox(height: context.scaledPx(8)),
        ],
        TextField(
          controller: controller,
          minLines: minLines,
          maxLines: effectiveMaxLines,
          maxLength: maxLength,
          keyboardType: keyboardType,
          onChanged: onChanged,
          inputFormatters: inputFormatters,
          textCapitalization: textCapitalization,
          buildCounter: maxLength != null
              ? (
                  context, {
                  required currentLength,
                  required isFocused,
                  maxLength,
                }) => const SizedBox.shrink()
              : null,
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
            prefixIcon: prefix == null
                ? null
                : IconTheme.merge(
                    data: IconThemeData(color: context.iconSecondary),
                    child: prefix!,
                  ),
            prefixText: prefixText,
            prefixStyle: AppTypography.bodyLarge.copyWith(
              color: context.textPrimary,
            ),
            suffixIcon: suffix,
            contentPadding: EdgeInsets.symmetric(
              horizontal: context.scaledPx(16),
              vertical: context.scaledPx(16),
            ),
            errorText: hasError ? errorText : null,
          ),
        ),
        if (maxLength != null)
          Padding(
            padding: EdgeInsetsDirectional.only(
              top: context.scaledPx(4),
              end: context.scaledPx(4),
            ),
            child: Align(
              alignment: AlignmentDirectional.centerEnd,
              child: AnimatedCounter(
                value: len,
                suffix: '/$maxLength',
                style: Theme.of(
                  context,
                ).textTheme.labelSmall!.copyWith(color: context.textSecondary),
              ),
            ),
          ),
      ],
    );
  }
}
