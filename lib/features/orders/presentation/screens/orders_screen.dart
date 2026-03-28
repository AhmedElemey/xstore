import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../shared/widgets/empty_state_widget.dart';

class OrdersScreen extends ConsumerWidget {
  const OrdersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text(AppStrings.ordersTitle)),
      body: RefreshIndicator(
        color: AppColors.primary,
        onRefresh: () async {
          await Future<void>.delayed(const Duration(milliseconds: 400));
        },
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(AppSpacing.lg),
          children: [
            const Gap(AppSpacing.x2l),
            EmptyStateWidget(
              title: AppStrings.ordersEmptyTitle,
              subtitle: AppStrings.ordersEmptySubtitle,
            ),
          ],
        ),
      ),
    );
  }
}
