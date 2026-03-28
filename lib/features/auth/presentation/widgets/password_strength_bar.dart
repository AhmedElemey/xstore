import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../providers/auth_states.dart';

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

  static String _label(PasswordStrength s) {
    switch (s) {
      case PasswordStrength.none:
        return '';
      case PasswordStrength.weak:
        return 'Weak';
      case PasswordStrength.fair:
        return 'Fair';
      case PasswordStrength.good:
        return 'Good';
      case PasswordStrength.strong:
        return 'Strong';
    }
  }

  static List<Color> _segmentColors(PasswordStrength s) {
    switch (s) {
      case PasswordStrength.none:
        return [
          const Color(0xFFE5E7EB),
          const Color(0xFFE5E7EB),
          const Color(0xFFE5E7EB),
          const Color(0xFFE5E7EB),
        ];
      case PasswordStrength.weak:
        return [
          AppColors.error,
          const Color(0xFFE5E7EB),
          const Color(0xFFE5E7EB),
          const Color(0xFFE5E7EB),
        ];
      case PasswordStrength.fair:
        return [
          AppColors.error,
          AppColors.warning,
          const Color(0xFFE5E7EB),
          const Color(0xFFE5E7EB),
        ];
      case PasswordStrength.good:
        return [
          AppColors.error,
          AppColors.warning,
          const Color(0xFFEAB308),
          const Color(0xFFE5E7EB),
        ];
      case PasswordStrength.strong:
        return [
          AppColors.success,
          AppColors.success,
          AppColors.success,
          AppColors.success,
        ];
    }
  }

  @override
  Widget build(BuildContext context) {
    final strength = _strengthFor(password);
    final filled = _filledSegments(strength);
    final colors = _segmentColors(strength);
    final label = _label(strength);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: List.generate(4, (i) {
            final active = i < filled;
            return Expanded(
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeOut,
                margin: EdgeInsets.only(right: i < 3 ? 6 : 0),
                height: 6,
                decoration: BoxDecoration(
                  color: active ? colors[i] : const Color(0xFFE5E7EB),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            );
          }),
        ),
        if (label.isNotEmpty) ...[
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: strength == PasswordStrength.strong
                  ? AppColors.success
                  : AppColors.textSecondary,
            ),
          ),
        ],
        const SizedBox(height: 12),
        _RequirementRow(
          met: password.length >= 8,
          text: 'At least 8 characters',
        ),
        _RequirementRow(
          met: RegExp(r'[A-Z]').hasMatch(password),
          text: 'One uppercase letter',
        ),
        _RequirementRow(
          met: RegExp(r'[0-9]').hasMatch(password),
          text: 'One number',
        ),
        _RequirementRow(
          met: RegExp(r'''[!@#$%^&*(),.?":{}|<>_\-+=\[\]\\/;`~']''')
              .hasMatch(password),
          text: 'One special character (!@#\$...)',
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
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Icon(
            met ? Icons.check_circle : Icons.circle_outlined,
            size: 18,
            color: met ? AppColors.success : AppColors.textDisabled,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 13,
                color: met ? AppColors.success : AppColors.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
