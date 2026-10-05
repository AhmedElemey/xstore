import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:gap/gap.dart';

import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/constants/prefs_keys.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/utils/extensions/context_extensions.dart';
import '../../../../shared/providers/shared_providers.dart';
import '../../../../shared/utils/location_permission_prompt.dart';
import '../../../../shared/widgets/orbit_background.dart';
import '../providers/auth_provider.dart';
import '../providers/guest_mode_provider.dart';
import '../widgets/auth_header.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _logoController;
  late final Animation<double> _logoScale;
  late final Animation<double> _taglineOpacity;

  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    _logoController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _logoScale = CurvedAnimation(
      parent: _logoController,
      curve: Curves.easeOutCubic,
    );
    _taglineOpacity = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _logoController,
        curve: const Interval(0.5, 1, curve: Curves.easeOut),
      ),
    );
    _logoController.forward();
    WidgetsBinding.instance.addPostFrameCallback((_) => _bootstrap());
  }

  Future<void> _bootstrap() async {
    final minDelay = Future<void>.delayed(const Duration(milliseconds: 2500));
    final authWait = ref.read(authProvider.future);
    await Future.wait<void>([minDelay, authWait]);

    if (!mounted) return;

    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

    // Runs on every cold start regardless of login state — the rationale
    // popup is "first time the app is ever opened", not "first time
    // logged in". The persisted flag makes this a no-op after the first
    // launch; the location auto-fill itself still only applies once a
    // session exists (see autoDetectAndFillLocationIfMissing).
    await maybeShowLocationPermissionPrompt(context, ref);
    if (!mounted) return;

    final prefs = await ref.read(sharedPreferencesProvider.future);
    if (!mounted) return;

    final user = ref.read(authProvider).valueOrNull;
    if (user != null) {
      // A restored session means this device already passed first-run.
      // Write the flag so a later logout/cold start cannot re-show
      // onboarding (e.g. iOS keychain survived reinstall, prefs did not).
      await prefs.setBool(PrefsKeys.onboardingComplete, true);
      if (!mounted) return;
      context.go(AppRoutes.home);
      return;
    }

    // Returning guest: re-enter browse mode directly. enable() sets the
    // provider state synchronously, so the router redirect sees it before
    // the navigation below is evaluated.
    if (prefs.getBool(PrefsKeys.guestMode) ?? false) {
      await prefs.setBool(PrefsKeys.onboardingComplete, true);
      await ref.read(guestModeProvider.notifier).enable();
      if (!mounted) return;
      context.go(AppRoutes.home);
      return;
    }

    final done = prefs.getBool(PrefsKeys.onboardingComplete) ?? false;
    if (done) {
      context.go(AppRoutes.login);
    } else {
      context.go(AppRoutes.onboarding);
    }
  }

  @override
  void dispose() {
    _logoController.dispose();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final gradient = context.brandGradient;
    return Scaffold(
      body: OrbitBackground(
        child: Stack(
          children: [
            // Planet with its orbit rings, centered in the upper sky.
            Align(
              alignment: const Alignment(0, -0.42),
              child: ScaleTransition(
                scale: Tween<double>(begin: 0.85, end: 1).animate(_logoScale),
                child: SizedBox(
                  width: 390,
                  height: 360,
                  child: CustomPaint(
                    foregroundPainter: _OrbitRingsPainter(
                      isDark: context.isDark,
                    ),
                    child: const Center(child: OrbitPlanet(size: 200)),
                  ),
                ),
              ),
            ),
            SafeArea(
              child: Padding(
                padding: const EdgeInsetsDirectional.fromSTEB(28, 0, 28, 44),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const AuthWordmark(size: 48),
                    const Gap(AppSpacing.spacing10),
                    FadeTransition(
                      opacity: _taglineOpacity,
                      child: Text(
                        context.l10n.tagline,
                        style: AppTypography.bodyLarge.copyWith(
                          fontSize: AppTypography.rem(1.0625),
                          height: 1.5,
                          color: context.textSecondary,
                        ),
                      ),
                    ),
                    const Gap(AppSpacing.spacing28),
                    // Thin gradient progress line, filled over the minimum
                    // splash time; it holds full if auth takes longer.
                    Container(
                      height: 4,
                      decoration: BoxDecoration(
                        color: context.isDark
                            ? AppColors.white.withValues(alpha: 0.08)
                            : AppColors.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(2),
                      ),
                      alignment: AlignmentDirectional.centerStart,
                      child: TweenAnimationBuilder<double>(
                        tween: Tween(begin: 0, end: 1),
                        duration: const Duration(milliseconds: 2400),
                        curve: Curves.easeOutCubic,
                        builder: (context, v, child) => FractionallySizedBox(
                          widthFactor: v,
                          heightFactor: 1,
                          child: child,
                        ),
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(colors: gradient),
                            borderRadius: BorderRadius.circular(2),
                            boxShadow: [
                              BoxShadow(color: gradient.first, blurRadius: 12),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// The two orbit rings around the splash planet (a solid glowing ellipse and
/// a dashed one) plus two small moons, drawn over a 390×360 box.
class _OrbitRingsPainter extends CustomPainter {
  const _OrbitRingsPainter({required this.isDark});

  final bool isDark;

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final ring = isDark ? AppColors.primaryLight : AppColors.primary;

    // Solid ring: 350×70, tilted -14°.
    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(-14 * math.pi / 180);
    final solid = Rect.fromCenter(center: Offset.zero, width: 350, height: 70);
    canvas.drawOval(
      solid,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4
        ..color = ring.withValues(alpha: 0.25)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8),
    );
    canvas.drawOval(
      solid,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5
        ..color = ring.withValues(alpha: 0.6),
    );
    canvas.restore();

    // Dashed ring: 390×150, tilted 8°.
    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(8 * math.pi / 180);
    final dashed = Rect.fromCenter(
      center: Offset.zero,
      width: 390,
      height: 150,
    );
    final dashPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1
      ..color = AppColors.darkSecondary.withValues(alpha: 0.35);
    const dashes = 90;
    const step = 2 * math.pi / dashes;
    for (var i = 0; i < dashes; i++) {
      canvas.drawArc(dashed, i * step, step / 2, false, dashPaint);
    }
    canvas.restore();

    // Moons: an amber one on the left, a small brand-colored one on the right.
    _moon(
      canvas,
      Offset(center.dx - 144, center.dy + 23),
      7,
      AppColors.accentLight,
      isDark ? AppColors.accentLight : AppColors.warning,
    );
    _moon(canvas, Offset(center.dx + 135, center.dy - 30), 4, ring, ring);
  }

  void _moon(Canvas canvas, Offset at, double r, Color color, Color glow) {
    canvas.drawCircle(
      at,
      r * 1.8,
      Paint()
        ..color = glow.withValues(alpha: 0.6)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, r * 1.3),
    );
    canvas.drawCircle(at, r, Paint()..color = color);
  }

  @override
  bool shouldRepaint(_OrbitRingsPainter oldDelegate) =>
      oldDelegate.isDark != isDark;
}
