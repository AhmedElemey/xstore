import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/constants/app_spacing.dart';
import '../../../../core/utils/extensions/context_extensions.dart';
import '../../../../shared/widgets/xstore_button.dart';

class CheckoutPrimaryFooter extends StatelessWidget {
  const CheckoutPrimaryFooter({
    super.key,
    required this.label,
    required this.busy,
    required this.onPressed,
  });

  final String label;
  final bool busy;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.md,
        AppSpacing.lg,
        AppSpacing.md + MediaQuery.paddingOf(context).bottom,
      ),
      decoration: BoxDecoration(
        color: context.surfaceColor,
        boxShadow: [
          BoxShadow(
            color: context.textPrimary.withValues(alpha: 0.08),
            blurRadius: AppSpacing.md,
            offset: const Offset(0, -AppSpacing.xs),
          ),
        ],
      ),
      child: XstoreButton(
        label: label,
        isLoading: busy,
        onPressed: busy || onPressed == null
            ? null
            : () {
                HapticFeedback.lightImpact();
                onPressed!();
              },
      ),
    );
  }
}
