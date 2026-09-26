import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shimmer/shimmer.dart';

import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/constants/prefs_keys.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/utils/extensions/context_extensions.dart';
import '../../../../shared/providers/shared_providers.dart';
import '../../../../shared/utils/location_permission_prompt.dart';
import '../../../../shared/widgets/space_background.dart';
import '../providers/auth_provider.dart';
import '../providers/guest_mode_provider.dart';

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
    return Scaffold(
      backgroundColor: AppColors.transparent,
      body: SpaceBackground(
        child: SizedBox.expand(
          child: Column(
            children: [
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ScaleTransition(
                        scale: Tween<double>(
                          begin: 0.85,
                          end: 1,
                        ).animate(_logoScale),
                        child: const _OrbitPlanet(),
                      ),
                      const SizedBox(height: AppSpacing.x2l),
                      ScaleTransition(
                        scale: Tween<double>(
                          begin: 0.85,
                          end: 1,
                        ).animate(_logoScale),
                        child: Text(
                          'xStore',
                          style: AppTypography.displayLarge.copyWith(
                            fontSize: AppTypography.rem(2.75),
                            fontWeight: FontWeight.w800,
                            color: context.textPrimary,
                            shadows: [
                              Shadow(
                                color: context.primaryColor.withValues(
                                  alpha: 0.45,
                                ),
                                blurRadius: 28,
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      FadeTransition(
                        opacity: _taglineOpacity,
                        child: Text(
                          context.l10n.tagline,
                          textAlign: TextAlign.center,
                          style: AppTypography.bodyLarge.copyWith(
                            color: context.textSecondary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.x4l),
                child: SizedBox(
                  width: MediaQuery.sizeOf(context).width * 0.4,
                  child: Shimmer.fromColors(
                    baseColor: context.primaryColor.withValues(alpha: 0.25),
                    highlightColor: context.primaryColor,
                    period: const Duration(milliseconds: 1200),
                    child: Container(
                      height: 3,
                      decoration: BoxDecoration(
                        color: context.primaryColor,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// The Orbit mark: a lit planet crossed by a tilted ring and a small moon.
class _OrbitPlanet extends StatelessWidget {
  const _OrbitPlanet();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 240,
      height: 160,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: 132,
            height: 132,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const RadialGradient(
                center: Alignment(-0.36, -0.44),
                colors: [
                  AppColors.white,
                  Color(0xFF9EE9FF),
                  Color(0xFF6C7BFF),
                  Color(0xFF2A1B6B),
                  Color(0xFF0C0F2A),
                ],
                stops: [0, 0.12, 0.45, 0.78, 1],
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF7CA0FF).withValues(alpha: 0.5),
                  blurRadius: 60,
                ),
              ],
            ),
          ),
          Transform.rotate(
            angle: -0.24,
            child: Container(
              width: 236,
              height: 50,
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.all(
                  Radius.elliptical(118, 25),
                ),
                border: Border.all(
                  color: AppColors.plasma.withValues(alpha: 0.6),
                  width: 1.5,
                ),
              ),
            ),
          ),
          Positioned(
            left: 18,
            top: 92,
            child: Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.cash,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.cash.withValues(alpha: 0.8),
                    blurRadius: 14,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
