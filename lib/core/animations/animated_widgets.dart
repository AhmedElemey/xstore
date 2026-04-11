import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../constants/app_spacing.dart';
import '../constants/app_typography.dart';
import 'app_animations.dart';

/// Press feedback: scale down while pointer is down.
class AnimatedTap extends StatefulWidget {
  const AnimatedTap({
    super.key,
    required this.onTap,
    required this.child,
    this.scale = AppAnimations.scalePressed,
    this.duration = AppAnimations.fast,
    this.enabled = true,
  });

  final VoidCallback? onTap;
  final Widget child;
  final double scale;
  final Duration duration;
  final bool enabled;

  @override
  State<AnimatedTap> createState() => _AnimatedTapState();
}

class _AnimatedTapState extends State<AnimatedTap>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    );
    _scale = Tween<double>(begin: 1.0, end: widget.scale).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.enabled) return widget.child;

    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTapDown: (_) {
        if (!mounted) return;
        _controller.forward();
      },
      onTapUp: (_) {
        final cb = widget.onTap;
        cb?.call();
        if (mounted) _controller.reverse();
      },
      onTapCancel: () {
        if (mounted) _controller.reverse();
      },
      child: AnimatedBuilder(
        animation: _scale,
        builder: (_, child) => Transform.scale(
          scale: _scale.value,
          child: child,
        ),
        child: widget.child,
      ),
    );
  }
}

/// Fade + scale between visible and hidden states.
class AnimatedVisibilityWidget extends StatelessWidget {
  const AnimatedVisibilityWidget({
    super.key,
    required this.visible,
    required this.child,
    this.duration = AppAnimations.normal,
  });

  final bool visible;
  final Widget child;
  final Duration duration;

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: duration,
      switchInCurve: AppAnimations.enter,
      switchOutCurve: AppAnimations.exit,
      transitionBuilder: (child, animation) => FadeTransition(
        opacity: animation,
        child: ScaleTransition(
          scale: Tween<double>(begin: 0.95, end: 1).animate(animation),
          child: child,
        ),
      ),
      child: visible
          ? KeyedSubtree(
              key: const ValueKey<String>('visible'),
              child: child,
            )
          : SizedBox.shrink(
              key: const ValueKey<String>('hidden'),
            ),
    );
  }
}

/// Integer labels that ease to the new value.
class AnimatedCounter extends StatelessWidget {
  const AnimatedCounter({
    super.key,
    required this.value,
    required this.style,
    this.duration = AppAnimations.normal,
    this.prefix = '',
    this.suffix = '',
  });

  final int value;
  final TextStyle style;
  final Duration duration;
  final String prefix;
  final String suffix;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<int>(
      tween: IntTween(end: value),
      duration: duration,
      curve: AppAnimations.smooth,
      builder: (_, val, __) => Text(
        '$prefix$val$suffix',
        style: style,
      ),
    );
  }
}

/// Vertical list of children with staggered entry (lightweight).
class StaggeredList extends StatelessWidget {
  const StaggeredList({
    super.key,
    required this.children,
    this.direction = Axis.vertical,
  });

  final List<Widget> children;
  final Axis direction;

  @override
  Widget build(BuildContext context) {
    final animated = children.asMap().entries.map((entry) {
      return entry.value
          .animate(
            delay: AppAnimations.staggerDelay(entry.key),
          )
          .fadeIn(
            duration: AppAnimations.normal,
            curve: AppAnimations.enter,
          )
          .slideY(
            begin: 0.1,
            end: 0,
            duration: AppAnimations.normal,
            curve: AppAnimations.enter,
          );
    }).toList();

    return direction == Axis.horizontal
        ? Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: animated,
          )
        : Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: animated,
          );
  }
}

/// Status pill with smooth color transitions.
class AnimatedStatusBadge extends StatelessWidget {
  const AnimatedStatusBadge({
    super.key,
    required this.label,
    required this.color,
  });

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<Color?>(
      tween: ColorTween(end: color),
      duration: AppAnimations.medium,
      curve: AppAnimations.smooth,
      builder: (_, animColor, __) {
        final c = animColor ?? color;
        return Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.sm,
            vertical: AppSpacing.xs,
          ),
          decoration: BoxDecoration(
            color: c.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: c.withValues(alpha: 0.4)),
          ),
          child: Text(
            label,
            style: AppTypography.labelSmall.copyWith(
              color: c,
              fontWeight: FontWeight.w600,
            ),
          ),
        );
      },
    );
  }
}
