import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../../core/analytics/analytics_service.dart';
import '../../../../core/analytics/event_names.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/constants/prefs_keys.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../shared/providers/shared_providers.dart';
import '../../../../shared/widgets/orbit_background.dart';
import '../../../../shared/widgets/xstore_button.dart';
import '../../../../core/utils/extensions/context_extensions.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final _pageController = PageController();
  int _page = 0;

  static const _slideIcons = [
    LucideIcons.shoppingBag,
    LucideIcons.store,
    LucideIcons.shieldCheck,
  ];

  Future<void> _finish({required bool skipped}) async {
    final prefs = await ref.read(sharedPreferencesProvider.future);
    await prefs.setBool(PrefsKeys.onboardingComplete, true);
    if (!mounted) return;
    ref
        .read(analyticsServiceProvider)
        .track(
          skipped
              ? AnalyticsEvents.onboardingSkipped
              : AnalyticsEvents.onboardingCompleted,
        );
    context.go(AppRoutes.login);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final count = _slideIcons.length;
    final isLast = _page == count - 1;
    return Scaffold(
      body: OrbitBackground(
        child: SafeArea(
          child: Padding(
            // The illustration pager runs full-bleed so the orbit ring isn't
            // clipped; text rows get the 28px side padding.
            padding: const EdgeInsets.only(top: 24, bottom: 40),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  height: 44,
                  padding: _sidePadding,
                  child: Row(
                    children: [
                      Text(
                        '${_pad2(_page + 1)} / ${_pad2(count)}',
                        style: AppTypography.mono.copyWith(
                          fontSize: AppTypography.rem(0.75),
                          color: context.labelColor,
                        ),
                      ),
                      const Spacer(),
                      TextButton(
                        onPressed: () => _finish(skipped: true),
                        child: Text(
                          l10n.skip,
                          style: AppTypography.body15.copyWith(
                            fontWeight: FontWeight.w700,
                            color: context.linkColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  flex: 11,
                  child: PageView.builder(
                    controller: _pageController,
                    itemCount: count,
                    onPageChanged: (i) => setState(() => _page = i),
                    itemBuilder: (context, i) => _OrbitIllustration(
                      icon: _slideIcons[i],
                      accent: _slideAccent(context, i),
                    ),
                  ),
                ),
                Expanded(
                  flex: 7,
                  child: Padding(
                    padding: _sidePadding,
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 320),
                      switchInCurve: Curves.easeOut,
                      switchOutCurve: Curves.easeIn,
                      layoutBuilder: (current, previous) => Stack(
                        alignment: AlignmentDirectional.bottomStart,
                        children: [...previous, ?current],
                      ),
                      child: SingleChildScrollView(
                        key: ValueKey(_page),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Text(
                              [
                                l10n.onboardingTitle1,
                                l10n.onboardingTitle2,
                                l10n.onboardingTitle3,
                              ][_page],
                              style: AppTypography.headline.copyWith(
                                height: 1.15,
                                color: context.textPrimary,
                              ),
                            ),
                            const Gap(AppSpacing.spacing18),
                            Text(
                              [
                                l10n.onboardingSubtitle1,
                                l10n.onboardingSubtitle2,
                                l10n.onboardingSubtitle3,
                              ][_page],
                              maxLines: 3,
                              style: AppTypography.bodyLarge.copyWith(
                                height: 1.55,
                                color: context.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                const Gap(AppSpacing.spacing18),
                Padding(
                  padding: _sidePadding,
                  child: Row(
                    children: [
                      for (var i = 0; i < count; i++)
                        _PageDot(active: i == _page),
                      const Spacer(),
                      ConstrainedBox(
                        constraints: const BoxConstraints(minWidth: 150),
                        child: XstoreButton(
                          label: isLast ? l10n.getStarted : l10n.next,
                          onPressed: () {
                            if (!isLast) {
                              _pageController.nextPage(
                                duration: const Duration(milliseconds: 380),
                                curve: Curves.easeOutCubic,
                              );
                            } else {
                              _finish(skipped: false);
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  static const _sidePadding = EdgeInsets.symmetric(horizontal: 28);

  /// Slide counter number, zero-padded to two places ("01 / 03").
  static String _pad2(int n) => n.toString().padLeft(2, '0');

  /// Per-slide accent: brand for shopping, amber for stores, green for trust.
  static Color _slideAccent(BuildContext context, int i) => switch (i) {
    0 => context.linkColor,
    1 => context.amberColor,
    _ => context.isDark ? AppColors.successLight : AppColors.success,
  };
}

class _PageDot extends StatelessWidget {
  const _PageDot({required this.active});

  final bool active;

  @override
  Widget build(BuildContext context) {
    final on = context.isDark ? AppColors.primaryLight : AppColors.primary;
    final off = context.isDark
        ? AppColors.white.withValues(alpha: 0.22)
        : AppColors.primary.withValues(alpha: 0.26);
    return AnimatedContainer(
      duration: const Duration(milliseconds: 280),
      curve: Curves.easeOutCubic,
      margin: const EdgeInsetsDirectional.only(end: AppSpacing.sm),
      height: 8,
      width: active ? 28 : 8,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(4),
        color: active ? on : off,
        boxShadow: active ? [BoxShadow(color: on, blurRadius: 10)] : null,
      ),
    );
  }
}

/// Planet on a tilted orbit ring, with a frosted badge carrying the slide's
/// icon.
class _OrbitIllustration extends StatelessWidget {
  const _OrbitIllustration({required this.icon, required this.accent});

  final IconData icon;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    final ring = context.isDark ? AppColors.primaryLight : AppColors.primary;
    return Center(
      child: SizedBox(
        height: 300,
        child: Stack(
          alignment: Alignment.center,
          clipBehavior: Clip.none,
          children: [
            const OrbitPlanet(size: 210),
            // Keeps the ring 380px wide even on narrower phones.
            OverflowBox(
              maxWidth: 380,
              child: Transform.rotate(
                angle: -12 * math.pi / 180,
                child: Container(
                  width: 380,
                  height: 80,
                  decoration: ShapeDecoration(
                    shape: OvalBorder(
                      side: BorderSide(
                        color: ring.withValues(alpha: 0.5),
                        width: 1.5,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            PositionedDirectional(
              end: 28,
              bottom: 8,
              child: Container(
                width: 76,
                height: 76,
                decoration: ShapeDecoration(
                  color: context.glassColor,
                  shape: CircleBorder(
                    side: BorderSide(color: context.borderColor),
                  ),
                  shadows: [
                    BoxShadow(
                      color: accent.withValues(alpha: 0.18),
                      blurRadius: 24,
                    ),
                  ],
                ),
                child: Icon(icon, size: 34, color: accent),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
