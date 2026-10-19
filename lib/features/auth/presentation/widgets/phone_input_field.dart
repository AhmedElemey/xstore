import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../../core/constants/app_typography.dart';
import '../../../../core/utils/extensions/context_extensions.dart';
import '../../../../core/utils/validators.dart';

class PhoneInputField extends StatelessWidget {
  const PhoneInputField({
    super.key,
    required this.controller,
    required this.onChanged,
    this.errorText,
    this.enabled = true,
    this.readOnly = false,
    this.suffix,
    this.onTap,
    this.accentColor,
  });

  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final String? errorText;
  final bool enabled;
  final bool readOnly;

  /// Trailing widget inside the field (e.g. a Verify action). Replaces the
  /// clear button so the row stays on one line.
  final Widget? suffix;

  /// Called when the field is tapped. Used with [readOnly] for "tap to
  /// change" flows that must not accept inline typing.
  final VoidCallback? onTap;

  /// Color of the "+20" code; defaults to the link color.
  final Color? accentColor;

  @override
  Widget build(BuildContext context) {
    final national = AppValidators.egyptNationalSignificantNumber(controller.text);
    if (national != controller.text) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (controller.text == national) return;
        controller.value = TextEditingValue(
          text: national,
          selection: TextSelection.collapsed(offset: national.length),
        );
      });
    }

    final codeColor = accentColor ?? context.linkColor;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          context.l10n.phoneNumber.toUpperCase(),
          style: AppTypography.fieldLabel.copyWith(color: context.labelColor),
        ),
        SizedBox(height: context.scaledPx(8)),
        TextFormField(
          controller: controller,
          readOnly: readOnly,
          onTap: onTap,
          onChanged: readOnly
              ? null
              : (value) {
                  final national =
                      AppValidators.egyptNationalSignificantNumber(value);
                  if (controller.text != national) {
                    controller.value = TextEditingValue(
                      text: national,
                      selection: TextSelection.collapsed(
                        offset: national.length,
                      ),
                    );
                  }
                  onChanged(AppValidators.normalizeEgyptLocal(national));
                },
          enabled: enabled,
          keyboardType: TextInputType.phone,
          inputFormatters: const [_EgyptNationalPhoneFormatter()],
          style: AppTypography.bodyLarge.copyWith(
            color: context.textPrimary,
            fontWeight: FontWeight.w500,
          ),
          decoration: InputDecoration(
            hintText: '1012345678',
            hintStyle: AppTypography.bodyLarge.copyWith(
              color: context.textHint,
            ),
            // "+20" in mono, split from the number by a hairline — the
            // Orbit country-code prefix.
            prefixIcon: Padding(
              padding: const EdgeInsetsDirectional.only(start: 16, end: 10),
              child: Container(
                padding: const EdgeInsetsDirectional.only(end: 10),
                decoration: BoxDecoration(
                  border: BorderDirectional(
                    end: BorderSide(color: context.borderColor),
                  ),
                ),
                child: Text(
                  '+20',
                  textDirection: TextDirection.ltr,
                  style: AppTypography.mono.copyWith(
                    fontSize: 15,
                    color: codeColor,
                  ),
                ),
              ),
            ),
            prefixIconConstraints: const BoxConstraints(minHeight: 24),
            suffixIcon:
                suffix ??
                (!readOnly && controller.text.isNotEmpty
                    ? IconButton(
                        onPressed: () {
                          controller.clear();
                          onChanged('');
                        },
                        icon: Icon(
                          LucideIcons.x,
                          size: 18,
                          color: context.iconSecondary,
                        ),
                      )
                    : null),
            suffixIconConstraints: suffix != null
                ? const BoxConstraints(minWidth: 0, minHeight: 0)
                : null,
            errorText: errorText,
            contentPadding: const EdgeInsets.symmetric(vertical: 16),
            isDense: true,
          ),
        ),
      ],
    );
  }
}

class _EgyptNationalPhoneFormatter extends TextInputFormatter {
  const _EgyptNationalPhoneFormatter();

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final national =
        AppValidators.egyptNationalSignificantNumber(newValue.text);
    return TextEditingValue(
      text: national,
      selection: TextSelection.collapsed(offset: national.length),
    );
  }
}
