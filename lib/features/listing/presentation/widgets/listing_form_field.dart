import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/animations/animated_widgets.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/utils/extensions/context_extensions.dart';

/// Outlined field (12px radius), optional counter, focus shadow; errors use red underline + helper text.
class ListingFormField extends StatefulWidget {
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
  State<ListingFormField> createState() => _ListingFormFieldState();
}

class _ListingFormFieldState extends State<ListingFormField> {
  final _focus = FocusNode();
  bool _focused = false;

  @override
  void initState() {
    super.initState();
    _focus.addListener(() {
      setState(() => _focused = _focus.hasFocus);
    });
  }

  @override
  void dispose() {
    _focus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final hasError = widget.errorText != null && widget.errorText!.isNotEmpty;
    final len = widget.controller?.text.length ?? 0;
    final counter = widget.maxLength != null
        ? '$len/${widget.maxLength}'
        : null;
    final effectiveMaxLines = widget.minLines != null
        ? widget.maxLines
        : (widget.maxLines ?? 1);

    final normalBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: context.textDisabled),
    );
    final focusedNormal = OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
    );
    const errorUnderline = UnderlineInputBorder(
      borderSide: BorderSide(color: AppColors.error, width: 2),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.label.isNotEmpty) ...[
          Text(
            widget.label,
            style: Theme.of(
              context,
            ).textTheme.labelLarge?.copyWith(color: context.textPrimary),
          ),
          SizedBox(height: context.scaledPx(6)),
        ],
        Builder(
          builder: (context) {
            final box = AnimatedContainer(
              duration: const Duration(milliseconds: 160),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                boxShadow: _focused && !hasError
                    ? [
                        BoxShadow(
                          color: AppColors.primary.withValues(alpha: 0.18),
                          blurRadius: 10,
                          offset: const Offset(0, 3),
                        ),
                      ]
                    : null,
              ),
              child: TextField(
                controller: widget.controller,
                focusNode: _focus,
                minLines: widget.minLines,
                maxLines: effectiveMaxLines,
                maxLength: widget.maxLength,
                keyboardType: widget.keyboardType,
                onChanged: widget.onChanged,
                inputFormatters: widget.inputFormatters,
                textCapitalization: widget.textCapitalization,
                buildCounter: widget.maxLength != null
                    ? (
                        context, {
                        required currentLength,
                        required isFocused,
                        maxLength,
                      }) => const SizedBox.shrink()
                    : null,
                style: Theme.of(
                  context,
                ).textTheme.bodyLarge?.copyWith(color: context.textPrimary),
                decoration: InputDecoration(
                  hintText: widget.hint,
                  hintStyle: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(color: context.textHint),
                  filled: true,
                  fillColor: context.surfaceVariantColor,
                  prefixIcon: widget.prefix == null
                      ? null
                      : IconTheme.merge(
                          data: IconThemeData(color: context.iconSecondary),
                          child: widget.prefix!,
                        ),
                  prefixText: widget.prefixText,
                  prefixStyle: Theme.of(
                    context,
                  ).textTheme.bodyLarge?.copyWith(color: context.textPrimary),
                  suffixIcon: widget.suffix,
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: context.scaledPx(AppTypography.rem(0.875)),
                    vertical: context.scaledPx(AppTypography.rem(0.875)),
                  ),
                  border: hasError ? errorUnderline : normalBorder,
                  enabledBorder: hasError ? errorUnderline : normalBorder,
                  focusedBorder: hasError ? errorUnderline : focusedNormal,
                  disabledBorder: normalBorder,
                ),
              ),
            );
            return box;
          },
        ),
        if (counter != null)
          Padding(
            padding: EdgeInsets.only(
              top: context.scaledPx(4),
              right: context.scaledPx(4),
            ),
            child: Align(
              alignment: Alignment.centerRight,
              child: AnimatedCounter(
                value: len,
                suffix: '/${widget.maxLength}',
                style: Theme.of(context).textTheme.labelSmall!.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          ),
        if (hasError)
          Padding(
            padding: EdgeInsets.only(
              top: context.scaledPx(4),
              left: context.scaledPx(4),
            ),
            child: Text(
              widget.errorText!,
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: AppColors.error),
            ),
          ),
      ],
    );
  }
}
