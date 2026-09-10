import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../core/constants/app_spacing.dart';
import '../../core/utils/extensions/context_extensions.dart';
import 'xstore_button.dart';

class ErrorStateWidget extends StatelessWidget {
  const ErrorStateWidget({
    super.key,
    required this.message,
    this.onRetry,
    this.retryLabel,
  });

  final String message;
  final VoidCallback? onRetry;

  /// Falls back to the localized default when omitted, since a `const`
  /// constructor default can't call `context.l10n`.
  final String? retryLabel;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.x2l),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              LucideIcons.alertCircle,
              size: AppSpacing.x4l,
              color: theme.colorScheme.error,
            ),
            const Gap(AppSpacing.lg),
            Text(
              message,
              style: theme.textTheme.bodyLarge,
              textAlign: TextAlign.center,
            ),
            if (onRetry != null) ...[
              const Gap(AppSpacing.lg),
              XstoreButton(
                label: retryLabel ?? context.l10n.retry,
                onPressed: onRetry,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
