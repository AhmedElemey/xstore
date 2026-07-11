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
import '../../../../shared/providers/shared_providers.dart';
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

    final user = ref.read(authProvider).valueOrNull;
    if (user != null) {
      context.go(AppRoutes.home);
      return;
    }

    final prefs = await ref.read(sharedPreferencesProvider.future);
    if (!mounted) return;

    // Returning guest: re-enter browse mode directly. enable() sets the
    // provider state synchronously, so the router redirect sees it before
    // the navigation below is evaluated.
    if (prefs.getBool(PrefsKeys.guestMode) ?? false) {
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

  static const _deepIndigo = AppColors.primaryDark;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
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
        child: Column(
          children: [
            Expanded(
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ScaleTransition(
                      scale: Tween<double>(begin: 0.85, end: 1).animate(_logoScale),
                      child: Text(
                        'xStore',
                        style: AppTypography.displayLarge.copyWith(
                          fontSize: AppTypography.rem(3),
                          fontWeight: FontWeight.w800,
                          color: AppColors.white,
                          letterSpacing: -1,
                          shadows: [
                            Shadow(
                              color: AppColors.white.withValues(alpha: 0.4),
                              blurRadius: 28,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    FadeTransition(
                      opacity: _taglineOpacity,
                      child: Text(
                        'Buy & Sell Anything',
                        style: AppTypography.bodyLarge.copyWith(
                          color: AppColors.white.withValues(alpha: 0.92),
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
                  baseColor: AppColors.white.withValues(alpha: 0.25),
                  highlightColor: AppColors.white.withValues(alpha: 0.65),
                  period: const Duration(milliseconds: 1200),
                  child: Container(
                    height: 3,
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
