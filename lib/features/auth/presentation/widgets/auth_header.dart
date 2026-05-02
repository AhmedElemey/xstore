import 'package:flutter/material.dart';

import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/utils/extensions/context_extensions.dart';

/// Gradient hero area for auth screens (logo + titles on indigo gradient).
class AuthHeader extends StatelessWidget {
  const AuthHeader({
    super.key,
    required this.heightFraction,
    required this.title,
    this.subtitle,
    this.showWave = false,
    this.logoSize = AppTypography.authWordmarkSize,
  });

  /// Fraction of screen height (e.g. 0.4 for login).
  final double heightFraction;
  final String title;
  final String? subtitle;
  final bool showWave;
  final double logoSize;

  static const _deepIndigo = AppColors.primaryDark;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final h = constraints.maxHeight * heightFraction;
        final content = Container(
          width: double.infinity,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                AppColors.primary,
                _deepIndigo,
              ],
            ),
          ),
          child: 
            
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.x2l),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'xStore',
                    style: TextStyle(
                      fontSize: logoSize,
                      fontWeight: FontWeight.w800,
                      color: AppColors.white,
                      letterSpacing: context.scaledPx(-0.5),
                      shadows: [
                        Shadow(
                          color: AppColors.white.withValues(alpha: 0.35),
                          blurRadius: 24,
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: context.scaledPx(12)),
                  Text(
                    title,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: AppColors.white,
                      fontSize: AppTypography.rem(1),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  if (subtitle != null) ...[
                    SizedBox(height: context.scaledPx(6)),
                    Text(
                      subtitle!,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: AppColors.white.withValues(alpha: 0.9),
                        fontSize: AppTypography.rem(0.875),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          
        );
        return SizedBox(
          height: h,
          width: double.infinity,
          child: showWave
              ? ClipPath(clipper: _WaveClipper(), child: content)
              : content,
        );
      },
    );
  }
}

class _WaveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.lineTo(0, size.height - 28);
    path.quadraticBezierTo(
      size.width * 0.1,
      size.height,
      size.width * 0.5,
      size.height - 18,
    );
    path.quadraticBezierTo(
      size.width * 0.75,
      size.height - 36,
      size.width,
      size.height - 22,
    );
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}
