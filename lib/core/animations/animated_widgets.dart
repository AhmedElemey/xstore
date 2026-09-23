import 'package:flutter/material.dart';

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

