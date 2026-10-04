import 'package:flutter/material.dart';

/// Text clamped to [maxLines] when collapsed, with a [toggle] (e.g. Read
/// more / Read less) shown only when the text actually overflows [maxLines]
/// at the current width.
class ExpandableText extends StatelessWidget {
  const ExpandableText({
    super.key,
    required this.text,
    required this.maxLines,
    required this.expanded,
    required this.toggle,
    this.style,
  });

  final String text;
  final int maxLines;
  final bool expanded;
  final Widget toggle;
  final TextStyle? style;

  @override
  Widget build(BuildContext context) {
    final effectiveStyle = DefaultTextStyle.of(context).style.merge(style);
    final textScaler = MediaQuery.textScalerOf(context);
    final textDirection = Directionality.of(context);
    return LayoutBuilder(
      builder: (context, constraints) {
        final painter = TextPainter(
          text: TextSpan(text: text, style: effectiveStyle),
          maxLines: maxLines,
          textDirection: textDirection,
          textScaler: textScaler,
        )..layout(maxWidth: constraints.maxWidth);
        final overflows = painter.didExceedMaxLines;
        painter.dispose();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedSize(
              duration: const Duration(milliseconds: 260),
              curve: Curves.easeOutCubic,
              alignment: AlignmentDirectional.topStart,
              child: Text(
                text,
                maxLines: expanded ? null : maxLines,
                overflow:
                    expanded ? TextOverflow.visible : TextOverflow.ellipsis,
                style: style,
              ),
            ),
            if (overflows) toggle,
          ],
        );
      },
    );
  }
}
