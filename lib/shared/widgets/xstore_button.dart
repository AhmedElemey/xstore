import 'package:flutter/material.dart';

import '../../core/constants/app_spacing.dart';
import '../../core/animations/app_animations.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_typography.dart';

class XstoreButton extends StatefulWidget {
  const XstoreButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.isLoading = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;

  @override
  State<XstoreButton> createState() => _XstoreButtonState();
}

class _XstoreButtonState extends State<XstoreButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pressController;
  late final Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _pressController = AnimationController(
      vsync: this,
      duration: AppAnimations.fast,
    );
    _scaleAnim = Tween<double>(begin: 1.0, end: AppAnimations.scalePressed)
        .animate(
      CurvedAnimation(parent: _pressController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pressController.dispose();
    super.dispose();
  }

  bool get _enabled => !widget.isLoading && widget.onPressed != null;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      enabled: _enabled,
      label: widget.label,
      child: Tooltip(
        message: widget.label,
        child: AnimatedBuilder(
          animation: _scaleAnim,
          builder: (_, child) => Transform.scale(
            scale: _scaleAnim.value,
            child: child,
          ),
          child: Material(
            color: AppColors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: _enabled
                  ? () {
                      _pressController.reverse();
                      widget.onPressed?.call();
                    }
                  : null,
              onTapDown: _enabled ? (_) => _pressController.forward() : null,
              onTapCancel: _enabled ? () => _pressController.reverse() : null,
              child: AnimatedContainer(
                duration: AppAnimations.normal,
                curve: AppAnimations.smooth,
                height: 56,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  gradient: widget.isLoading
                      ? null
                      : const LinearGradient(
                          colors: [AppColors.primary, AppColors.accent],
                        ),
                  color: widget.isLoading
                      ? Theme.of(context).colorScheme.surfaceContainerHighest
                      : null,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: widget.isLoading
                      ? null
                      : [
                          BoxShadow(
                            color: AppColors.primary.withValues(alpha: 0.3),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                ),
                child: AnimatedSwitcher(
                  duration: AppAnimations.fast,
                  transitionBuilder: (child, anim) => FadeTransition(
                    opacity: anim,
                    child: child,
                  ),
                  child: widget.isLoading
                      ? const SizedBox(
                          key: ValueKey<String>('loading'),
                          height: 24,
                          width: 24,
                          child: CircularProgressIndicator(
                            color: AppColors.white,
                            strokeWidth: 2.5,
                          ),
                        )
                      : Padding(
                          key: const ValueKey<String>('label'),
                          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
                          child: Text(
                            widget.label,
                            textAlign: TextAlign.center,
                            style: AppTypography.labelLarge.copyWith(
                              color: AppColors.white,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
