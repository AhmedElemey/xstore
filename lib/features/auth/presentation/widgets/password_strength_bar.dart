import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/utils/extensions/context_extensions.dart';
import '../../../../core/utils/validators.dart';
import '../../../../shared/widgets/orbit_widgets.dart';

int _rulesMet(String password) {
  final r = Validators.passwordRules(password);
  return [r.length, r.lower, r.upper, r.digit, r.symbol].where((m) => m).length;
}

/// Four-segment strength meter under a new-password field: red, amber, then
/// green as more of the password rules are met.
class PasswordStrengthBar extends StatelessWidget {
  const PasswordStrengthBar({super.key, required this.password});

  final String password;

  @override
  Widget build(BuildContext context) {
    final met = password.isEmpty ? 0 : _rulesMet(password);
    final filled = (met * 4 / 5).round();
    final color = filled <= 1
        ? AppColors.error
        : filled == 2
            ? context.cashColor
            : AppColors.success;
    return ExcludeSemantics(
      child: Row(
        children: [
          for (var i = 0; i < 4; i++) ...[
            if (i > 0) const SizedBox(width: 6),
            Expanded(
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                height: 4,
                decoration: BoxDecoration(
                  color: i < filled ? color : context.borderColor,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Glass checklist of the password rules, ticking each one as it is met.
class PasswordRulesCard extends StatelessWidget {
  const PasswordRulesCard({super.key, required this.password});

  final String password;

  @override
  Widget build(BuildContext context) {
    final r = Validators.passwordRules(password);
    final l10n = context.l10n;
    final rules = [
      (r.length, l10n.passwordRuleLength),
      (r.lower, l10n.passwordRuleLower),
      (r.digit, l10n.passwordRuleNumber),
      (r.upper, l10n.passwordRuleUpper),
      (r.symbol, l10n.passwordRuleSymbol),
    ];
    return GlassCard(
      radius: 20,
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (var i = 0; i < rules.length; i++) ...[
            if (i > 0) const SizedBox(height: 10),
            Text(
              '${rules[i].$1 ? '✓' : '○'}  ${rules[i].$2}',
              style: AppTypography.bodyMedium.copyWith(
                color: rules[i].$1 ? AppColors.success : context.textSecondary,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
