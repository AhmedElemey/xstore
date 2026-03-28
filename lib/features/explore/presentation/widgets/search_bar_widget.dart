import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/constants/app_typography.dart';

class SearchBarWidget extends StatelessWidget {
  const SearchBarWidget({
    super.key,
    required this.controller,
    required this.focusNode,
    required this.onChanged,
    required this.onClear,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final ValueChanged<String> onChanged;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<TextEditingValue>(
      valueListenable: controller,
      builder: (context, v, _) {
        return TextField(
          controller: controller,
          focusNode: focusNode,
          autofocus: true,
          onChanged: onChanged,
          textInputAction: TextInputAction.search,
          decoration: InputDecoration(
            hintText: AppStrings.exploreSearchPlaceholder,
            hintStyle:
                AppTypography.bodyMedium.copyWith(color: AppColors.textSecondary),
            prefixIcon: Icon(LucideIcons.search, color: AppColors.textSecondary),
            suffixIcon: v.text.isEmpty
                ? null
                : IconButton(
                    onPressed: onClear,
                    icon: Icon(LucideIcons.x, color: AppColors.textSecondary),
                  ),
            filled: true,
            fillColor: AppColors.cardBg,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppSpacing.md),
              borderSide: const BorderSide(color: AppColors.textDisabled),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppSpacing.md),
              borderSide: const BorderSide(color: AppColors.textDisabled),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppSpacing.md),
              borderSide: const BorderSide(color: AppColors.primary, width: 2),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.lg,
              vertical: AppSpacing.md,
            ),
          ),
        );
      },
    );
  }
}
