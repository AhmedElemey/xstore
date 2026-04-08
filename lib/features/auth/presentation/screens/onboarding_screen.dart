import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/prefs_keys.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../shared/providers/shared_providers.dart';
import '../widgets/auth_button.dart';
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

  static const _slideColors = [
    [Color(0xFF818CF8), Color(0xFF4F46E5)],
    [Color(0xFFFDBA74), Color(0xFFF97316)],
    [Color(0xFF6EE7B7), Color(0xFF22C55E)],
  ];

  Future<void> _finish() async {
    final prefs = await ref.read(sharedPreferencesProvider.future);
    await prefs.setBool(PrefsKeys.onboardingComplete, true);
    if (!mounted) return;
    context.go(AppRoutes.login);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.paddingOf(context).bottom;
    return Scaffold(
      backgroundColor: context.backgroundColor,
      body: Column(
        children: [
          Expanded(
            flex: 55,
            child: PageView.builder(
              controller: _pageController,
              itemCount: _slideIcons.length,
              onPageChanged: (i) => setState(() => _page = i),
              itemBuilder: (context, i) {
                return _IllustrationArea(
                  icon: _slideIcons[i],
                  gradientColors: _slideColors[i],
                );
              },
            ),
          ),
          Expanded(
            flex: 45,
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: context.surfaceColor,
                borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
                boxShadow: [
                  BoxShadow(
                    color: context.cardShadowColor,
                    blurRadius: 24,
                    offset: Offset(0, -4),
                  ),
                ],
              ),
              child: Padding(
                padding: EdgeInsets.fromLTRB(24, 28, 24, 24 + bottomInset),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: _finish,
                        child: Text(
                          'Skip',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: context.textSecondary,
                          ),
                        ),
                      ),
                    ),
                    const Gap(4),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(_slideIcons.length, (i) {
                        final active = i == _page;
                        return AnimatedContainer(
                          duration: const Duration(milliseconds: 280),
                          curve: Curves.easeOutCubic,
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          height: 8,
                          width: active ? 28 : 8,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(4),
                            color: active
                                ? AppColors.primary
                                : context.textDisabled,
                          ),
                        );
                      }),
                    ),
                    const Gap(20),
                    Expanded(
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 320),
                        switchInCurve: Curves.easeOut,
                        switchOutCurve: Curves.easeIn,
                        child: Column(
                          key: ValueKey(_page),
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Text(
                              [
                                'Discover Amazing Deals',
                                'Start Selling Today',
                                'Safe & Trusted',
                              ][_page],
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.w800,
                                color: context.textPrimary,
                              ),
                            ),
                            const Gap(12),
                            Text(
                              [
                                'Shop from thousands of vendors across Algeria and beyond',
                                'List your products in minutes and reach thousands of buyers',
                                'Secure payments, buyer protection, and verified sellers',
                              ][_page],
                              maxLines: 3,
                              style: TextStyle(
                                fontSize: 15,
                                height: 1.45,
                                color: context.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    AuthButton(
                      label: _page == _slideIcons.length - 1
                          ? 'Get Started'
                          : 'Next',
                      onPressed: () {
                        if (_page < _slideIcons.length - 1) {
                          _pageController.nextPage(
                            duration: const Duration(milliseconds: 380),
                            curve: Curves.easeOutCubic,
                          );
                        } else {
                          _finish();
                        }
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _IllustrationArea extends StatelessWidget {
  const _IllustrationArea({
    required this.icon,
    required this.gradientColors,
  });

  final IconData icon;
  final List<Color> gradientColors;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: context.backgroundColor,
      child: Center(
        child: Container(
          width: 200,
          height: 200,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: gradientColors,
            ),
            boxShadow: [
              BoxShadow(
                color: gradientColors.last.withValues(alpha: 0.35),
                blurRadius: 40,
                offset: const Offset(0, 16),
              ),
            ],
          ),
          child: Icon(
            icon,
            size: 88,
            color: Colors.white.withValues(alpha: 0.95),
          ),
        ),
      ),
    );
  }
}
