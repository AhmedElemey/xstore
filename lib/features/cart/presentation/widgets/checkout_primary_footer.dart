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
    return DecoratedBox(
      decoration: BoxDecoration(
        color: context.surfaceColor.withValues(alpha: 0.96),
        border: Border(top: BorderSide(color: context.borderColor)),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          AppSpacing.xl,
          AppSpacing.lg,
          AppSpacing.xl,
          AppSpacing.lg + MediaQuery.paddingOf(context).bottom,
        ),
        child: SizedBox(
          width: double.infinity,
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
        ),
      ),
    );
  }
}
