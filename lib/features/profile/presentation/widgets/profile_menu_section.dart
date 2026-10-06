import 'package:flutter/material.dart';

import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/utils/extensions/context_extensions.dart';

class ProfileMenuSection extends StatelessWidget {
  const ProfileMenuSection({
    super.key,
    required this.title,
    required this.children,
  });

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (title.isNotEmpty)
          Padding(
            padding: const EdgeInsetsDirectional.only(
              start: AppSpacing.xs,
              bottom: AppSpacing.sm,
            ),
            child: Text(
              title.toUpperCase(),
              style: AppTypography.fieldLabel.copyWith(
                color: context.labelColor,
              ),
            ),
          ),
        Container(
          decoration: BoxDecoration(
            color: context.glassColor,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: context.borderColor),
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            children: [
              for (var i = 0; i < children.length; i++) ...[
                children[i],
                if (i < children.length - 1)
                  Padding(
                    padding: const EdgeInsetsDirectional.only(
                      start: 64,
                      end: AppSpacing.lg,
                    ),
                    child: Divider(height: 1, color: context.borderColor),
                  ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}
