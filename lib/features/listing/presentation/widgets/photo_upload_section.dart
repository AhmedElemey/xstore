import 'dart:io';

import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/utils/extensions/context_extensions.dart';

/// Horizontal photo strip: add tile, previews, reorder via long-press drag.
class PhotoUploadSection extends StatelessWidget {
  const PhotoUploadSection({
    super.key,
    required this.paths,
    required this.errorText,
    required this.onOpenPicker,
    required this.onRemove,
    required this.onReorder,
  });

  final List<String> paths;
  final String? errorText;
  final VoidCallback onOpenPicker;
  final void Function(int index) onRemove;
  final void Function(int fromIndex, int toIndex) onReorder;

  static const double tile = 100;

  /// Wider than [tile] so icon + localized label fit in one row.
  static const double addPhotoTileWidth = 152;

  @override
  Widget build(BuildContext context) {
    final showAdd = paths.length < 5;
    final hasError = errorText != null && errorText!.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          context.l10n.listingPhotoSectionTitle,
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        const Gap(AppSpacing.sm),
        Text(
          context.l10n.listingPhotoSectionSubtitle,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
        const Gap(AppSpacing.lg),
        SizedBox(
          height: tile + 8,
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (var i = 0; i < paths.length; i++)
                  Padding(
                    padding: const EdgeInsets.only(right: AppSpacing.md),
                    child: _PhotoTile(
                      path: paths[i],
                      index: i,
                      isCover: i == 0,
                      onRemove: () => onRemove(i),
                      onReorder: onReorder,
                    ),
                  ),
                if (showAdd)
                  Padding(
                    padding: const EdgeInsets.only(right: AppSpacing.md),
                    child: _AddPhotoTile(
                      width: addPhotoTileWidth,
                      height: tile,
                      onTap: onOpenPicker,
                    ),
                  ),
              ],
            ),
          ),
        ),
        if (hasError)
          Padding(
            padding: EdgeInsets.only(
              top: context.scaledPx(6),
              left: context.scaledPx(4),
            ),
            child: Text(
              errorText!,
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: AppColors.error),
            ),
          ),
      ],
    );
  }
}

class _AddPhotoTile extends StatelessWidget {
  const _AddPhotoTile({
    required this.width,
    required this.height,
    required this.onTap,
  });

  final double width;
  final double height;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: CustomPaint(
          foregroundPainter: _DashedBorderPainter(
            color: context.textDisabled,
            radius: 12,
          ),
          child: SizedBox(
            width: width,
            height: height,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: context.scaledPx(10)),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Icon(
                    LucideIcons.badgePlus,
                    color: context.iconSecondary,
                    size: 24,
                  ),
                  SizedBox(width: context.scaledPx(8)),
                  Expanded(
                    child: Text(
                      context.l10n.listingAddPhotoTile,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.start,
                      style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        color: context.textPrimary,
                        fontWeight: FontWeight.w600,
                        height: 1.2,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _PhotoTile extends StatelessWidget {
  const _PhotoTile({
    required this.path,
    required this.index,
    required this.isCover,
    required this.onRemove,
    required this.onReorder,
  });

  final String path;
  final int index;
  final bool isCover;
  final VoidCallback onRemove;
  final void Function(int from, int to) onReorder;

  @override
  Widget build(BuildContext context) {
    return LongPressDraggable<int>(
      data: index,
      feedback: Material(
        elevation: 6,
        borderRadius: BorderRadius.circular(12),
        clipBehavior: Clip.antiAlias,
        child: SizedBox(
          width: PhotoUploadSection.tile,
          height: PhotoUploadSection.tile,
          child: Image.file(File(path), fit: BoxFit.cover),
        ),
      ),
      childWhenDragging: Opacity(
        opacity: 0.35,
        child: _buildFrame(context, dragTarget: false),
      ),
      child: DragTarget<int>(
        onAcceptWithDetails: (details) {
          onReorder(details.data, index);
        },
        builder: (context, candidate, _) {
          final active = candidate.isNotEmpty;
          return _buildFrame(context, dragTarget: active);
        },
      ),
    );
  }

  Widget _buildFrame(BuildContext context, {required bool dragTarget}) {
    return Container(
      width: PhotoUploadSection.tile,
      height: PhotoUploadSection.tile,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: dragTarget ? AppColors.primary : AppColors.transparent,
          width: 2,
        ),
        boxShadow: dragTarget
            ? [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.25),
                  blurRadius: 8,
                ),
              ]
            : null,
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Semantics(
            label:
                '${context.l10n.listingPhotoSectionTitle} ${index + 1}',
            image: true,
            child: Image.file(File(path), fit: BoxFit.cover),
          ),
          if (isCover)
            Positioned(
              left: 6,
              bottom: 6,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: AppSpacing.xs),
                decoration: BoxDecoration(
                  color: AppColors.materialGreen600,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  context.l10n.listingPhotoCoverBadge,
                  style: TextStyle(
                    color: AppColors.white,
                    fontSize: AppTypography.rem(0.6875),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          Positioned(
            top: AppSpacing.xs,
            right: AppSpacing.xs,
            child: Tooltip(
              message: MaterialLocalizations.of(context).deleteButtonTooltip,
              child: Material(
                color: AppColors.error,
                shape: const CircleBorder(),
                clipBehavior: Clip.antiAlias,
                child: InkWell(
                  onTap: onRemove,
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.xs),
                    child: Icon(
                      LucideIcons.x,
                      color: context.surfaceColor,
                      size: AppSpacing.lg,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DashedBorderPainter extends CustomPainter {
  _DashedBorderPainter({required this.color, required this.radius});

  final Color color;
  final double radius;

  @override
  void paint(Canvas canvas, Size size) {
    final r = RRect.fromRectAndRadius(
      Offset.zero & size,
      Radius.circular(radius),
    );
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    final path = Path()..addRRect(r);
    canvas.drawPath(_dashPath(path, 6, 4), paint);
  }

  Path _dashPath(Path source, double dash, double gap) {
    final metrics = source.computeMetrics();
    final out = Path();
    for (final m in metrics) {
      var d = 0.0;
      while (d < m.length) {
        final next = d + dash;
        out.addPath(
          m.extractPath(d, next > m.length ? m.length : next),
          Offset.zero,
        );
        d = next + gap;
      }
    }
    return out;
  }

  @override
  bool shouldRepaint(covariant _DashedBorderPainter oldDelegate) =>
      oldDelegate.color != color || oldDelegate.radius != radius;
}
