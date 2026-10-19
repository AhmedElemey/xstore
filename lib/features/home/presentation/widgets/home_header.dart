import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../shared/widgets/notification_bell_button.dart';
import '../../../../shared/widgets/notification_icon_badge.dart';
import '../../../../core/utils/extensions/context_extensions.dart';

class HomeHeader extends ConsumerWidget {
  const HomeHeader({
    super.key,
    required this.onSearchTap,
    this.onCartTap,
    this.cartItemCount = 0,
  });

  final VoidCallback onSearchTap;
  final VoidCallback? onCartTap;
  final int cartItemCount;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SafeArea(
      bottom: false,
      child: Padding(
        padding: const EdgeInsetsDirectional.fromSTEB(
          AppSpacing.xl,
          AppSpacing.spacing18,
          AppSpacing.xl,
          AppSpacing.md,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Expanded(
                  child: ShaderMask(
                    blendMode: BlendMode.srcIn,
                    shaderCallback: (rect) => LinearGradient(
                      colors: context.brandGradient,
                    ).createShader(rect),
                    child: Text(
                      context.l10n.appName,
                      style: AppTypography.headlineSmall.copyWith(fontSize: 24),
                    ),
                  ),
                ),
                if (onCartTap != null) ...[
                  _GlassCircle(
                    child: IconButton(
                      tooltip: context.l10n.cartTitle,
                      onPressed: onCartTap,
                      icon: NotificationIconBadge(
                        count: cartItemCount,
                        child: Icon(
                          LucideIcons.shoppingCart,
                          size: 21,
                          color: context.textPrimary,
                        ),
                      ),
                    ),
                  ),
                  const Gap(AppSpacing.spacing10),
                ],
                _GlassCircle(
                  child: NotificationBellButton(
                    icon: LucideIcons.bell,
                    tooltip: context.l10n.notifications,
                  ),
                ),
              ],
            ),
            const Gap(AppSpacing.spacing18),
            Material(
              color: context.glassColor,
              shape: StadiumBorder(
                side: BorderSide(color: context.borderColor),
              ),
              clipBehavior: Clip.antiAlias,
              child: InkWell(
                onTap: onSearchTap,
                child: SizedBox(
                  height: 52,
                  child: Padding(
                    padding: const EdgeInsetsDirectional.symmetric(
                      horizontal: AppSpacing.spacing18,
                    ),
                    child: Row(
                      children: [
                        Icon(
                          LucideIcons.search,
                          color: context.linkColor,
                          size: AppSpacing.xl,
                        ),
                        const Gap(AppSpacing.spacing10),
                        Expanded(
                          child: Text(
                            context.l10n.searchHint,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppTypography.body15.copyWith(
                              color: context.labelColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            const Gap(AppSpacing.md),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _TrustChip(label: context.l10n.freeShippingBadge),
                  const Gap(AppSpacing.sm),
                  _TrustChip(label: context.l10n.securePayBadge),
                  const Gap(AppSpacing.sm),
                  _TrustChip(label: context.l10n.easyReturnsBadge),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 44px frosted circle behind a header action.
class _GlassCircle extends StatelessWidget {
  const _GlassCircle({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 44,
      height: 44,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: context.glassColor,
        shape: BoxShape.circle,
        border: Border.all(color: context.borderColor),
      ),
      child: child,
    );
  }
}

class _TrustChip extends StatelessWidget {
  const _TrustChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 32,
      alignment: Alignment.center,
      padding: const EdgeInsetsDirectional.symmetric(horizontal: AppSpacing.md),
      decoration: ShapeDecoration(
        color: context.glassColor,
        shape: StadiumBorder(side: BorderSide(color: context.borderColor)),
      ),
      child: Text(
        label,
        style: AppTypography.labelSmall.copyWith(
          color: context.textSecondary,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
