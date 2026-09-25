import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gap/gap.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
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

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          context.l10n.phoneNumber,
          style: AppTypography.bodyMedium.copyWith(
            color: context.textSecondary,
            fontWeight: FontWeight.w500,
          ),
        ),
        const Gap(AppSpacing.xs),
        SizedBox(
          height: 52,
          child: Material(
            color: AppColors.transparent,
            borderRadius: BorderRadius.circular(12),
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.transparent,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: errorText != null
                      ? AppColors.error
                      : context.borderColor,
                  width: 1.5,
                ),
              ),
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              child: TextFormField(
                controller: controller,
                readOnly: readOnly,
                onTap: onTap,
                onChanged: readOnly
                    ? null
                    : (value) {
                        final national =
                            AppValidators.egyptNationalSignificantNumber(
                          value,
                        );
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
                inputFormatters: const [
                  _EgyptNationalPhoneFormatter(),
                ],
                style: AppTypography.bodyLarge.copyWith(
                  color: context.textPrimary,
                ),
                decoration: InputDecoration(
                  fillColor: AppColors.transparent,
                  hintText: '1012345678',
                  prefixIcon: const Padding(
                    padding: EdgeInsets.only(right: 8),
                    child: Icon(LucideIcons.phone),
                  ),
                  prefixIconConstraints: const BoxConstraints(
                    minWidth: 24,
                    minHeight: 24,
                  ),
                  prefixText: '🇪🇬 +20 ',
                  prefixStyle: AppTypography.bodyMedium.copyWith(
                    color: context.textPrimary,

                    fontWeight: FontWeight.w600,
                  ),

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
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  disabledBorder: InputBorder.none,
                  errorBorder: InputBorder.none,
                  focusedErrorBorder: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    vertical: AppSpacing.inputContentPaddingH,
                  ),
                  isDense: true,
                ),
              ),
            ),
          ),
        ),
        if (errorText != null) ...[
          const Gap(AppSpacing.xs),
          Text(
            errorText!,
            style: AppTypography.labelSmall.copyWith(color: AppColors.error),
          ),
        ],
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
