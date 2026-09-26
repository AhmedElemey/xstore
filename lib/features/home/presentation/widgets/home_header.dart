import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/utils/extensions/context_extensions.dart';
import '../../../../shared/widgets/notification_bell_button.dart';
import '../../../../shared/widgets/orbit_widgets.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../wishlist/presentation/providers/wishlist_provider.dart';

/// Orbit Home header: greeting and name, wishlist heart and bell on glass
/// discs, then the search pill.
class HomeHeader extends ConsumerWidget {
  const HomeHeader({
    super.key,
    required this.onSearchTap,
    this.onWishlistTap,
  });

  final VoidCallback onSearchTap;

  /// Null hides the heart (vendors don't have a wishlist).
  final VoidCallback? onWishlistTap;

  String _greeting(BuildContext context) {
    final hour = DateTime.now().hour;
    if (hour < 12) return context.l10n.homeGreetingMorning;
    if (hour < 17) return context.l10n.homeGreetingAfternoon;
    return context.l10n.homeGreetingEvening;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final name = ref.watch(
      authProvider.select((a) => a.valueOrNull?.name.trim() ?? ''),
    );
    final firstName = name.isEmpty ? '' : name.split(RegExp(r'\s+')).first;
    final hasSaved = onWishlistTap != null &&
        ref.watch(wishlistProvider.select((s) => s.itemCount > 0));

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.sm,
        AppSpacing.lg,
        AppSpacing.lg,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _greeting(context),
                      style: AppTypography.bodySmall.copyWith(
                        color: context.textSecondary,
                      ),
                    ),
                    const Gap(2),
                    Text(
                      firstName.isEmpty ? context.l10n.appName : firstName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.titleSmall.copyWith(
                        fontWeight: FontWeight.w800,
                        color: context.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
              if (onWishlistTap != null) ...[
                OrbitCircleButton(
                  tooltip: context.l10n.navWishlist,
                  onPressed: onWishlistTap,
                  child: Icon(
                    hasSaved ? Icons.favorite_rounded : LucideIcons.heart,
                    size: 21,
                    color: hasSaved ? AppColors.errorLight : context.textPrimary,
                  ),
                ),
                const Gap(AppSpacing.sm),
              ],
              DecoratedBox(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: glassFill(context),
                  border: Border.all(color: context.borderColor),
                ),
                child: SizedBox(
                  width: 44,
                  height: 44,
                  child: NotificationBellButton(
                    icon: LucideIcons.bell,
                    tooltip: context.l10n.notifications,
                  ),
                ),
              ),
            ],
          ),
          const Gap(AppSpacing.lg),
          Material(
            color: glassFill(context),
            shape: StadiumBorder(side: BorderSide(color: context.borderColor)),
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              onTap: onSearchTap,
              child: SizedBox(
                height: 52,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.lg,
                  ),
                  child: Row(
                    children: [
                      Icon(
                        LucideIcons.search,
                        color: context.primaryColor,
                        size: 20,
                      ),
                      const Gap(AppSpacing.md),
                      Expanded(
                        child: Text(
                          context.l10n.homeSearchProductsStores,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTypography.bodyMedium.copyWith(
                            color: context.textSecondary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// The trust promises that used to sit under the search bar; the design has
/// no slot for them, so Home shows them lower down.
class HomeTrustChips extends StatelessWidget {
  const HomeTrustChips({super.key});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: AppSpacing.sm,
      runSpacing: AppSpacing.sm,
      children: [
        for (final label in [
          context.l10n.freeShippingBadge,
          context.l10n.securePayBadge,
          context.l10n.easyReturnsBadge,
        ])
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.xs + 2,
            ),
            decoration: BoxDecoration(
              color: glassFill(context),
              borderRadius: BorderRadius.circular(AppSpacing.x3l),
              border: Border.all(color: context.borderColor),
            ),
            child: Text(
              label,
              style: AppTypography.labelSmall.copyWith(
                color: context.textSecondary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
      ],
    );
  }
}
