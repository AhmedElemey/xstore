import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_typography.dart';
import '../providers/auth_states.dart';
import '../../../../core/utils/extensions/context_extensions.dart';

class PasswordStrengthBar extends StatelessWidget {
  const PasswordStrengthBar({
    super.key,
    required this.password,
  });

  final String password;

  static PasswordStrength _strengthFor(String p) {
    if (p.isEmpty) return PasswordStrength.none;
    final hasUpper = RegExp(r'[A-Z]').hasMatch(p);
    final hasNum = RegExp(r'[0-9]').hasMatch(p);
    final hasSym =
        RegExp(r'''[!@#$%^&*(),.?":{}|<>_\-+=\[\]\\/;`~']''').hasMatch(p);
    if (p.length >= 8 && hasUpper && hasNum && hasSym) {
      return PasswordStrength.strong;
    }
    if (p.length >= 8 && (hasNum || hasSym)) {
      return PasswordStrength.good;
    }
    if (p.length >= 6) {
      return PasswordStrength.fair;
    }
    return PasswordStrength.weak;
  }

  static int _filledSegments(PasswordStrength s) {
    switch (s) {
      case PasswordStrength.none:
        return 0;
      case PasswordStrength.weak:
        return 1;
      case PasswordStrength.fair:
        return 2;
      case PasswordStrength.good:
        return 3;
      case PasswordStrength.strong:
        return 4;
    }
  }

  static String _label(BuildContext context, PasswordStrength s) {
    switch (s) {
      case PasswordStrength.none:
        return '';
      case PasswordStrength.weak:
        return context.l10n.passwordStrengthWeak;
      case PasswordStrength.fair:
        return context.l10n.passwordStrengthFair;
      case PasswordStrength.good:
        return context.l10n.passwordStrengthGood;
      case PasswordStrength.strong:
        return context.l10n.passwordStrengthStrong;
    }
  }

  /// Orbit: every filled segment takes the level's color — red, amber,
  /// then green.
  static Color _levelColor(BuildContext context, PasswordStrength s) {
    switch (s) {
      case PasswordStrength.none:
      case PasswordStrength.weak:
        return context.colorScheme.error;
      case PasswordStrength.fair:
        return context.amberColor;
      case PasswordStrength.good:
      case PasswordStrength.strong:
        return _successColor(context);
    }
  }

  static Color _successColor(BuildContext context) =>
      context.isDark ? AppColors.successLight : AppColors.success;

  @override
  Widget build(BuildContext context) {
    final strength = _strengthFor(password);
    final filled = _filledSegments(strength);
    final color = _levelColor(context, strength);
    final track = context.isDark
        ? AppColors.white.withValues(alpha: 0.12)
        : AppColors.primary.withValues(alpha: 0.14);
    final label = _label(context, strength);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: List.generate(4, (i) {
            return Expanded(
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeOut,
                margin: EdgeInsetsDirectional.only(end: i < 3 ? 6 : 0),
                height: 4,
                decoration: BoxDecoration(
                  color: i < filled ? color : track,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            );
          }),
        ),
        if (label.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.sm),
          Text(
            label,
            style: AppTypography.fieldLabel.copyWith(color: color),
          ),
        ],
        const SizedBox(height: AppSpacing.md),
        _RequirementRow(
          met: password.length >= 8,
          text: context.l10n.passwordRuleMinLength,
        ),
        _RequirementRow(
          met: RegExp(r'[A-Z]').hasMatch(password),
          text: context.l10n.passwordRuleUppercase,
        ),
        _RequirementRow(
          met: RegExp(r'[0-9]').hasMatch(password),
          text: context.l10n.passwordRuleNumber,
        ),
        _RequirementRow(
          met: RegExp(r'''[!@#$%^&*(),.?":{}|<>_\-+=\[\]\\/;`~']''')
              .hasMatch(password),
          text: context.l10n.passwordRuleSpecial,
        ),
      ],
    );
  }
}

class _RequirementRow extends StatelessWidget {
  const _RequirementRow({
    required this.met,
    required this.text,
  });

  final bool met;
  final String text;

  @override
  Widget build(BuildContext context) {
    final color = met
        ? PasswordStrengthBar._successColor(context)
        : context.textSecondary;
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          Icon(
            met ? LucideIcons.circleCheck : LucideIcons.circle,
            size: 16,
            color: color,
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              text,
              style: AppTypography.bodySmall.copyWith(color: color),
            ),
          ),
        ],
      ),
    );
  }
}
