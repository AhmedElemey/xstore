import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

import '../../../../core/constants/app_spacing.dart';

class FlashSaleBanner extends StatelessWidget {
  const FlashSaleBanner({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        gradient: LinearGradient(
          colors: [
            scheme.primary,
            scheme.secondary,
          ],
        ),
      ),
      child: Row(
        children: [
          const Icon(Icons.flash_on, color: Colors.white),
          const Gap(AppSpacing.sm),
          Expanded(
            child: Text(
              'Flash sale — limited time offers inside',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: Colors.white,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}
