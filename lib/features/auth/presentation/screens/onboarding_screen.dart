import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../core/analytics/analytics_service.dart';
import '../../../../core/analytics/event_names.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/constants/prefs_keys.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../shared/providers/shared_providers.dart';
import '../../../../shared/widgets/xstore_button.dart';
import '../../../../core/utils/extensions/context_extensions.dart';
import '../../../../shared/widgets/orbit_widgets.dart';
import '../../../../shared/widgets/space_background.dart';

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
    ref.read(analyticsServiceProvider).track(
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
    final count = _slideIcons.length;
    final last = _page == count - 1;
    String two(int n) => n.toString().padLeft(2, '0');
    return Scaffold(
      backgroundColor: context.backgroundColor,
      body: SpaceBackground(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(28, AppSpacing.md, 28, 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        '${two(_page + 1)} / ${two(count)}',
                        style: AppTypography.labelSmall.copyWith(
                          color: context.textSecondary,
                          fontFeatures: const [FontFeature.tabularFigures()],
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: () => _finish(skipped: true),
                      style: TextButton.styleFrom(
                        foregroundColor: context.primaryColor,
                      ),
                      child: Text(context.l10n.skip),
                    ),
                  ],
                ),
                Expanded(
                  child: PageView.builder(
                    controller: _pageController,
                    itemCount: count,
                    onPageChanged: (i) => setState(() => _page = i),
                    itemBuilder: (context, i) => _Illustration(
                      icon: _slideIcons[i],
                      paletteIndex: i,
                    ),
                  ),
                ),
                // Text scrolls inside its slice so long translations never
                // overflow on short screens.
                SizedBox(
                  height: 190,
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 320),
                    switchInCurve: Curves.easeOut,
                    switchOutCurve: Curves.easeIn,
                    child: SingleChildScrollView(
                      key: ValueKey(_page),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            [
                              context.l10n.onboardingTitle1,
                              context.l10n.onboardingTitle2,
                              context.l10n.onboardingTitle3,
                            ][_page],
                            style: AppTypography.titleLarge.copyWith(
                              fontSize: 30,
                              height: 1.15,
                              fontWeight: FontWeight.w800,
                              color: context.textPrimary,
                            ),
                          ),
                          const Gap(AppSpacing.lg),
                          Text(
                            [
                              context.l10n.onboardingSubtitle1,
                              context.l10n.onboardingSubtitle2,
                              context.l10n.onboardingSubtitle3,
                            ][_page],
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
                const Gap(AppSpacing.xl),
                Row(
                  children: [
                    Expanded(
                      child: Row(
                        children: List.generate(count, (i) {
                          final active = i == _page;
                          final accent = context.primaryColor;
                          return AnimatedContainer(
                            duration: const Duration(milliseconds: 280),
                            curve: Curves.easeOutCubic,
                            margin: const EdgeInsetsDirectional.only(
                              end: AppSpacing.sm,
                            ),
                            height: 8,
                            width: active ? 28 : 8,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(4),
                              color: active ? accent : context.borderColor,
                              boxShadow: active
                                  ? [
                                      BoxShadow(
                                        color: accent.withValues(alpha: 0.7),
                                        blurRadius: 10,
                                      ),
                                    ]
                                  : null,
                            ),
                          );
                        }),
                      ),
                    ),
                    XstoreButton(
                      label: last ? context.l10n.getStarted : context.l10n.next,
                      onPressed: () {
                        if (!last) {
                          _pageController.nextPage(
                            duration: const Duration(milliseconds: 380),
                            curve: Curves.easeOutCubic,
                          );
                        } else {
                          _finish(skipped: false);
                        }
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// A lit planet crossed by a tilted orbit ring, carrying the slide's icon.
class _Illustration extends StatelessWidget {
  const _Illustration({required this.icon, required this.paletteIndex});

  final IconData icon;
  final int paletteIndex;

  @override
  Widget build(BuildContext context) {
    final ring = context.primaryColor.withValues(alpha: 0.5);
    return ExcludeSemantics(
      child: Center(
        child: SizedBox(
          width: 320,
          height: 240,
          child: Stack(
            alignment: Alignment.center,
            children: [
              OrbitGlyphOrb(
                icon: icon,
                paletteIndex: paletteIndex,
                size: 190,
              ),
              Transform.rotate(
                angle: -0.21,
                child: Container(
                  width: 320,
                  height: 72,
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.all(
                      Radius.elliptical(160, 36),
                    ),
                    border: Border.all(color: ring, width: 1.5),
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
