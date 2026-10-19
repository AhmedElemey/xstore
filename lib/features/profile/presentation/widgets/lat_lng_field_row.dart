import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gap/gap.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/utils/extensions/context_extensions.dart';

class LatLngFieldRow extends StatelessWidget {
  const LatLngFieldRow({
    super.key,
    required this.latController,
    required this.lngController,
    required this.onLatChanged,
    required this.onLngChanged,
    this.latError,
    this.lngError,
  });

  final TextEditingController latController;
  final TextEditingController lngController;
  final ValueChanged<String> onLatChanged;
  final ValueChanged<String> onLngChanged;
  final String? latError;
  final String? lngError;

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.ltr,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: _CoordField(
              label: context.l10n.latitude,
              controller: latController,
              hint: context.l10n.latitudeHint,
              onChanged: onLatChanged,
              errorText: latError,
              prefixIcon: LucideIcons.arrowUpDown,
            ),
          ),
          const Gap(AppSpacing.sm),
          Expanded(
            child: _CoordField(
              label: context.l10n.longitude,
              controller: lngController,
              hint: context.l10n.longitudeHint,
              onChanged: onLngChanged,
              errorText: lngError,
              prefixIcon: LucideIcons.arrowLeftRight,
            ),
          ),
        ],
      ),
    );
  }
}

class _CoordField extends StatelessWidget {
  const _CoordField({
    required this.label,
    required this.controller,
    required this.hint,
    required this.onChanged,
    required this.prefixIcon,
    required this.errorText,
  });

  final String label;
  final TextEditingController controller;
  final String hint;
  final ValueChanged<String> onChanged;
  final IconData prefixIcon;
  final String? errorText;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label.toUpperCase(), style: AppTypography.fieldLabel.copyWith(color: context.labelColor)),
        SizedBox(height: context.scaledPx(8)),
        TextField(
          controller: controller,
          onChanged: onChanged,
          keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: true),
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'[0-9.\-]')),
            LengthLimitingTextInputFormatter(10),
          ],
          style: AppTypography.mono.copyWith(
            fontSize: 15,
            color: context.textPrimary,
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: AppTypography.mono.copyWith(fontSize: 15, color: context.textHint),
            prefixIcon: Icon(prefixIcon, size: 16),
            prefixIconColor: context.iconSecondary,
            // Fields keep the theme's frosted border; an invalid value swaps
            // in the error border (the message itself is shown below).
            enabledBorder: errorText != null ? Theme.of(context).inputDecorationTheme.errorBorder : null,
          ),
        ),
        if (errorText != null) ...[
          const Gap(AppSpacing.xs),
          Text(errorText!, style: AppTypography.bodySmall.copyWith(color: AppColors.error)),
        ],
      ],
    );
  }
}

