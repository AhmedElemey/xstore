import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/extensions/context_extensions.dart';

class StoreOpenCloseToggle extends StatelessWidget {
  const StoreOpenCloseToggle({
    super.key,
    required this.isOpen,
    required this.onPressed,
  });

  final bool isOpen;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: onPressed,
      icon: Icon(isOpen ? Icons.cancel_outlined : Icons.check_circle_outline),
      style: OutlinedButton.styleFrom(
        foregroundColor: isOpen ? AppColors.error : AppColors.success,
        side: BorderSide(color: isOpen ? AppColors.error : AppColors.success),
      ),
      label: Text(isOpen ? context.l10n.closeStoreNow : context.l10n.openStoreNow),
    );
  }
}

