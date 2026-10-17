import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/utils/extensions/context_extensions.dart';
import 'store_open_close_toggle.dart';

class StoreStatusBanner extends StatelessWidget {
  const StoreStatusBanner({
    super.key,
    required this.isOpen,
    required this.message,
    required this.onToggle,
    required this.onEditMessage,
  });

  final bool isOpen;
  final String? message;
  final VoidCallback onToggle;
  final VoidCallback onEditMessage;

  @override
  Widget build(BuildContext context) {
    final bg = isOpen
        ? (context.isDark ? const Color(0xFF052E16).withValues(alpha: 0.12) : const Color(0xFFECFDF5))
        : (context.isDark ? const Color(0xFF2D0707).withValues(alpha: 0.12) : const Color(0xFFFEF2F2));
    final border = isOpen ? AppColors.success : AppColors.error;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOut,
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: border, width: 2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            isOpen ? context.l10n.storeStatusOpen : context.l10n.storeStatusClosed,
            style: AppTypography.titleMedium.copyWith(color: border),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            isOpen ? context.l10n.storeOpenDesc : context.l10n.storeClosedDesc,
            style: AppTypography.bodyMedium.copyWith(color: context.textSecondary),
          ),
          if (!isOpen) ...[
            const SizedBox(height: AppSpacing.sm),
            InkWell(
              onTap: onEditMessage,
              child: Text(
                message?.isNotEmpty == true ? message! : context.l10n.closedMessage,
                style: AppTypography.bodySmall.copyWith(
                  color: context.textSecondary,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
          ],
          const SizedBox(height: AppSpacing.md),
          StoreOpenCloseToggle(isOpen: isOpen, onPressed: onToggle),
        ],
      ),
    );
  }
}

