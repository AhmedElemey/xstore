import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

import '../../../../core/constants/app_spacing.dart';
import '../../../../core/utils/extensions/context_extensions.dart';

class ProductDescription extends StatelessWidget {
  const ProductDescription({
    super.key,
    required this.text,
    required this.expanded,
    required this.onToggle,
  });

  final String text;
  final bool expanded;
  final VoidCallback onToggle;

  static const _collapsedLines = 2;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bodyStyle = (theme.textTheme.bodyMedium ?? const TextStyle())
        .copyWith(
          color: theme.colorScheme.onSurfaceVariant,
          height: 1.45,
          fontWeight: FontWeight.w400,
        );

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final showToggle = _exceedsLineLimit(
            text: text,
            style: bodyStyle,
            maxWidth: constraints.maxWidth,
            maxLines: _collapsedLines,
            textDirection: Directionality.of(context),
            textScaler: MediaQuery.textScalerOf(context),
            locale: Localizations.localeOf(context),
          );

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                context.l10n.description,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const Gap(AppSpacing.md),
              AnimatedSize(
                duration: const Duration(milliseconds: 280),
                curve: Curves.easeOutCubic,
                alignment: Alignment.topLeft,
                child: Text(
                  text,
                  maxLines: expanded ? null : _collapsedLines,
                  overflow: expanded
                      ? TextOverflow.visible
                      : TextOverflow.ellipsis,
                  style: bodyStyle,
                ),
              ),
              if (showToggle) ...[
                const Gap(AppSpacing.sm),
                GestureDetector(
                  onTap: onToggle,
                  child: Text(
                    expanded
                        ? '${context.l10n.readLess} ${context.arrowBack}'
                        : '${context.l10n.readMore} ${context.arrowForward}',
                    style: theme.textTheme.titleSmall?.copyWith(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ],
          );
        },
      ),
    );
  }
}

bool _exceedsLineLimit({
  required String text,
  required TextStyle style,
  required double maxWidth,
  required int maxLines,
  required TextDirection textDirection,
  required TextScaler textScaler,
  required Locale locale,
}) {
  if (!maxWidth.isFinite || text.isEmpty) return false;

  final painter = TextPainter(
    text: TextSpan(text: text, style: style),
    maxLines: maxLines,
    textDirection: textDirection,
    textScaler: textScaler,
    locale: locale,
  )..layout(maxWidth: maxWidth);
  final exceeds = painter.didExceedMaxLines;
  painter.dispose();
  return exceeds;
}
