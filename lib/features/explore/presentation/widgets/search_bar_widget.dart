import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/utils/extensions/context_extensions.dart';

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
            hintText: context.l10n.exploreSearchPlaceholder,
            hintStyle: AppTypography.body15.copyWith(color: context.labelColor),
            prefixIcon: Icon(LucideIcons.search, color: context.linkColor),
            suffixIcon: v.text.isEmpty
                ? null
                : IconButton(
                    onPressed: onClear,
                    icon: Icon(LucideIcons.x, color: context.textSecondary),
                  ),
            filled: true,
            fillColor: context.glassColor,
            border: _border(context.borderColor),
            enabledBorder: _border(context.borderColor),
            focusedBorder: _border(context.linkColor, width: 1.5),
            contentPadding: EdgeInsetsDirectional.symmetric(
              horizontal: context.scaledPx(AppSpacing.lg),
              vertical: context.scaledPx(AppSpacing.md),
            ),
          ),
        );
      },
    );
  }

  static OutlineInputBorder _border(Color color, {double width = 1}) =>
      OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppSpacing.x2l + AppSpacing.xs),
        borderSide: BorderSide(color: color, width: width),
      );
}
