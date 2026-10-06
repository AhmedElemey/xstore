import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../auth/domain/entities/user_entity.dart';
import '../../../../core/utils/extensions/context_extensions.dart';

class ProfileStatsRow extends StatelessWidget {
  const ProfileStatsRow({
    super.key,
    required this.role,
    this.sales,
    this.rating,
    this.responsePercent,
    this.orders,
    this.wishlistCount,
    this.savedDzd,
    this.onSalesTap,
    this.onRatingTap,
    this.onResponseTap,
    this.onOrdersTap,
    this.onWishlistTap,
    this.onSavedTap,
  });

  final UserRole role;
  final int? sales;
  final double? rating;
  final int? responsePercent;
  final int? orders;
  final int? wishlistCount;
  final int? savedDzd;
  final VoidCallback? onSalesTap;
  final VoidCallback? onRatingTap;
  final VoidCallback? onResponseTap;
  final VoidCallback? onOrdersTap;
  final VoidCallback? onWishlistTap;
  final VoidCallback? onSavedTap;

  @override
  Widget build(BuildContext context) {
    if (role == UserRole.vendor) {
      // The API doesn't send these yet; show "—" instead of a fake zero.
      final dash = context.l10n.newSellerEmDash;
      final s = sales;
      final r = rating;
      final pct = responsePercent;
      return _Card(
        child: Row(
          children: [
            Expanded(
              child: _StatCell(
                value: s != null && s > 0 ? '$s' : dash,
                label: context.l10n.statSales,
                onTap: onSalesTap,
              ),
            ),
            const _VertDivider(),
            Expanded(
              child: _StatCell(
                value: r != null && r > 0 ? '${r.toStringAsFixed(1)} ★' : dash,
                label: context.l10n.statRating,
                onTap: onRatingTap,
              ),
            ),
            const _VertDivider(),
            Expanded(
              child: _StatCell(
                value: pct != null && pct > 0 ? '$pct%' : dash,
                label: context.l10n.statResponse,
                onTap: onResponseTap,
              ),
            ),
          ],
        ),
      );
    }

    return _Card(
      child: Row(
        children: [
          Expanded(
            child: _StatCell(
              value: '${orders ?? 0}',
              label: context.l10n.statOrders,
              onTap: onOrdersTap,
            ),
          ),
          const _VertDivider(),
          Expanded(
            child: _StatCell(
              value: '${wishlistCount ?? 0}',
              label: context.l10n.statWishlist,
              onTap: onWishlistTap,
            ),
          ),
          const _VertDivider(),
          Expanded(
            child: _StatCell(
              value: context.formatCurrency((savedDzd ?? 0) / 100.0),
              label: context.l10n.statTotalSaved,
              isMoney: true,
              onTap: onSavedTap,
            ),
          ),
        ],
      ),
    );
  }
}

class _Card extends StatelessWidget {
  const _Card({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
      decoration: BoxDecoration(
        color: context.glassColor,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: context.borderColor),
      ),
      clipBehavior: Clip.antiAlias,
      child: child,
    );
  }
}

class _VertDivider extends StatelessWidget {
  const _VertDivider();

  @override
  Widget build(BuildContext context) {
    return Container(width: 1, height: 40, color: context.borderColor);
  }
}

class _StatCell extends StatelessWidget {
  const _StatCell({
    required this.value,
    required this.label,
    this.onTap,
    this.isMoney = false,
  });

  final String value;
  final String label;
  final VoidCallback? onTap;
  final bool isMoney;

  static const _star = ' ★';

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
        child: Column(
          children: [
            Text.rich(
              TextSpan(
                children: [
                  TextSpan(text: value.replaceFirst(_star, '')),
                  // The mono face has no star glyph; draw it in the body font.
                  if (value.endsWith(_star))
                    TextSpan(
                      text: _star,
                      style: AppTypography.bodySmall.copyWith(
                        fontSize: 16,
                        color: context.textPrimary,
                      ),
                    ),
                ],
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTypography.mono.copyWith(
                fontSize: 18,
                color: isMoney ? context.amberColor : context.textPrimary,
                fontWeight: FontWeight.w700,
              ),
            ),
            const Gap(AppSpacing.xs),
            Text(
              label.toUpperCase(),
              style: AppTypography.fieldLabel.copyWith(
                color: context.labelColor,
                fontSize: 10,
                letterSpacing: 0.6,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
            ),
          ],
        ),
      ),
    );
  }
}
