import 'package:flutter/material.dart';

/// Owns a repeating (reverse) [AnimationController] and hands its value to
/// [builder] — the shared lifecycle boilerplate (create in initState, dispose
/// in dispose) behind every "pulsing" effect in the app (scaling dots,
/// fading badges, swaying icons). Callers keep full control of what the
/// pulse actually looks like; only the controller plumbing is shared.
class PulsingAnimationBuilder extends StatefulWidget {
  const PulsingAnimationBuilder({
    super.key,
    required this.builder,
    this.duration = const Duration(milliseconds: 1200),
    this.child,
  });

  final Duration duration;
  final Widget? child;
  final Widget Function(
    BuildContext context,
    Animation<double> animation,
    Widget? child,
  ) builder;

  @override
  State<PulsingAnimationBuilder> createState() =>
      _PulsingAnimationBuilderState();
}

class _PulsingAnimationBuilderState extends State<PulsingAnimationBuilder>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration)
      ..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) => widget.builder(context, _controller, child),
      child: widget.child,
    );
  }
}
