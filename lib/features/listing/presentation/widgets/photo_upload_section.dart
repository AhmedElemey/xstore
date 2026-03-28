import 'dart:io';

import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';

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

  @override
  Widget build(BuildContext context) {
    final showAdd = paths.length < 5;
    final hasError = errorText != null && errorText!.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Product Photos',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const Gap(AppSpacing.sm),
        Text(
          'Add 1–5 photos (first = cover)',
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
                  _AddPhotoTile(
                    size: tile,
                    onTap: onOpenPicker,
                  ),
              ],
            ),
          ),
        ),
        if (hasError)
          Padding(
            padding: const EdgeInsets.only(top: 6, left: 4),
            child: Text(
              errorText!,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.error,
                  ),
            ),
          ),
      ],
    );
  }
}

class _AddPhotoTile extends StatelessWidget {
  const _AddPhotoTile({
    required this.size,
    required this.onTap,
  });

  final double size;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: CustomPaint(
          foregroundPainter: _DashedBorderPainter(
            color: AppColors.textDisabled,
            radius: 12,
          ),
          child: SizedBox(
            width: size,
            height: size,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(LucideIcons.plus, color: AppColors.textSecondary, size: 28),
                const SizedBox(height: 4),
                Text(
                  'Add Photo',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: Colors.grey.shade600,
                      ),
                ),
              ],
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
          color: dragTarget ? AppColors.primary : Colors.transparent,
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
          Image.file(
            File(path),
            fit: BoxFit.cover,
          ),
          if (isCover)
            Positioned(
              left: 6,
              bottom: 6,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.green.shade600,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  'Cover',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          Positioned(
            top: AppSpacing.xs,
            right: AppSpacing.xs,
            child: Material(
              color: AppColors.error,
              shape: const CircleBorder(),
              clipBehavior: Clip.antiAlias,
              child: InkWell(
                onTap: onRemove,
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.xs),
                  child: Icon(LucideIcons.x, color: AppColors.cardBg, size: AppSpacing.lg),
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
    canvas.drawPath(
      _dashPath(path, 6, 4),
      paint,
    );
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
