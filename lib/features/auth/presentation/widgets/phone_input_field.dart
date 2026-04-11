import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gap/gap.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/utils/extensions/context_extensions.dart';

class PhoneInputField extends StatelessWidget {
  const PhoneInputField({
    super.key,
    required this.controller,
    required this.onChanged,
    this.errorText,
    this.enabled = true,
  });

  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final String? errorText;
  final bool enabled;

  String _normalizeEgyptInput(String value) {
    final digits = value.replaceAll(RegExp(r'\D'), '');
    if (digits.startsWith('1')) {
      return digits.replaceFirst('1', '01');
    }
    return digits;
  }

  @override
  Widget build(BuildContext context) {
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
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            child: Container(
              decoration: BoxDecoration(
                 color: Colors.transparent,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: errorText != null ? AppColors.error : context.borderColor,
                  width: 1.5,
                ),
              ),
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              child: TextFormField(
                controller: controller,
                onChanged: (value) {
                  final normalized = _normalizeEgyptInput(value);
                  if (controller.text != normalized) {
                    controller.value = TextEditingValue(
                      text: normalized,
                      selection: TextSelection.collapsed(
                        offset: normalized.length,
                      ),
                    );
                  }
                  onChanged(normalized);
                },
                enabled: enabled,
                keyboardType: TextInputType.phone,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(11),
                ],
                style: AppTypography.bodyLarge.copyWith(color: context.textPrimary),
                decoration: InputDecoration(
                  fillColor:  Colors.transparent,
                  hintText: '01012345678',
                  prefixIcon: const Padding(
                    padding: EdgeInsets.only(right: 8),
                    child: Icon(LucideIcons.phone),
                  ),
                  prefixIconConstraints:
                      const BoxConstraints(minWidth: 24, minHeight: 24),
                  prefixText: '🇪🇬 +20 ',
                  prefixStyle: AppTypography.bodyMedium.copyWith(
                    color: context.textPrimary,
                    
                    fontWeight: FontWeight.w600,
                  ),
                
                  suffixIcon: controller.text.isNotEmpty
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
                      : null,
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  disabledBorder: InputBorder.none,
                  errorBorder: InputBorder.none,
                  focusedErrorBorder: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 14),
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
