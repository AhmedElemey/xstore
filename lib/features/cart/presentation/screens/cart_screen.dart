import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/utils/extensions/context_extensions.dart';
import '../../../../shared/widgets/auth_back_button.dart';
import '../../../../shared/widgets/orbit_background.dart';
import '../../../auth/domain/entities/user_entity.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../providers/cart_provider.dart';
import '../widgets/cart_clear_cart_sheet.dart';
import '../widgets/cart_consumer_body.dart';
import '../widgets/cart_vendor_buyers_only.dart';

class CartScreen extends ConsumerWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final role = ref.watch(
      authProvider.select((a) => a.valueOrNull?.role ?? UserRole.consumer),
    );
    final itemCount = ref.watch(cartProvider.select((c) => c.itemCount));
    final hasItems = ref.watch(cartProvider.select((c) => c.items.isNotEmpty));

    if (role == UserRole.vendor) {
      return Scaffold(
        body: OrbitBackground(
          child: SafeArea(
            bottom: false,
            child: Column(
              children: [
                _Header(title: context.l10n.cartTitle),
                const Expanded(child: CartVendorBuyersOnly()),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      body: OrbitBackground(
        child: SafeArea(
          bottom: false,
          child: Column(
            children: [
              _Header(
                title: context.l10n.cartAppBarTitle(itemCount),
                action: hasItems
                    ? Material(
                        color: context.glassColor,
                        shape: CircleBorder(
                          side: BorderSide(color: context.borderColor),
                        ),
                        clipBehavior: Clip.antiAlias,
                        child: IconButton(
                          tooltip: MaterialLocalizations.of(
                            context,
                          ).deleteButtonTooltip,
                          constraints: const BoxConstraints.tightFor(
                            width: 44,
                            height: 44,
                          ),
                          icon: Icon(
                            LucideIcons.trash2,
                            size: 20,
                            color: context.textPrimary,
                          ),
                          onPressed: () =>
                              showCartClearConfirmSheet(context, ref),
                        ),
                      )
                    : null,
              ),
              const Expanded(child: CartConsumerBody()),
            ],
          ),
        ),
      ),
    );
  }
}

/// Orbit screen header: frosted back button, Unbounded title, optional action.
class _Header extends StatelessWidget {
  const _Header({required this.title, this.action});

  final String title;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(
        AppSpacing.xl,
        AppSpacing.spacing18,
        AppSpacing.xl,
        AppSpacing.lg,
      ),
      child: Row(
        children: [
          const AuthBackButton(),
          const Gap(AppSpacing.md),
          Expanded(
            child: Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTypography.headlineSmall.copyWith(
                fontSize: 20,
                color: context.textPrimary,
              ),
            ),
          ),
          if (action != null) action!,
        ],
      ),
    );
  }
}
